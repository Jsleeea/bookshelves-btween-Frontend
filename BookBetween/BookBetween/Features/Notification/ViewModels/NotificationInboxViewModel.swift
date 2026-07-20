//
//  NotificationInboxViewModel.swift
//  BookBetween
//

import Foundation
import Observation

@Observable
@MainActor
final class NotificationInboxViewModel {
    private(set) var notifications: [NotificationItem]

    var isEmpty: Bool {
        notifications.isEmpty
    }

    init() {
        self.notifications = [
            NotificationItem(
                id: 1,
                type: .meetingCancelled,
                title: "최소 인원 미달로 모임이 취소되었어요",
                message: "혼모노 | 7/15 (수) · 18:30 | 2/6",
                isActionable: false
            ),
            NotificationItem(
                id: 2,
                type: .aiSummaryReady,
                title: "AI 요약이 완료되었어요",
                message: "지금 확인해보세요",
                isActionable: true
            ),
            NotificationItem(
                id: 3,
                type: .meetingStarted,
                title: "혼모노 독서 모임이 시작되었어요",
                message: "지금 모임에 참여해보세요",
                isActionable: true
            )
        ]
    }

    init(notifications: [NotificationItem]) {
        self.notifications = notifications
    }
}
