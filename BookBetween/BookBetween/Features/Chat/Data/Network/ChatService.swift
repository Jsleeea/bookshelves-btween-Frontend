//
//  ChatService.swift
//  BookBetween
//
//  Created by 한지민 on 8/1/26.
//

import Foundation
import Moya

protocol ChatServiceProtocol {
  func fetchChatRoom(chatroomId: Int) async throws -> ChatRoom
  func reportChatRoom(chatroomId: Int) async throws -> ChatReport
  func voteForNewQuestion(meetingId: Int) async throws -> QuestionVoteResult
}

final class ChatService: ChatServiceProtocol {
  private let baseURL: URL
  private let provider: MoyaProvider<ChatTarget>
  private let requestExecutor: AuthenticatedRequestExecutor

  init(configuration: NetworkConfiguration) {
    self.baseURL = configuration.baseURL
    self.provider = MoyaProvider<ChatTarget>(
      plugins: [
        AuthorizationPlugin(accessToken: configuration.accessToken)
      ]
    )
    self.requestExecutor = AuthenticatedRequestExecutor(
      reissueTokens: configuration.reissueTokens
    )
  }

  init(baseURL: URL, provider: MoyaProvider<ChatTarget>) {
    self.baseURL = baseURL
    self.provider = provider
    self.requestExecutor = AuthenticatedRequestExecutor(
      reissueTokens: nil
    )
  }

  static func stubbed() -> ChatService {
    let baseURL = URL(string: "https://stub.bookbetween.local")!
    let provider = MoyaProvider<ChatTarget>(
      stubClosure: { _ in .immediate }
    )
    return ChatService(baseURL: baseURL, provider: provider)
  }

  func fetchChatRoom(chatroomId: Int) async throws -> ChatRoom {
    try await self.requestExecutor.execute {
      do {
        let response = try await self.provider.requestAsync(
          ChatTarget(baseURL: self.baseURL, endpoint: .fetchChatRoom(chatroomId: chatroomId))
        )
        return try response.decodePayload(ChatRoomResultDTO.self).toDomain()
      } catch let error as MoyaError {
        throw NetworkError.transport(error)
      }
    }
  }

  func reportChatRoom(chatroomId: Int) async throws -> ChatReport {
    try await self.requestExecutor.execute {
      do {
        let response = try await self.provider.requestAsync(
          ChatTarget(baseURL: self.baseURL, endpoint: .reportChatRoom(chatroomId: chatroomId))
        )
        return try response.decodePayload(ChatReportResultDTO.self).toDomain()
      } catch let error as MoyaError {
        throw NetworkError.transport(error)
      }
    }
  }

  func voteForNewQuestion(meetingId: Int) async throws -> QuestionVoteResult {
    try await self.requestExecutor.execute {
      do {
        let response = try await self.provider.requestAsync(
          ChatTarget(baseURL: self.baseURL, endpoint: .voteForNewQuestion(meetingId: meetingId))
        )
        return try response.decodePayload(QuestionVoteResultDTO.self).toDomain()
      } catch let error as MoyaError {
        throw NetworkError.transport(error)
      }
    }
  }
}
