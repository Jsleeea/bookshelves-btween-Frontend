//
//  ChatStubData.swift
//  BookBetween
//
//  Created by 한지민 on 8/1/26.
//

import Foundation

enum ChatStubData {
  static func data(for endpoint: ChatTarget.Endpoint) -> Data {
    let json: String

    switch endpoint {
    case .fetchChatRoom(let chatroomId):
      json = fetchChatRoomResponse(chatroomId: chatroomId)
    case .reportChatRoom(let chatroomId):
      json = reportChatRoomResponse(chatroomId: chatroomId)
    case .voteForNewQuestion:
      json = voteForNewQuestionResponse
    }

    return Data(json.utf8)
  }

  private static func fetchChatRoomResponse(chatroomId: Int) -> String {
    """
    {
      "isSuccess": true,
      "code": "CHAT200_1",
      "message": "채팅방 입장에 성공했습니다.",
      "result": {
        "chatroomId": \(chatroomId),
        "meetingId": 10,
        "bookTitle": "소년이 온다",
        "status": "IN_PROGRESS",
        "startsAt": "2026-07-15T19:00:00+09:00",
        "endsAt": "2026-07-15T19:30:00+09:00",
        "maxParticipants": 6,
        "participants": {
          "applied": 6,
          "connected": 4
        },
        "myMemberId": 21,
        "currentQuestion": {
          "questionId": 7,
          "questionOrder": 2,
          "content": "작품의 주제의식은 무엇이라고 생각하나요?"
        },
        "maxQuestions": 5,
        "vote": {
          "currentVotes": 1,
          "requiredVotes": 2,
          "voted": false
        },
        "messages": [
          {
            "messageId": 153,
            "senderMemberId": 18,
            "senderNickname": "꾸벅이는 고양이",
            "content": "다들 어느 장면이 기억에 남으세요?",
            "createdAt": "2026-07-15T19:11:40+09:00"
          },
          {
            "messageId": 154,
            "senderMemberId": 21,
            "senderNickname": "책 먹는 여우",
            "content": "저는 2부가 제일 인상 깊었어요",
            "createdAt": "2026-07-15T19:12:03+09:00"
          }
        ]
      }
    }
    """
  }

  private static func reportChatRoomResponse(chatroomId: Int) -> String {
    """
    {
      "isSuccess": true,
      "code": "REPORT201_1",
      "message": "신고가 접수되었습니다.",
      "result": {
        "id": 1,
        "chatroomId": \(chatroomId),
        "status": "PENDING",
        "createdAt": "2026-07-05T21:00:00"
      }
    }
    """
  }

  private static let voteForNewQuestionResponse = """
  {
    "isSuccess": true,
    "code": "AI200",
    "message": "질문 생성 투표가 반영되었습니다.",
    "result": {
      "currentVotes": 2,
      "requiredVotes": 3,
      "triggered": false
    }
  }
  """
}
