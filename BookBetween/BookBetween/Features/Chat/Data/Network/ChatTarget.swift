//
//  ChatTarget.swift
//  BookBetween
//
//  Created by 한지민 on 8/1/26.
//

import Foundation
import Alamofire
import Moya

struct ChatTarget: TargetType {
  enum Endpoint {
    case fetchChatRoom(chatroomId: Int)
    case reportChatRoom(chatroomId: Int)
    case voteForNewQuestion(meetingId: Int)
  }

  let baseURL: URL
  let endpoint: Endpoint

  var path: String {
    switch endpoint {
    case .fetchChatRoom(let chatroomId):
      return "/api/v1/chatrooms/\(chatroomId)"
    case .reportChatRoom:
      return "/api/v1/reports"
    case .voteForNewQuestion(let meetingId):
      return "/api/v1/meetings/\(meetingId)/question-votes"
    }
  }

  var method: Moya.Method {
    switch endpoint {
    case .fetchChatRoom:
      return .get
    case .reportChatRoom, .voteForNewQuestion:
      return .post
    }
  }

  var task: Moya.Task {
    switch endpoint {
    case .fetchChatRoom, .voteForNewQuestion:
      return .requestPlain
    case .reportChatRoom(let chatroomId):
      return .requestParameters(
        parameters: ["chatroomId": chatroomId],
        encoding: JSONEncoding.default
      )
    }
  }

  var headers: [String: String]? {
    [
      "Accept": "application/json",
      "Content-Type": "application/json"
    ]
  }

  var sampleData: Data {
    ChatStubData.data(for: endpoint)
  }
}
