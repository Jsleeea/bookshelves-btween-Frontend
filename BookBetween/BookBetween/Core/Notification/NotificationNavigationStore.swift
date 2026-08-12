//
//  NotificationNavigationStore.swift
//  BookBetween
//

import Foundation
import Observation

@Observable
final class NotificationNavigationStore {
    private(set) var inboxRequestID: UUID?

    func requestInbox() {
        inboxRequestID = UUID()
    }

    func markInboxRequestHandled(_ requestID: UUID) {
        guard inboxRequestID == requestID else {
            return
        }

        inboxRequestID = nil
    }
}
