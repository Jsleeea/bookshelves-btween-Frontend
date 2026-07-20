//
//  NotificationItem.swift
//  BookBetween
//

import Foundation

struct NotificationItem: Identifiable {
    let id: Int
    let type: NotificationType
    let title: String
    let message: String
    let isActionable: Bool
}

enum NotificationType {
    case meetingCancelled
    case aiSummaryReady
    case meetingStarted
}
