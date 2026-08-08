//
//  ChatRoom.swift
//  BookBetween
//
//  Created by 한지민 on 8/1/26.
//

import Foundation

struct ChatRoom {
  let chatroomId: Int
  let meetingId: Int
  let bookTitle: String
  let status: String
  let startsAt: Date
  let endsAt: Date
  let maxParticipants: Int
  let participants: ChatParticipants
  let myMemberId: Int
  let currentQuestion: ChatQuestion?
  let maxQuestions: Int
  let vote: ChatVote
  let messages: [ChatMessage]
}

struct ChatParticipants {
  let applied: Int
  let connected: Int
}

struct ChatQuestion {
  private enum Ordinal {
    static let names = ["첫번째", "두번째", "세번째", "네번째", "다섯번째"]
  }

  let questionId: Int
  let questionOrder: Int
  let content: String

  var orderText: String {
    guard self.questionOrder >= 1, self.questionOrder <= Ordinal.names.count else {
      return "\(self.questionOrder)번째"
    }
    return Ordinal.names[self.questionOrder - 1]
  }
}

struct ChatVote {
  let currentVotes: Int
  let requiredVotes: Int
  let voted: Bool
}
