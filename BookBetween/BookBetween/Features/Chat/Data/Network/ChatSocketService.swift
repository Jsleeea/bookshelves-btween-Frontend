//
//  ChatSocketService.swift
//  BookBetween
//
//  Created by 한지민 on 8/1/26.
//

import Foundation

protocol ChatSocketServiceProtocol {
  func connect() async throws
  func subscribe(chatroomId: Int) async throws -> AsyncThrowingStream<ChatSocketEvent, Error>
  func send(chatroomId: Int, content: String) async throws
  func disconnect() async
}

@MainActor
final class ChatSocketService: ChatSocketServiceProtocol {

  // MARK: - Constant

  private enum Constant {
    static let stompVersion = "1.2"
    static let heartBeatHeaderValue = "10000,10000"
    static let heartBeatInterval: Duration = .seconds(10)
    static let webSocketPath = "/ws-stomp"
  }

  // MARK: - Properties

  private let baseURL: URL
  private let accessTokenProvider: () -> String?
  private let session: URLSession

  private var webSocketTask: URLSessionWebSocketTask?
  private var receiveTask: Task<Void, Never>?
  private var heartBeatTask: Task<Void, Never>?
  private var connectContinuation: CheckedContinuation<Void, Error>?
  private var eventContinuation: AsyncThrowingStream<ChatSocketEvent, Error>.Continuation?

  // MARK: - Init

  init(configuration: NetworkConfiguration) {
    self.baseURL = configuration.baseURL
    self.accessTokenProvider = configuration.accessToken
    self.session = URLSession(configuration: .default)
  }

  // MARK: - Connect

  func connect() async throws {
    guard let accessToken = self.accessTokenProvider() else {
      throw ChatSocketServiceError.missingAccessToken
    }

    let webSocketURL = try Self.makeWebSocketURL(from: self.baseURL)
    let task = self.session.webSocketTask(with: webSocketURL)
    self.webSocketTask = task
    task.resume()

    self.startReceiving()

    try await self.sendFrame(
      STOMPFrame(
        command: STOMPCommand.connect.rawValue,
        headers: [
          "accept-version": Constant.stompVersion,
          "heart-beat": Constant.heartBeatHeaderValue,
          "Authorization": "Bearer \(accessToken)"
        ]
      )
    )

    try await withCheckedThrowingContinuation { continuation in
      self.connectContinuation = continuation
    }

    self.startHeartBeat()
  }

  // MARK: - Subscribe

  func subscribe(chatroomId: Int) async throws -> AsyncThrowingStream<ChatSocketEvent, Error> {
    let (stream, continuation) = AsyncThrowingStream<ChatSocketEvent, Error>.makeStream()
    self.eventContinuation = continuation

    try await self.sendFrame(
      STOMPFrame(
        command: STOMPCommand.subscribe.rawValue,
        headers: [
          "id": "sub-\(chatroomId)",
          "destination": "/sub/chatrooms/\(chatroomId)"
        ]
      )
    )

    return stream
  }

  // MARK: - Send

  func send(chatroomId: Int, content: String) async throws {
    let payload = try JSONEncoder().encode(["content": content])
    guard let body = String(data: payload, encoding: .utf8) else {
      throw ChatSocketServiceError.invalidPayload
    }

    try await self.sendFrame(
      STOMPFrame(
        command: STOMPCommand.send.rawValue,
        headers: [
          "destination": "/pub/chatrooms/\(chatroomId)",
          "content-type": "application/json"
        ],
        body: body
      )
    )
  }

  // MARK: - Disconnect

  func disconnect() async {
    try? await self.sendFrame(STOMPFrame(command: STOMPCommand.disconnect.rawValue))

    self.heartBeatTask?.cancel()
    self.heartBeatTask = nil
    self.receiveTask?.cancel()
    self.receiveTask = nil

    self.connectContinuation?.resume(throwing: CancellationError())
    self.connectContinuation = nil

    self.eventContinuation?.finish()
    self.eventContinuation = nil

    self.webSocketTask?.cancel(with: .normalClosure, reason: nil)
    self.webSocketTask = nil
  }

  // MARK: - Frame Sending

  private func sendFrame(_ frame: STOMPFrame) async throws {
    guard let webSocketTask = self.webSocketTask else {
      throw ChatSocketServiceError.notConnected
    }
    try await webSocketTask.send(.string(frame.encode()))
  }

  // MARK: - Receiving

  private func startReceiving() {
    self.receiveTask = Task { [weak self] in
      while let self, !Task.isCancelled {
        guard let task = self.webSocketTask else { break }

        do {
          let message = try await task.receive()
          self.handle(message)
        } catch {
          self.handleReceiveFailure(error)
          break
        }
      }
    }
  }

  private func handle(_ message: URLSessionWebSocketTask.Message) {
    switch message {
    case .string(let text):
      self.handle(text: text)
    case .data(let data):
      if let text = String(data: data, encoding: .utf8) {
        self.handle(text: text)
      }
    @unknown default:
      break
    }
  }

  private func handle(text: String) {
    guard text != "\n", !text.isEmpty else {
      // 서버 heart-beat 프레임입니다. presence 확인용이라 별도 처리가 필요 없습니다.
      return
    }

    guard let frame = STOMPFrame.parse(text) else { return }

    switch frame.command {
    case STOMPCommand.connected.rawValue:
      self.connectContinuation?.resume()
      self.connectContinuation = nil

    case STOMPCommand.message.rawValue:
      guard let bodyData = frame.body.data(using: .utf8) else { return }
      do {
        let event = try ChatSocketFrameDecoder.decode(bodyData)
        self.eventContinuation?.yield(event)
        if case .meetingEnded = event {
          self.eventContinuation?.finish()
        }
      } catch {
        self.eventContinuation?.yield(with: .failure(error))
      }

    case STOMPCommand.error.rawValue:
      let error = ChatSocketServiceError.serverError(frame.body)
      self.connectContinuation?.resume(throwing: error)
      self.connectContinuation = nil
      self.eventContinuation?.yield(with: .failure(error))

    default:
      break
    }
  }

  private func handleReceiveFailure(_ error: Error) {
    self.connectContinuation?.resume(throwing: error)
    self.connectContinuation = nil
    self.eventContinuation?.finish(throwing: error)
  }

  // MARK: - Heart Beat

  private func startHeartBeat() {
    self.heartBeatTask = Task { [weak self] in
      while let self, !Task.isCancelled {
        try? await Task.sleep(for: Constant.heartBeatInterval)
        try? await self.sendRawHeartBeat()
      }
    }
  }

  private func sendRawHeartBeat() async throws {
    guard let webSocketTask = self.webSocketTask else { return }
    try await webSocketTask.send(.string("\n"))
  }

  // MARK: - URL

  private static func makeWebSocketURL(from baseURL: URL) throws -> URL {
    guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
      throw ChatSocketServiceError.invalidURL
    }

    switch components.scheme {
    case "https":
      components.scheme = "wss"
    case "http":
      components.scheme = "ws"
    default:
      break
    }

    components.path = Constant.webSocketPath

    guard let url = components.url else {
      throw ChatSocketServiceError.invalidURL
    }

    return url
  }
}

enum ChatSocketServiceError: LocalizedError {
  case invalidURL
  case notConnected
  case missingAccessToken
  case invalidPayload
  case serverError(String)

  var errorDescription: String? {
    switch self {
    case .invalidURL:
      return "채팅 서버 주소가 올바르지 않습니다."
    case .notConnected:
      return "채팅 서버에 연결되어 있지 않습니다."
    case .missingAccessToken:
      return "로그인 정보가 없어 채팅 서버에 연결할 수 없습니다."
    case .invalidPayload:
      return "메시지를 전송할 수 없습니다."
    case .serverError(let message):
      return message
    }
  }
}
