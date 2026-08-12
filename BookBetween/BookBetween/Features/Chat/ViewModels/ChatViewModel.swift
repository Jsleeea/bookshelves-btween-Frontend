//
//  ChatViewModel.swift
//  BookBetween
//
//  Created by 한지민 on 8/1/26.
//

import Foundation
import Observation

@Observable
@MainActor
final class ChatViewModel {

  // MARK: - Constant

  static let messageMaxLength = 500

  // MARK: - State

  private(set) var chatRoom: ChatRoom?
  private(set) var messages: [ChatMessage] = []
  private(set) var currentQuestion: ChatQuestion?
  private(set) var maxQuestions = 0
  private(set) var voteCurrentCount = 0
  private(set) var voteRequiredCount = 0
  private(set) var hasVotedThisRound = false
  private(set) var appliedCount = 0
  private(set) var connectedCount = 0
  private(set) var myMemberId: Int?
  private(set) var isMeetingEnded = false
  private(set) var endedMeeting: BookMeeting?
  private(set) var showsEndedMeetingNotice = false
  var isReported = false
  private(set) var isLoading = false
  private(set) var questionUpdateTrigger = 0
  var errorMessage: String?

  // MARK: - Properties

  private let chatroomId: Int
  let meetingId: Int
  private let chatService: any ChatServiceProtocol
  private let socketService: any ChatSocketServiceProtocol
  private let meetingService: (any MeetingServiceProtocol)?
  private var eventListeningTask: Task<Void, Never>?

  // MARK: - Init

  init(
    chatroomId: Int,
    meetingId: Int,
    chatService: any ChatServiceProtocol,
    socketService: any ChatSocketServiceProtocol,
    meetingService: (any MeetingServiceProtocol)? = nil
  ) {
    self.chatroomId = chatroomId
    self.meetingId = meetingId
    self.chatService = chatService
    self.socketService = socketService
    self.meetingService = meetingService
  }

  // MARK: - Lifecycle

  func enterChatRoom() async {
    guard !self.isLoading else { return }
    guard !self.isMeetingEnded else {
      self.showsEndedMeetingNotice = true
      return
    }
    self.isLoading = true
    self.errorMessage = nil
    defer { self.isLoading = false }

    do {
      try await self.socketService.connect()
      let eventStream = try await self.socketService.subscribe(chatroomId: self.chatroomId)
      self.startListening(to: eventStream)

      let chatRoom = try await self.chatService.fetchChatRoom(chatroomId: self.chatroomId)
      self.applyInitialState(from: chatRoom)
    } catch let NetworkError.server(_, code, _) where code.hasPrefix("CHAT410") {
      self.handleMeetingEnded()
    } catch {
      self.errorMessage = error.localizedDescription
    }
  }

  // MARK: - Reconnect

  func reconnect() async {
    guard !self.isLoading else { return }
    await self.socketService.disconnect()
    await self.enterChatRoom()
  }

  // MARK: - Actions

  func sendMessage(_ content: String) async {
    let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty, content.utf16.count <= Self.messageMaxLength else { return }

    do {
      try await self.socketService.send(chatroomId: self.chatroomId, content: trimmed)
    } catch {
      self.errorMessage = error.localizedDescription
    }
  }

  func requestNewQuestion() async {
    do {
      _ = try await self.chatService.voteForNewQuestion(meetingId: self.meetingId)
      self.hasVotedThisRound = true
    } catch {
      self.errorMessage = error.localizedDescription
    }
  }

  func reportChatRoom() async {
    do {
      _ = try await self.chatService.reportChatRoom(chatroomId: self.chatroomId)
      self.isReported = true
    } catch {
      self.errorMessage = error.localizedDescription
    }
  }

  // MARK: - Meeting End Timer

  func checkMeetingEndedByTime(at date: Date = .now) {
    guard let endsAt = self.chatRoom?.endsAt, date >= endsAt else { return }
    self.handleMeetingEnded()
  }

  // MARK: - Initial State

  private func applyInitialState(from chatRoom: ChatRoom) {
    self.chatRoom = chatRoom
    self.messages = chatRoom.messages
    self.currentQuestion = chatRoom.currentQuestion
    self.maxQuestions = chatRoom.maxQuestions
    self.voteCurrentCount = chatRoom.vote.currentVotes
    self.voteRequiredCount = chatRoom.vote.requiredVotes
    self.hasVotedThisRound = chatRoom.vote.voted
    self.appliedCount = chatRoom.participants.applied
    self.connectedCount = chatRoom.participants.connected
    self.myMemberId = chatRoom.myMemberId
  }

  // MARK: - Event Handling

  private func startListening(to stream: AsyncThrowingStream<ChatSocketEvent, Error>) {
    self.eventListeningTask = Task { [weak self] in
      guard let self else { return }

      do {
        for try await event in stream {
          self.handle(event)
        }
      } catch let ChatSocketServiceError.serverError(code, _) where code.hasPrefix("CHAT410") {
        self.handleMeetingEnded()
      } catch {
        self.errorMessage = error.localizedDescription
      }
    }
  }

  private func handle(_ event: ChatSocketEvent) {
    switch event {
    case .message(let message):
      self.messages.append(message)

    case .question(let question, let maxQuestions):
      self.currentQuestion = question
      self.maxQuestions = maxQuestions
      self.voteCurrentCount = 0
      self.hasVotedThisRound = false
      self.questionUpdateTrigger += 1

    case .voteCount(let currentVotes, let requiredVotes):
      self.voteCurrentCount = currentVotes
      self.voteRequiredCount = requiredVotes

    case .participant(let update):
      self.connectedCount = update.connected
      self.voteRequiredCount = update.requiredVotes
      self.voteCurrentCount = update.currentVotes

    case .meetingEnded:
      self.handleMeetingEnded()
    }
  }

  private func handleMeetingEnded() {
    guard !self.isMeetingEnded else { return }
    self.isMeetingEnded = true

    let socketService = self.socketService
    Task {
      await socketService.disconnect()
    }

    if let meetingService {
      let meetingId = self.meetingId
      Task { [weak self] in
        let meeting = try? await meetingService.fetchMeetingDetail(meetingId: meetingId)
        self?.endedMeeting = meeting
      }
    }
  }
}
