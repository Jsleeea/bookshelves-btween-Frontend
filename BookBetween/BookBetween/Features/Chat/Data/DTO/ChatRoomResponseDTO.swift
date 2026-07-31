//
//  ChatRoomResponseDTO.swift
//  BookBetween
//
//  Created by 한지민 on 8/1/26.
//

import Foundation

struct ChatRoomResultDTO: Decodable {
  let chatroomId: Int
  let meetingId: Int
  let bookTitle: String
  let status: String
  let startsAt: String
  let endsAt: String
  let maxParticipants: Int
  let participants: ChatParticipantsDTO
  let myMemberId: Int
  let currentQuestion: ChatQuestionDTO?
  let maxQuestions: Int
  let vote: ChatVoteDTO
  let messages: [ChatMessageDTO]
}

struct ChatParticipantsDTO: Decodable {
  let applied: Int
  let connected: Int
}

struct ChatQuestionDTO: Decodable {
  let questionId: Int
  let questionOrder: Int
  let content: String
}

struct ChatVoteDTO: Decodable {
  let currentVotes: Int
  let requiredVotes: Int
  let voted: Bool
}

struct ChatMessageDTO: Decodable {
  let messageId: Int
  let senderMemberId: Int
  let senderNickname: String
  let content: String
  let createdAt: String
}

extension ChatRoomResultDTO {
  func toDomain() throws -> ChatRoom {
    ChatRoom(
      chatroomId: chatroomId,
      meetingId: meetingId,
      bookTitle: bookTitle,
      status: status,
      startsAt: try parseChatAPIDate(startsAt),
      endsAt: try parseChatAPIDate(endsAt),
      maxParticipants: maxParticipants,
      participants: ChatParticipants(
        applied: participants.applied,
        connected: participants.connected
      ),
      myMemberId: myMemberId,
      currentQuestion: currentQuestion.map {
        ChatQuestion(
          questionId: $0.questionId,
          questionOrder: $0.questionOrder,
          content: $0.content
        )
      },
      maxQuestions: maxQuestions,
      vote: ChatVote(
        currentVotes: vote.currentVotes,
        requiredVotes: vote.requiredVotes,
        voted: vote.voted
      ),
      messages: try messages.map { try $0.toDomain() }
    )
  }
}

extension ChatMessageDTO {
  func toDomain() throws -> ChatMessage {
    ChatMessage(
      messageId: messageId,
      senderMemberId: senderMemberId,
      senderNickname: senderNickname,
      content: content,
      createdAt: try parseChatAPIDate(createdAt)
    )
  }
}

func parseChatAPIDate(_ value: String) throws -> Date {
  let iso8601Formatter = ISO8601DateFormatter()
  if let date = iso8601Formatter.date(from: value) {
    return date
  }

  let fractionalISO8601Formatter = ISO8601DateFormatter()
  fractionalISO8601Formatter.formatOptions = [
    .withInternetDateTime,
    .withFractionalSeconds
  ]
  if let date = fractionalISO8601Formatter.date(from: value) {
    return date
  }

  let localFormatter = DateFormatter()
  localFormatter.locale = Locale(identifier: "en_US_POSIX")
  localFormatter.calendar = Calendar(identifier: .gregorian)
  localFormatter.timeZone = .current
  localFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

  let localDateComponents = value.split(
    separator: ".",
    maxSplits: 1,
    omittingEmptySubsequences: false
  )
  guard let date = localFormatter.date(from: String(localDateComponents[0])) else {
    throw ChatDTOError.invalidDate(value)
  }

  guard localDateComponents.count == 2 else {
    return date
  }

  let fractionalDigits = localDateComponents[1].prefix { $0.isNumber }
  guard !fractionalDigits.isEmpty,
        let fractionalSeconds = Double("0.\(fractionalDigits)") else {
    throw ChatDTOError.invalidDate(value)
  }

  return date.addingTimeInterval(fractionalSeconds)
}

enum ChatDTOError: LocalizedError {
  case invalidDate(String)

  var errorDescription: String? {
    switch self {
    case .invalidDate:
      return "채팅 응답의 날짜 형식이 올바르지 않습니다."
    }
  }
}
