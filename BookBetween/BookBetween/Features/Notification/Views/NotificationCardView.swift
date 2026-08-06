//
//  NotificationCardView.swift
//  BookBetween
//

import SwiftUI

struct NotificationCardView: View {
    let item: NotificationItem

    var body: some View {
        HStack(spacing: 12) {
            notificationIcon

            VStack(alignment: .leading, spacing: 5) {
                titleText

                Text(item.displayMessage)
                    .caption1RegularStyle
                    .foregroundStyle(.gray500)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if item.isActionable {
                Image("icon_notification_chevron_right")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 7, height: 14)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity, minHeight: 88)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(.gray200, lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var titleText: some View {
        if let bookTitle = item.meetingStartedBookTitle ?? item.aiSummaryBookTitle {
            ViewThatFits(in: .horizontal) {
                Text(item.displayTitle)
                    .font(.body1SemiBold)
                    .tracking(0)
                    .foregroundStyle(.gray800)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)

                VStack(alignment: .leading, spacing: 1.5) {
                    Text(bookTitle)
                        .font(.body1SemiBold)
                        .tracking(0)
                        .foregroundStyle(.gray800)
                        .lineLimit(1)
                        .truncationMode(.tail)

                    Text(titleSuffix)
                        .font(.body1SemiBold)
                        .tracking(0)
                        .foregroundStyle(.gray800)
                        .lineLimit(1)
                }
            }
        } else {
            Text(item.displayTitle)
                .font(.body1SemiBold)
                .tracking(0)
                .foregroundStyle(.gray800)
                .lineSpacing(1.5)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var titleSuffix: String {
        switch item.type {
        case .meetingStarted:
            return NotificationItem.meetingStartedSuffix
        case .aiSummaryReady:
            return NotificationItem.aiSummaryReadySuffix
        case .meetingCancelled, .system:
            return item.displayTitle
        }
    }

    private var notificationIcon: some View {
        ZStack {
            Circle()
                .fill(.white)
                .shadow(color: .black.opacity(0.12), radius: 5, x: 0, y: 4)

            Image(iconImageName)
                .resizable()
                .scaledToFit()
                .frame(width: iconSize.width, height: iconSize.height)
        }
        .frame(width: 50, height: 50)
    }

    private var iconImageName: String {
        switch item.type {
        case .meetingCancelled:
            return "icon_exclamation_mark"
        case .aiSummaryReady:
            return "icon_check_mark"
        case .meetingStarted:
            return "icon_alert_mark"
        case .system:
            return "icon_alert_mark"
        }
    }

    private var iconSize: CGSize {
        switch item.type {
        case .meetingCancelled:
            return CGSize(width: 26, height: 26)
        case .aiSummaryReady:
            return CGSize(width: 28, height: 23)
        case .meetingStarted:
            return CGSize(width: 25, height: 27)
        case .system:
            return CGSize(width: 25, height: 27)
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        NotificationCardView(
            item: NotificationItem(
                id: 1,
                type: .meetingCancelled,
                title: "최소 인원 미달로 모임이 취소되었어요",
                message: "혼모노 | 7/15 (수) · 18:30 | 2/6",
                isActionable: false
            )
        )

        NotificationCardView(
            item: NotificationItem(
                id: 2,
                type: .aiSummaryReady,
                title: "혼모노 모임 요약이 준비되었어요",
                message: "지금 확인해보세요",
                isActionable: true
            )
        )
        NotificationCardView(
            item: NotificationItem(
                id: 3,
                type: .meetingStarted,
                title: "저는 남자고 임신을 했습니다 독서 모임이 시작되었어요",
                message: "지금 모임에 참여해보세요",
                    isActionable: true
            )
        )

        NotificationCardView(
            item: NotificationItem(
                id: 4,
                type: .meetingStarted,
                title: "혼모노 독서 모임이 시작되었어요",
                message: "지금 모임에 참여해보세요",
                isActionable: true
            )
        )
    }
    .padding(20)
    .background(.gray50)
}
