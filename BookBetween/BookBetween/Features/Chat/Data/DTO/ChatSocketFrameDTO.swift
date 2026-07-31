//
//  ChatSocketFrameDTO.swift
//  BookBetween
//
//  Created by 한지민 on 8/1/26.
//

import Foundation

struct ChatSocketFrameEnvelopeDTO: Decodable {
  let type: String
}

struct ChatSocketMessageFrameDTO: Decodable {
  let data: ChatMessageDTO
}

struct ChatSocketQuestionFrameDTO: Decodable {
  let data: ChatSocketQuestionDataDTO
}

struct ChatSocketQuestionDataDTO: Decodable {
  let questionId: Int
  let questionOrder: Int
  let content: String
  let maxQuestions: Int
}

struct ChatSocketVoteCountFrameDTO: Decodable {
  let data: ChatSocketVoteCountDataDTO
}

struct ChatSocketVoteCountDataDTO: Decodable {
  let currentVotes: Int
  let requiredVotes: Int
}

struct ChatSocketParticipantFrameDTO: Decodable {
  let data: ChatSocketParticipantDataDTO
}

struct ChatSocketParticipantDataDTO: Decodable {
  let event: String
  let nickname: String
  let connected: Int
  let requiredVotes: Int
  let currentVotes: Int
}

struct ChatSocketSystemFrameDTO: Decodable {
  let data: ChatSocketSystemDataDTO
}

struct ChatSocketSystemDataDTO: Decodable {
  let event: String
}

enum ChatSocketFrameDecoder {
  static func decode(_ data: Data) throws -> ChatSocketEvent {
    let decoder = JSONDecoder()
    let envelope = try decoder.decode(ChatSocketFrameEnvelopeDTO.self, from: data)

    switch envelope.type {
    case "MESSAGE":
      let frame = try decoder.decode(ChatSocketMessageFrameDTO.self, from: data)
      return .message(try frame.data.toDomain())

    case "QUESTION":
      let frame = try decoder.decode(ChatSocketQuestionFrameDTO.self, from: data)
      return .question(
        ChatQuestion(
          questionId: frame.data.questionId,
          questionOrder: frame.data.questionOrder,
          content: frame.data.content
        ),
        maxQuestions: frame.data.maxQuestions
      )

    case "VOTE_COUNT":
      let frame = try decoder.decode(ChatSocketVoteCountFrameDTO.self, from: data)
      return .voteCount(
        currentVotes: frame.data.currentVotes,
        requiredVotes: frame.data.requiredVotes
      )

    case "PARTICIPANT":
      let frame = try decoder.decode(ChatSocketParticipantFrameDTO.self, from: data)
      guard let eventType = ChatParticipantEventType(rawValue: frame.data.event) else {
        throw ChatSocketFrameError.invalidParticipantEvent(frame.data.event)
      }
      return .participant(
        ChatParticipantUpdate(
          event: eventType,
          nickname: frame.data.nickname,
          connected: frame.data.connected,
          requiredVotes: frame.data.requiredVotes,
          currentVotes: frame.data.currentVotes
        )
      )

    case "SYSTEM":
      return .meetingEnded

    default:
      throw ChatSocketFrameError.unknownType(envelope.type)
    }
  }
}

enum ChatSocketFrameError: LocalizedError {
  case unknownType(String)
  case invalidParticipantEvent(String)

  var errorDescription: String? {
    switch self {
    case .unknownType(let type):
      return "알 수 없는 채팅 프레임 타입입니다: \(type)"
    case .invalidParticipantEvent(let event):
      return "알 수 없는 참여자 이벤트입니다: \(event)"
    }
  }
}
