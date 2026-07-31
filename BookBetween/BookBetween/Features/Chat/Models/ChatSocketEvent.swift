//
//  ChatSocketEvent.swift
//  BookBetween
//
//  Created by 한지민 on 8/1/26.
//

enum ChatSocketEvent {
  case message(ChatMessage)
  case question(ChatQuestion, maxQuestions: Int)
  case voteCount(currentVotes: Int, requiredVotes: Int)
  case participant(ChatParticipantUpdate)
  case meetingEnded
}

struct ChatParticipantUpdate {
  let event: ChatParticipantEventType
  let nickname: String
  let connected: Int
  let requiredVotes: Int
  let currentVotes: Int
}

enum ChatParticipantEventType: String {
  case joined = "JOINED"
  case left = "LEFT"
}
