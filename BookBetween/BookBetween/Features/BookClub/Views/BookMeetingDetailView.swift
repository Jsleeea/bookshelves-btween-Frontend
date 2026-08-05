import SwiftUI

struct BookMeetingDetailView: View {
    @Environment(\.dismiss) private var dismiss

    private let service: (any MeetingServiceProtocol)?
    private let isParticipant: Bool
    private let onParticipated: (() -> Void)?
    @State private var meeting: BookMeeting
    @State private var isParticipating = false
    @State private var participationError: String?
    @State private var meetingDismissed = false
    @State private var showSuccessModal = false

    init(meeting: BookMeeting, service: (any MeetingServiceProtocol)? = nil, isParticipant: Bool = false, onParticipated: (() -> Void)? = nil) {
        self._meeting = State(initialValue: meeting)
        self.service = service
        self.isParticipant = isParticipant
        self.onParticipated = onParticipated
    }

	var body: some View {
		ZStack {
            Color.beige100.ignoresSafeArea()
			if !isParticipant {
				leafDecoration
			}
			VStack(spacing: 0) {
				navigationHeader
                    .padding(.top, 8)
                    .padding(.bottom, 7)
				subtitleHeader
                    .padding(.bottom, 6)

				ScrollView(showsIndicators: false) {
					VStack(alignment: .center, spacing: 0) {
						bookHeaderSection
							.padding(.bottom, 24)
						descriptionText
							.padding(.bottom, 52)
						meetingInfoSection
                            .padding(.bottom, 40)
                        noticeSection
                            .padding(.bottom, 24)
                        if meeting.status == .recruiting && !isParticipant {
                            BottomActionButton(title: isParticipating ? "참여 중..." : "모임 참여하기") {
                                guard !isParticipating else { return }
                                Task {
                                    isParticipating = true
                                    do {
                                        _ = try await service?.participateMeeting(meetingId: meeting.id)
                                        showSuccessModal = true
                                    } catch {
                                        participationError = error.localizedDescription
                                        isParticipating = false
                                    }
                                }
                            }
                            .padding(.bottom, 42)
                            .disabled(isParticipating)
                        }
					}
				}
				.scrollBounceBehavior(.basedOnSize)
			}
		}
        .enableSwipeBack()
		.overlay {
            if showSuccessModal {
                ZStack {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    SuccessModalView(title: "모임에 참여했습니다") {
                        dismiss()
                        onParticipated?()
                    }
                }
            }
        }
		.toolbar(.hidden, for: .navigationBar)
		.hideTabBar()
		.alert("모임 참여 실패", isPresented: Binding(
			get: { participationError != nil },
			set: { if !$0 { participationError = nil } }
		)) {
			Button("확인", role: .cancel) { participationError = nil }
		} message: {
			Text(participationError ?? "")
		}
		.task {
			guard let service else { return }
			do {
				meeting = try await service.fetchMeetingDetail(meetingId: meeting.id)
			} catch {
				meetingDismissed = true
			}
		}
		.alert("모임이 폭파됐어요", isPresented: $meetingDismissed) {
			Button("확인") { dismiss() }
		} message: {
			Text("인원 미달로 모임이 자동으로 폭파됐습니다.")
		}
	}

	// MARK: - Decoration

    private var leafDecoration: some View {
        Image(.leaf1)
            .resizable()
            .scaledToFit()
            .frame(width: 123)
            .opacity(0.55)
            .rotationEffect(.degrees(-5))
            .offset(x: 137, y: -300)
            .allowsHitTesting(false)
    }

	// MARK: - Navigation Header

	private var navigationHeader: some View {
		HStack(spacing: 12) {
			Button { dismiss() } label: {
				Image(.iconChevronRightGray2)
					.resizable()
					.scaledToFill()
					.frame(width: 20, height: 20)
					.clipped()
					.foregroundStyle(Color.gray600)
			}
			Text("독서 모임")
				.head2Style
				.foregroundStyle(Color.gray900)
			Spacer()
		}
		.padding(.horizontal, 30)
	}

	private var subtitleHeader: some View {
		HStack {
			Text(navigationSubtitle)
				.caption1RegularStyle
				.foregroundStyle(Color.gray500)
			Spacer()
		}
		.padding(.horizontal, 62)
	}

    // MARK: - Dynamic Header

    private var navigationSubtitle: String {
        isParticipant
            ? "같이 읽을 책과 모임 정보를 확인해주세요"
            : "참여하는 모임의 일정을 확인해주세요"
    }

	// MARK: - Book Header

	private var bookHeaderSection: some View {
		HStack(alignment: .center, spacing: 16) {
			BookCoverImage(book: meeting.book, placeholderImageName: "book_cover_mock")
				.aspectRatio(29.0/44.0, contentMode: .fit)
				.frame(height: 160)
				.clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray200, lineWidth: 0.5)
                }

			VStack(alignment: .leading, spacing: 4) {
				Text(meeting.book.title)
					.head1Style
					.foregroundStyle(Color.gray800)
					.padding(.bottom, 4)

				Text(meeting.book.publisher.map { "\(meeting.book.author) | \($0)" } ?? meeting.book.author)
					.body2RegularStyle
					.foregroundStyle(Color.gray500)

				if let kdcName = meeting.book.kdcName {
					Text(kdcName)
						.caption1SemiBoldStyle
						.foregroundStyle(Color.white)
						.padding(.horizontal, 10)
						.padding(.vertical, 2)
						.background(Color.green600)
						.clipShape(Capsule())
				}
			}

			Spacer()
		}
        .padding(.top, 6)
		.padding(.horizontal, 28.5)
	}

	@ViewBuilder
	private var descriptionText: some View {
		if let description = meeting.book.description, !description.isEmpty {
			Text(description)
				.caption1RegularStyle
				.foregroundStyle(Color.gray600)
				.padding(.horizontal, 29.5)
                .lineLimit(4)
		}
	}

	// MARK: - Meeting Info

	private var meetingInfoSection: some View {
		VStack(alignment: .leading, spacing: 20) {
			HStack(spacing: 4.5) {
				Image("icon_calendar")
					.resizable()
					.scaledToFill()
					.frame(width: 20, height: 20)
					.clipped()
					.foregroundStyle(Color.gray600)
				Text("모임정보")
					.head2Style
					.foregroundStyle(Color.gray600)
			}
			.padding(.horizontal, 6)

			meetingInfoCard
				.padding(.horizontal, 4)
		}
		.padding(.horizontal, 19)
	}

	private var meetingInfoCard: some View {
		VStack(spacing: 0) {
			infoRow(icon: { Image("icon_calendar") }, label: "모임 날짜", value: meetingDateText)
				.padding(.top, 9)
				.padding(.bottom, 6)

			Divider()
				.overlay(Color.gray300)

			infoRow(icon: { Image("icon_calendar") }, label: "모임 시간", value: meetingTimeText)
				.padding(.top, 24)
				.padding(.bottom, 6)

			Divider()
				.overlay(Color.gray300)

			infoRow(icon: { Image("icon_clock").resizable().scaledToFill().frame(width: 14, height: 14).clipped() }, label: "타이머 시간", value: "\(meeting.timerMinutes)분")
				.padding(.top, 24)
				.padding(.bottom, 6)

			Divider()
				.overlay(Color.gray300)

			infoRow(icon: { Image("icon_group") }, label: "참여자 수", value: "\(meeting.currentParticipants)/\(meeting.maxParticipants)")
				.padding(.top, 24)
				.padding(.bottom, 6)

			Divider()
				.overlay(Color.gray300)
		}
		.padding(.vertical, 20)
		.padding(.horizontal, 20)
		.background(.white)
		.clipShape(RoundedRectangle(cornerRadius: 12))
		.overlay {
			RoundedRectangle(cornerRadius: 12)
				.stroke(Color.gray300, lineWidth: 0.5)
		}	}

	private func infoRow<Icon: View>(
		@ViewBuilder icon: () -> Icon,
		label: String,
		value: String
	) -> some View {
		HStack {
			icon()
			Text(label)
				.body2RegularStyle
				.foregroundStyle(Color.gray600)
			Spacer()
			Text(value)
				.body2RegularStyle
				.foregroundStyle(Color.gray600)
		}
		.padding(.horizontal, 8)
	}

    // MARK: - Notice

    private var noticeSection: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(.leaf3)
                .resizable()
                .scaledToFill()
                .frame(width: 20, height: 20)
                .clipped()
            VStack(alignment: .leading, spacing: 4) {
                Text("모임은 타이머 설정 시간 만료 후  자동으로 폭파돼요.")
                    .caption2SemiBoldStyle
                    .foregroundStyle(Color.green700)
                Text("편안하고 안전한 대화를 위해 최소인원 3명 이상이 필요해요.")
                    .caption2RegularStyle
                    .foregroundStyle(Color.gray500)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 29)
        .padding(.top, 12)
        .padding(.bottom, 9)
        .background(Color.green50.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 29)
    }

	// MARK: - Helpers

	private static let dateFormatter: DateFormatter = {
		let f = DateFormatter()
		f.dateFormat = "MM/dd"
		return f
	}()

	private static let timeFormatter: DateFormatter = {
		let f = DateFormatter()
		f.dateFormat = "HH:mm"
		return f
	}()

	private var meetingDateText: String {
		Self.dateFormatter.string(from: meeting.meetingDate)
	}

	private var meetingTimeText: String {
		Self.timeFormatter.string(from: meeting.meetingDate)
	}
}

// MARK: - Shared Bottom Button

struct BottomActionButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .body1SemiBoldStyle
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.green600)
                .clipShape(RoundedRectangle(cornerRadius: 10.3))
                .padding(.horizontal, 29)
        }
        .background {
            Color.white.ignoresSafeArea(edges: .bottom)
        }
    }
}

#Preview {
	NavigationStack {
		BookMeetingDetailView(
			meeting: BookMeeting(
				id: 1,
				book: Book(
					id: 1,
					title: "프로젝트 헤일메리",
					author: "앤디 위어",
					description: "중학교 과학 교사이자 전직 분자생물학자인 라이랜드 그레이스가 기억을 잃은 채 우주선에서 깨어나, 태양을 갉아 먹는 미생물 '아스트로파지'로 인해 멸종 위기에 처한 지구를 구하기 위해 외계인 과학자 '로키'와 함께 11.9광년 떨어진 타우 세티 행성계로 모험을 떠나는 이야기입니다",
					kdcName: "외국소설"
				),
				meetingDate: Calendar.current.date(from: DateComponents(year: 2026, month: 11, day: 30, hour: 19)) ?? Date(),
				timerMinutes: 30,
				maxParticipants: 6,
				currentParticipants: 4,
				status: .upcoming
			)
		)
	}
}
