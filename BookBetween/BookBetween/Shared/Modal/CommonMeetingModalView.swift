import SwiftUI

enum MeetingEventModalType {
    case started
    case ended
    case summaryCompleted
}

struct MeetingEventModalView: View {
    let type: MeetingEventModalType
    let meeting: BookMeeting
    var onClose: (() -> Void)?
    var onPrimaryAction: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            topIcon
                .padding(.top, 24.5)

            titleSection
                .padding(.top, type == .ended ? -20.03 : -7.681)

            meetingCard
                .padding(.top, type == .ended ? 16 : 12)

            primaryButton
                .padding(.top, type == .ended ? 16 : 12)
        }
        .padding(.horizontal, type == .ended ? 20 : 30)
        .padding(.bottom, type == .ended ? 20 : 24.5)
        .frame(width: 300, height: type == .ended ? 350 : 340)
        .background { modalBackground }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay { borderOverlay }
        .overlay(alignment: .top) {
            if type != .ended, let onClose {
                closeButton(action: onClose)
            }
        }
        .shadow(color: Color(hex: "2B2A28").opacity(0.16), radius: 24, x: 0, y: 20)
    }

    // MARK: - topIcon

    private var topIcon: some View {
        let imageName = type == .ended ? "icon_check_mark" : "icon_alert_mark"
        let iconHeight: CGFloat = type == .ended ? 44 : 54.362

        return Image(imageName)
            .resizable()
            .scaledToFit()
            .frame(width: 50, height: iconHeight)
            .shadow(color: Color(hex: "205130").opacity(0.2), radius: 2, x: -4, y: 4)
            .offset(y: -3)
            .frame(width: 120, height: 120)
            .background {
                RadialGradient(
                    stops: [
                        .init(color: Color.green50.opacity(0.5), location: 0.51),
                        .init(color: Color.white.opacity(0), location: 1.0)
                    ],
                    center: UnitPoint(x: 0.5, y: 0.46875),
                    startRadius: 0,
                    endRadius: 70
                )
                .frame(width: 160, height: 160)
            }
    }

    // MARK: - titleSection

    @ViewBuilder
    private var titleSection: some View {
        switch type {
        case .started:
            VStack(spacing: 4) {
                Text("독서모임이 시작되었습니다.")
                    .head3Style
                    .foregroundStyle(Color.green900)
                    .multilineTextAlignment(.center)

                Text("지금 참여하여 함께 이야기를 나눠보세요.")
                    .body2SemiBoldStyle
                    .foregroundStyle(Color.gray500)
                    .multilineTextAlignment(.center)
            }

        case .ended:
            VStack(spacing: 8) {
                Text("독서모임이 종료되었습니다")
                    .head3Style
                    .tracking(-0.054)
                    .lineSpacing(2)
                    .foregroundStyle(Color.green900)
                    .multilineTextAlignment(.center)

                VStack(spacing: 4) {
                    Text("모임 종료 후 모든 대화 내용이 삭제됩니다")
                        .body2SemiBoldStyle
                        .tracking(-0.042)
                        .lineSpacing(6)
                        .foregroundStyle(Color.gray500)
                        .multilineTextAlignment(.center)

                    Text("모임 내용은 AI가 요약하여 알려드릴게요")
                        .body2SemiBoldStyle
                        .tracking(-0.042)
                        .lineSpacing(6)
                        .foregroundStyle(Color.gray500)
                        .multilineTextAlignment(.center)
                }
            }

        case .summaryCompleted:
            VStack(spacing: 4) {
                Text("대화 요약이 완료되었습니다")
                    .head3Style
                    .foregroundStyle(Color.green900)
                    .multilineTextAlignment(.center)

                Text("지금 이동하여 AI요약을 확인해보세요")
                    .body2SemiBoldStyle
                    .foregroundStyle(Color.gray500)
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - meetingCard

    private var meetingCard: some View {
        HStack(alignment: .center, spacing: 12) {
            BookCoverImage(book: meeting.book, placeholderImageName: "book_cover_mock")
                .aspectRatio(40.476 / 59.389, contentMode: .fill)
                .frame(width: 40.476, height: 59.389)
                .clipShape(RoundedRectangle(cornerRadius: 5.569))
                .padding(.leading, 24)
                .padding(.top, 6.81)
                .padding(.bottom, 6.86)

            VStack(alignment: .leading, spacing: 0) {
                Text(meeting.book.title)
                    .body2SemiBoldStyle
                    .foregroundStyle(Color.gray800)
                    .lineLimit(1)
                    .padding(.top, 9)

                Text(meeting.book.author)
                    .caption1RegularStyle
                    .foregroundStyle(Color.gray500)
                    .padding(.top, 4)
                    .padding(.bottom, 2)

                infoRow
                    .padding(.top, 1.99)
            }
            .padding(.bottom, 9.87)

            Spacer()
        }
        .frame(width: 240, height: 73.059)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 7.016))
        .overlay {
            RoundedRectangle(cornerRadius: 7.016)
                .stroke(Color.gray300, lineWidth: 0.292)
        }
    }

    private var infoRow: some View {
        HStack(spacing: 3.694) {
            Image("icon_calendar")
                .resizable()
                .scaledToFill()
                .frame(width: 9.605, height: 9.605)
                .clipped()

            Text(meetingDateText)
                .font(.pretend(type: .regular, size: 8.866))
                .tracking(-0.027)
                .lineSpacing(5.911)

            Image("icon_divider")
                .resizable()
                .frame(width: 0.739, height: 8)

            Image("icon_group")
                .resizable()
                .scaledToFill()
                .frame(width: 8.127, height: 7.388)
                .clipped()

            Text("\(meeting.currentParticipants)/\(meeting.maxParticipants)")
                .font(.pretend(type: .regular, size: 8.866))
                .tracking(-0.027)
                .lineSpacing(5.911)
        }
        .foregroundStyle(Color.gray600)
    }

    // MARK: - primaryButton

    private var primaryButton: some View {
        Button(action: onPrimaryAction) {
            Text(primaryButtonTitle)
                .body1SemiBoldStyle
                .foregroundStyle(Color.beige100)
                .frame(width: 240, height: 40)
                .background(Color.green600)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var primaryButtonTitle: String {
        switch type {
        case .started: return "참여하기"
        case .ended: return "홈으로 이동"
        case .summaryCompleted: return "확인하기"
        }
    }

    // MARK: - closeButton

    private func closeButton(action: @escaping () -> Void) -> some View {
        HStack {
            Spacer()
            Button(action: action) {
                Image("close_icon")
                    .resizable()
                    .frame(width: 15, height: 15)
                    .foregroundStyle(Color.green900)
            }
            .padding(.horizontal, 11)
        }
        .padding(.top, 16)
    }

    // MARK: - Common Styling

    private var modalBackground: some View {
        LinearGradient(
            stops: [
                .init(color: .white, location: 0.8367),
                .init(color: Color.white.opacity(0.2), location: 1.5517)
            ],
            startPoint: .bottom,
            endPoint: .top
        )
    }

    private var borderOverlay: some View {
        RoundedRectangle(cornerRadius: 12)
            .strokeBorder(
                LinearGradient(
                    stops: [
                        .init(color: Color.white.opacity(0.2), location: 0.2499),
                        .init(color: .white, location: 0.8197)
                    ],
                    startPoint: UnitPoint(x: 0.967, y: 0.321),
                    endPoint: UnitPoint(x: 0.033, y: 0.679)
                ),
                lineWidth: 1.5
            )
    }

    // MARK: - Helpers

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "MM/dd · HH:mm"
        return formatter
    }()

    private var meetingDateText: String {
        Self.dateFormatter.string(from: meeting.meetingDate)
    }
}

// MARK: - Environment Key

private struct ShowSummaryCompletedKey: EnvironmentKey {
    static let defaultValue: (BookMeeting) -> Void = { _ in }
}

extension EnvironmentValues {
    var showSummaryCompleted: (BookMeeting) -> Void {
        get { self[ShowSummaryCompletedKey.self] }
        set { self[ShowSummaryCompletedKey.self] = newValue }
    }
}

#Preview("모임 시작") {
    MeetingEventModalView(
        type: .started,
        meeting: BookMeeting(
            id: 1,
            book: Book(id: 1, title: "혼모노", author: "성해나"),
            meetingDate: Calendar.current.date(from: DateComponents(year: 2026, month: 6, day: 20, hour: 6)) ?? Date(),
            timerMinutes: 30,
            maxParticipants: 6,
            currentParticipants: 4,
            status: .inProgress
        ),
        onClose: {},
        onPrimaryAction: {}
    )
    .padding(.horizontal, 24)
}

#Preview("모임 종료") {
    MeetingEventModalView(
        type: .ended,
        meeting: BookMeeting(
            id: 1,
            book: Book(id: 1, title: "혼모노", author: "성해나"),
            meetingDate: Calendar.current.date(from: DateComponents(year: 2026, month: 6, day: 20, hour: 6)) ?? Date(),
            timerMinutes: 30,
            maxParticipants: 6,
            currentParticipants: 4,
            status: .completed
        ),
        onPrimaryAction: {}
    )
    .padding(.horizontal, 24)
}

#Preview("요약 완료") {
    MeetingEventModalView(
        type: .summaryCompleted,
        meeting: BookMeeting(
            id: 1,
            book: Book(id: 1, title: "혼모노", author: "성해나"),
            meetingDate: Calendar.current.date(from: DateComponents(year: 2026, month: 6, day: 20, hour: 6)) ?? Date(),
            timerMinutes: 30,
            maxParticipants: 6,
            currentParticipants: 4,
            status: .completed
        ),
        onClose: {},
        onPrimaryAction: {}
    )
    .padding(.horizontal, 24)
}
