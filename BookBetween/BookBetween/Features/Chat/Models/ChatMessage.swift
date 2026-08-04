//
//  ChatMessage.swift
//  BookBetween
//
//  Created by 한지민 on 8/1/26.
//

import Foundation

struct ChatMessage: Identifiable {
  let messageId: Int
  let senderMemberId: Int
  let senderNickname: String
  let content: String
  let createdAt: Date

  var id: Int { messageId }
}
