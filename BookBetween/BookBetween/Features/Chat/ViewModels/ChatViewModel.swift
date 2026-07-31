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
  private(set) var isLoading = false
  private(set) var questionUpdateTrigger = 0
  var errorMessage: String?

  // MARK: - Properties

  private let chatroomId: Int
  private let meetingId: Int
  private let chatService: any ChatServiceProtocol
  private let socketService: any ChatSocketServiceProtocol
  private var eventListeningTask: Task<Void, Never>?

  // MARK: - Init

  init(
    chatroomId: Int,
    meetingId: Int,
    chatService: any ChatServiceProtocol,
    socketService: any ChatSocketServiceProtocol
  ) {
    self.chatroomId = chatroomId
    self.meetingId = meetingId
    self.chatService = chatService
    self.socketService = socketService
  }

  // MARK: - Lifecycle

  func enterChatRoom() async {
    guard !self.isLoading else { return }
    self.isLoading = true
    self.errorMessage = nil
    defer { self.isLoading = false }

    do {
      try await self.socketService.connect()
      let eventStream = try await self.socketService.subscribe(chatroomId: self.chatroomId)
      self.startListening(to: eventStream)

      let chatRoom = try await self.chatService.fetchChatRoom(chatroomId: self.chatroomId)
      self.applyInitialState(from: chatRoom)
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
    guard !trimmed.isEmpty, trimmed.count <= Self.messageMaxLength else { return }

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
      self.isMeetingEnded = true
      let socketService = self.socketService
      Task {
        await socketService.disconnect()
      }
    }
  }
}
