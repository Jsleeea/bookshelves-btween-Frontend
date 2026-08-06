//
//  NotificationItem.swift
//  BookBetween
//

import Foundation

struct NotificationItem: Identifiable, Equatable {
    let id: Int
    let type: NotificationType
    let title: String
    let message: String
    let isActionable: Bool
    let isRead: Bool
    let targetId: Int?
    let createdAt: Date

    init(
        id: Int,
        type: NotificationType,
        title: String,
        message: String,
        isActionable: Bool,
        isRead: Bool = false,
        targetId: Int? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.message = message
        self.isActionable = isActionable
        self.isRead = isRead
        self.targetId = targetId
        self.createdAt = createdAt
    }

    func markingAsRead() -> NotificationItem {
        NotificationItem(
            id: id,
            type: type,
            title: title,
            message: message,
            isActionable: isActionable,
            isRead: true,
            targetId: targetId,
            createdAt: createdAt
        )
    }
}

enum NotificationType: Equatable {
    case meetingCancelled
    case aiSummaryReady
    case meetingStarted
    case system

    init(apiValue: String) {
        switch apiValue {
        case "MEETING_CANCELED", "MEETING_CANCELLED":
            self = .meetingCancelled
        case "MEETING_SUMMARY_DONE":
            self = .aiSummaryReady
        case "MEETING_STARTED":
            self = .meetingStarted
        case "SYSTEM":
            self = .system
        default:
            self = .system
        }
    }
}

extension NotificationItem {
    static let meetingStartedSuffix = "독서 모임이 시작되었어요"
    /// 카드에 노출하는 고정 문구. 서버가 실제로 내려주는 원문 문구와는 다를 수 있다.
    static let aiSummaryReadySuffix = "AI 요약이 완료되었어요"
    /// 서버가 내려주는 원문 title의 접미사("{책 제목} 모임 요약이 준비되었어요").
    /// 책 제목 파싱에만 사용하고, 화면에는 aiSummaryReadySuffix를 노출한다.
    private static let aiSummaryReadyRawSuffix = "모임 요약이 준비되었어요"

    var displayTitle: String {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)

        switch type {
        case .meetingCancelled:
            return "최소 인원 미달로 모임이 취소되었어요"
        case .aiSummaryReady:
            guard let bookTitle = aiSummaryBookTitle else {
                return Self.aiSummaryReadySuffix
            }
            return "\(bookTitle) \(Self.aiSummaryReadySuffix)"
        case .meetingStarted:
            let genericTitles = [
                "",
                "모임이 곧 시작됩니다.",
                "모임이 시작되었습니다.",
                "모임이 시작되었어요"
            ]
            return genericTitles.contains(trimmedTitle)
                ? Self.meetingStartedSuffix
                : trimmedTitle
        case .system:
            return trimmedTitle
        }
    }

    /// "{책 제목} 독서 모임이 시작되었어요" 형식에서 책 제목만 추출.
    /// 책 제목을 알 수 없는 경우(제네릭 문구, 다른 알림 타입 등) nil.
    var meetingStartedBookTitle: String? {
        guard type == .meetingStarted else { return nil }

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedTitle.hasSuffix(Self.meetingStartedSuffix) else { return nil }

        let bookTitle = String(trimmedTitle.dropLast(Self.meetingStartedSuffix.count))
            .trimmingCharacters(in: .whitespaces)

        return bookTitle.isEmpty ? nil : bookTitle
    }

    /// 서버 원문 title("{책 제목} 모임 요약이 준비되었어요")에서 책 제목만 추출.
    /// 책 제목을 알 수 없는 경우(제네릭 문구, 다른 알림 타입 등) nil.
    var aiSummaryBookTitle: String? {
        guard type == .aiSummaryReady else { return nil }

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedTitle.hasSuffix(Self.aiSummaryReadyRawSuffix) else { return nil }

        let bookTitle = String(trimmedTitle.dropLast(Self.aiSummaryReadyRawSuffix.count))
            .trimmingCharacters(in: .whitespaces)

        return bookTitle.isEmpty ? nil : bookTitle
    }

    var displayMessage: String {
        switch type {
        case .aiSummaryReady:
            return "지금 확인해보세요"
        case .meetingStarted:
            return "지금 모임에 참여해보세요"
        case .meetingCancelled, .system:
            return message.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
}

struct NotificationPage: Equatable {
    let notifications: [NotificationItem]
    let page: Int
    let size: Int
    let hasNext: Bool
}

struct NewNotificationBatch: Equatable {
    let notifications: [NotificationItem]
    let nextCursor: Int
    let hasNext: Bool
}
