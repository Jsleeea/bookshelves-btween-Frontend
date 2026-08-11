//
//  ActiveChatSession.swift
//  BookBetween
//

import Observation

@MainActor
@Observable
final class ActiveChatSession {
  static let shared = ActiveChatSession()

  var activeMeetingId: Int?

  private init() {}
}
