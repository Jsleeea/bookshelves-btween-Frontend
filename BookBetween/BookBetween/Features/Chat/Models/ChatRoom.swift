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
  let questionId: Int
  let questionOrder: Int
  let content: String
}

struct ChatVote {
  let currentVotes: Int
  let requiredVotes: Int
  let voted: Bool
}
