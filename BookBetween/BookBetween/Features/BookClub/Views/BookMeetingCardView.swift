import SwiftUI

struct BookMeetingCardView: View {
	let meeting: BookMeeting
    let service: (any MeetingServiceProtocol)?
    let isParticipant: Bool
    let onParticipated: (() -> Void)?
    let onCompletedNavigate: ((BookMeeting) -> Void)?
    let onFetchError: (() -> Void)?
    let onSummaryPending: (() -> Void)?
    @State private var isFetching = false

    init(
        meeting: BookMeeting,
        service: (any MeetingServiceProtocol)? = nil,
        isParticipant: Bool = false,
        onParticipated: (() -> Void)? = nil,
        onCompletedNavigate: ((BookMeeting) -> Void)? = nil,
        onFetchError: (() -> Void)? = nil,
        onSummaryPending: (() -> Void)? = nil
    ) {
        self.meeting = meeting
        self.service = service
        self.isParticipant = isParticipant
        self.onParticipated = onParticipated
        self.onCompletedNavigate = onCompletedNavigate
        self.onFetchError = onFetchError
        self.onSummaryPending = onSummaryPending
    }

	var body: some View {
		ZStack {
			HStack(alignment: .center, spacing: 20) {
				bookCover

				VStack(alignment: .leading, spacing: 4) {
					statusBadge

					Text(meeting.book.title)
						.head3Style
						.lineLimit(1)
						.foregroundStyle(Color.gray800)

					infoRow
				}

				Spacer()
			}

			VStack {
				HStack {
					Spacer()
					moreButtonLabel
				}
				Spacer()
			}
			.padding(.top, 11)
			.padding(.trailing, 19.86)

			if meeting.status == .completed {
				Color.clear
					.contentShape(Rectangle())
					.onTapGesture {
						guard !isFetching else { return }
						Task { await fetchAndNavigate() }
					}
			} else {
				NavigationLink(value: routeValue) {
					Color.clear
				}
			}
		}
		.padding(.leading, 22)
		.background(.white)
		.clipShape(RoundedRectangle(cornerRadius: 12))
		.overlay {
			RoundedRectangle(cornerRadius: 12)
				.stroke(Color.gray200, lineWidth: 0.5)
		}
		.padding(.horizontal, 19)
		.frame(height: 110)
	}

    // MARK: - bookCover

	private var bookCover: some View {
		BookCoverImage(book: meeting.book, placeholderImageName: "book_cover_mock")
            .frame(width: 86.0 * 29.0 / 44.0, height: 86)
            .clipped()
			.clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray200, lineWidth: 0.5)
            }
	}

	// MARK: - statusBadge

	private var statusBadge: some View {
		Text(meeting.status.title)
			.caption2SemiBoldStyle
			.foregroundStyle(badgeForegroundColor)
            .padding(.vertical, 1.5)
			.padding(.horizontal, 6)
			.background(badgeBackgroundColor)
			.clipShape(Capsule())
	}

	private var badgeForegroundColor: Color {
		switch meeting.status {
        case .recruiting:  return Color.blue600
		case .upcoming:    return Color.green800
        case .inProgress:  return Color.red01
		case .completed:   return Color.gray600
		}
	}

	private var badgeBackgroundColor: Color {
		switch meeting.status {
        case .recruiting:  return Color.blue01
		case .upcoming:    return Color.green50
        case .inProgress:  return Color.red50
		case .completed:   return Color.gray200
		}
	}

    // MARK: - infoRow

	private var infoRow: some View {
		HStack(spacing: 0) {
			Image("icon_calendar")
                .resizable()
                .scaledToFill()
                .frame(width: 13, height: 13)
                .clipped()
                .padding(.trailing, 4)

			Text(meetingDateText)
				.caption1RegularStyle
                .padding(.trailing, 8)

			separator
                .padding(.trailing, 8)

			Image("icon_group")
                .resizable()
                .scaledToFill()
                .frame(width: 11, height: 11)
                .clipped()
                .padding(.trailing, 4)

			Text("\(meeting.currentParticipants)/\(meeting.maxParticipants)")
				.caption1RegularStyle
                .padding(.trailing, 8)

			separator
                .padding(.trailing, 8)

			Image("icon_clock")
                .resizable()
                .scaledToFill()
                .frame(width: 11, height: 11)
                .clipped()
                .padding(.trailing, 4)

			Text("\(meeting.timerMinutes)분")
				.caption1RegularStyle

		}
		.foregroundStyle(Color.gray600)
	}

	private var separator: some View {
		Text("|")
			.caption1RegularStyle
			.foregroundStyle(Color.gray600)
	}

    // MARK: - moreButtonLabel

    private var moreButtonLabel: some View {
        HStack(spacing: 4) {
            Text("더보기")
                .caption2RegularStyle

            Image("icon_chevron_right_gray")
                .resizable()
                .scaledToFill()
                .frame(width: 4, height: 8)
                .clipped()
        }
        .foregroundStyle(Color.gray600)
    }

    private var routeValue: BookClubRoute {
        switch meeting.status {
        case .inProgress:
            return .chat(chatroomId: meeting.chatroomId, meetingId: meeting.id)
        default:
            return .detail(meeting, isParticipant: isParticipant)
        }
    }

    // MARK: - Completed Meeting Fetch

    private func fetchAndNavigate() async {
        guard let service else {
            onCompletedNavigate?(meeting)
            return
        }
        isFetching = true
        defer { isFetching = false }
        do {
            let detail = try await service.fetchMeetingDetail(meetingId: meeting.id)
            if detail.meetingSummary == nil {
                onSummaryPending?()
            } else {
                onCompletedNavigate?(detail)
            }
        } catch {
            onFetchError?()
        }
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

#Preview {
	NavigationStack {
		VStack(spacing: 12) {
            BookMeetingCardView(
                meeting: BookMeeting(
                    id: 2,
                    book: Book(
                        id: 2,
                        title: "프로젝트 헤일메리",
                        author: "앤디 위어",
                        description: nil
                    ),
                    title: nil,
                    description: "",
                    recruitmentStartDate: Date(),
                    recruitmentEndDate: Date(),
                    readingStartDate: Date(),
                    readingEndDate: Date(),
                    meetingDate: Calendar.current.date(from: DateComponents(year: 2026, month: 6, day: 20, hour: 6)) ?? Date(),
                    timerMinutes: 35,
                    maxParticipants: 6,
                    currentParticipants: 3,
                    status: .upcoming
                )
            )
			BookMeetingCardView(
				meeting: BookMeeting(
					id: 1,
					book: Book(
						id: 1,
						title: "빛은 얼마나 깊이 스미는가",
						author: "김초엽",
						description: nil
					),
					title: nil,
					description: "",
					recruitmentStartDate: Date(),
					recruitmentEndDate: Date(),
					readingStartDate: Date(),
					readingEndDate: Date(),
					meetingDate: Calendar.current.date(from: DateComponents(year: 2026, month: 6, day: 19, hour: 21)) ?? Date(),
					timerMinutes: 45,
					maxParticipants: 6,
					currentParticipants: 3,
					status: .completed
				)
			)
		}
	}
}
