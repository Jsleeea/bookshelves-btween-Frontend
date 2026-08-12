import SwiftUI

struct BookMeetingDetailView: View {
    @Environment(\.dismiss) private var dismiss

    private let service: (any MeetingServiceProtocol)?
    private let isParticipant: Bool
    private let onParticipated: (() -> Void)?
    @State private var meeting: BookMeeting
    @State private var isLoading = false
    @State private var isParticipating = false
    @State private var participationError: String?
    @State private var fetchError = false
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
                    .padding(.bottom, 8)
				subtitleHeader
                    .padding(.bottom, 6)

				ScrollView(.vertical, showsIndicators: false) {
					VStack(alignment: .center, spacing: 0) {
						bookHeaderSection
							.padding(.bottom, 24)
						descriptionText
							.padding(.bottom, 52)
						meetingInfoSection
                            .padding(.bottom, (meeting.status == .recruiting && !isParticipant) ? 16 : 32)
                        noticeSection
                            .padding(.bottom, 12)
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
                            .padding(.bottom, 16)
                            .disabled(isParticipating)
                        }
					}
                    .frame(maxWidth: .infinity)
				}
				.scrollBounceBehavior(.basedOnSize)
                .scrollDisabled(isParticipant)
			}
		}
        .enableSwipeBack()
		.overlay {
            ZStack {
                if isLoading {
                    Color.beige100
                        .ignoresSafeArea()
                        .transition(.opacity)
                    ProgressView()
                        .transition(.opacity)
                }
                if showSuccessModal {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    CommonNoticeModalView(type: .success, title: "모임에 참여했습니다") {
                        dismiss()
                        onParticipated?()
                    }
                }
            }
            .animation(.easeInOut(duration: 0.25), value: isLoading)
        }
		.toolbar(.hidden, for: .navigationBar)
		.hideTabBar()
		.alert("모임에 참여하지 못했습니다", isPresented: Binding(
			get: { participationError != nil },
			set: { if !$0 { participationError = nil } }
		)) {
			Button("확인", role: .cancel) { participationError = nil }
		} message: {
			Text(participationError ?? "")
		}
		.task {
			guard let service else { return }
            isLoading = true
            defer { isLoading = false }
			do {
				meeting = try await service.fetchMeetingDetail(meetingId: meeting.id)
			} catch {
				fetchError = true
			}
		}
		.alert("모임 정보를 불러오지 못했습니다", isPresented: $fetchError) {
			Button("확인") { dismiss() }
		} message: {
			Text("잠시 후 다시 시도해주세요.")
		}
	}

	// MARK: - Decoration

    private var leafDecoration: some View {
        GeometryReader { geo in
            Image(.leaf1)
                .resizable()
                .scaledToFit()
                .frame(width: 123)
                .opacity(0.55)
                .position(
                    x: geo.size.width * 0.85,
                    y: geo.size.height * 0.15
                )
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
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

			VStack(alignment: .leading, spacing: 10) {
				Text(meeting.book.title)
					.head2Style
					.foregroundStyle(Color.gray800)
                    .lineLimit(2)

				Text(meeting.book.publisher.map { "\(meeting.book.author) | \($0)" } ?? meeting.book.author)
					.body2RegularStyle
					.foregroundStyle(Color.gray500)
                    .lineLimit(1)

				if let kdcName = meeting.book.kdcName {
					Text("#\(kdcName)")
						.body2SemiBoldStyle
						.foregroundStyle(Color.white)
						.padding(.horizontal, 10)
						.padding(.vertical, 5)
						.background(Color.green600)
						.clipShape(Capsule())
				}
			}
		}
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 6)
		.padding(.horizontal, 28)
	}

	@ViewBuilder
	private var descriptionText: some View {
		if let description = meeting.book.description, !description.isEmpty {
			Text(description)
				.caption1RegularStyle
				.foregroundStyle(Color.gray600)
				.padding(.horizontal, 28)
                .lineLimit(4)
		}
	}

	// MARK: - Meeting Info

	private var meetingInfoSection: some View {
		VStack(alignment: .leading, spacing: 0) {
			HStack(spacing: 4.5) {
				Image("icon_calendar")
					.resizable()
					.scaledToFill()
					.frame(width: 20, height: 20)
					.clipped()
					.foregroundStyle(Color.gray600)
				Text("모임정보")
                    .font(.head2)
					.foregroundStyle(Color.gray600)
			}
            .padding(.bottom, 8)
			.padding(.horizontal, 5)

            Text("모임은 현재 시간 기준 7시간 이후부터 생성할 수 있어요")
                .font(.caption1SemiBold)
                .foregroundStyle(Color.green700)
                .padding(.bottom, 20)
                .padding(.horizontal, 5)

			meetingInfoCard
				.padding(.horizontal, 3)
		}
		.padding(.horizontal, 20)
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
		.padding(.horizontal, 22)
		.background(.white)
		.clipShape(RoundedRectangle(cornerRadius: 12))
		.overlay {
			RoundedRectangle(cornerRadius: 12)
				.stroke(Color.gray300, lineWidth: 0.5)
		}	}

	// MARK: - Info Row

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
		.padding(.horizontal, 18)
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
            Color.clear.ignoresSafeArea(edges: .bottom)
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
