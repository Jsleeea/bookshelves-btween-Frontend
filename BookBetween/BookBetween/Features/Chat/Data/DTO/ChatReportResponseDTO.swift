//
//  ChatReportResponseDTO.swift
//  BookBetween
//
//  Created by 한지민 on 8/1/26.
//

import Foundation

struct ChatReportResultDTO: Decodable {
  let id: Int
  let chatroomId: Int
  let status: String
  let createdAt: String
}

extension ChatReportResultDTO {
  func toDomain() throws -> ChatReport {
    ChatReport(
      reportId: id,
      chatroomId: chatroomId,
      status: status,
      createdAt: try parseChatAPIDate(createdAt)
    )
  }
}
