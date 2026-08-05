import SwiftUI

struct BookClubView: View {
	@State private var viewModel: BookClubViewModel
	@State private var currentMeetingPage = 0
	@FocusState private var isSearchFocused: Bool
    @State private var showFetchErrorModal = false
    @State private var showSummaryPendingModal = false
    private let navigationPath: Binding<NavigationPath>

	init(
		meetingService: (any MeetingServiceProtocol)? = nil,
		bookService: (any BookServiceProtocol)? = nil,
        memberService: (any MemberServiceProtocol)? = nil,
		chatService: (any ChatServiceProtocol)? = nil,
		chatSocketService: (any ChatSocketServiceProtocol)? = nil,
        navigationPath: Binding<NavigationPath> = .constant(NavigationPath())
	) {
		_viewModel = State(
			initialValue: BookClubViewModel(
				meetingService: meetingService,
				bookService: bookService,
                memberService: memberService,
				chatService: chatService,
				chatSocketService: chatSocketService
			)
		)
        self.navigationPath = navigationPath
	}

	var body: some View {
		VStack(spacing: 0) {
			HStack {
				Text("모임 관리")
					.head2Style
                    .foregroundStyle(Color.gray900)
				Spacer()
			}
            .padding(.top, 8)
			.padding(.horizontal, 30)
            .padding(.bottom, 6)

			tabSelector

			if viewModel.selectedTab == .search {
				searchContent
                    .padding(.top, 8)
			} else {
				HStack {
					Spacer()
					MonthYearPickerView(
						selectedYear: Bindable(viewModel).selectedYear,
						selectedMonth: Bindable(viewModel).selectedMonth,
						startYear: viewModel.joinedYear
					)
				}
				.padding(.horizontal, 19)
                .padding(.bottom, 15)

				ScrollView(showsIndicators: false) {
					let meetings = viewModel.selectedTab == .myMeetings
						? viewModel.filteredParticipatingMeetings
						: viewModel.filteredCreatedMeetings
					if meetings.isEmpty {
						emptyStateView(message: "모임이 없습니다")
							.frame(height: 522)
					} else {
						VStack(spacing: 12) {
							meetingList(meetings)
						}
						.padding(.top, 1)
						.padding(.bottom, 100)
					}
				}
				.refreshable {
                    await viewModel.fetchMyMeetings()
                }
				.scrollBounceBehavior(.basedOnSize)
			}
		}
		.background(Color.beige100)
		.toolbar(.hidden, for: .navigationBar)
        .navigationDestination(for: BookClubRoute.self) { route in
            switch route {
            case .detail(let meeting, let isParticipant):
                BookMeetingDetailView(
                    meeting: meeting,
                    service: viewModel.meetingService,
                    isParticipant: isParticipant,
                    onParticipated: isParticipant ? nil : {
                        viewModel.selectedTab = .myMeetings
                        Task { await viewModel.fetchMyMeetings() }
                    }
                )
            case .chat(let chatroomId, let meetingId):
                if let chatService = viewModel.chatService, let chatSocketService = viewModel.chatSocketService {
                    ChatView(viewModel: ChatViewModel(
                        chatroomId: chatroomId,
                        meetingId: meetingId,
                        chatService: chatService,
                        socketService: chatSocketService
                    ))
                } else {
                    ChatView(chatroomId: chatroomId, meetingId: meetingId)
                }
            case .result(let meeting):
                BookMeetingResultView(meeting: meeting, service: viewModel.meetingService)
            case .create(let book):
                BookMeetingCreateView(book: book, service: viewModel.meetingService) {
                    viewModel.selectedTab = .myMeetings
                    Task { await viewModel.fetchMyMeetings() }
                }
            }
        }
        .bookClubErrorOverlay(showFetchError: $showFetchErrorModal, showSummaryPending: $showSummaryPendingModal)
		.task {
            await viewModel.fetchJoinedYear()
			await viewModel.fetchMyMeetings()
		}
		.onChange(of: viewModel.selectedYear) {
			Task { await viewModel.fetchMyMeetings() }
		}
		.onChange(of: viewModel.selectedMonth) {
			Task { await viewModel.fetchMyMeetings() }
		}
	}

	// MARK: - Tab Selector

	private var tabSelector: some View {
		HStack(spacing: 8) {
			ForEach(BookClubTab.allCases, id: \.self) { tab in
				tabPill(for: tab)
			}
			Spacer()
		}
        .padding(.top, 6)
        .padding(.bottom, 8)
        .padding(.horizontal, 30)
	}

	private func tabPill(for tab: BookClubTab) -> some View {
		Button {
			viewModel.selectedTab = tab
		} label: {
			Text(tab.title)
				.caption1SemiBoldStyle
				.foregroundStyle(viewModel.selectedTab == tab ? Color.gray50 : Color.gray200)
				.frame(width: tab.pillWidth, height: 30)
				.background(viewModel.selectedTab == tab ? Color.green600 : Color.gray50)
				.clipShape(Capsule())
				.overlay(Capsule().stroke(Color.gray200, lineWidth: viewModel.selectedTab == tab ? 0 : 1))
		}
	}

	// MARK: - Meeting List (참여/내가 만든)

	@ViewBuilder
	private func meetingList(_ meetings: [BookMeeting]) -> some View {
		ForEach(meetings, id: \.id) { meeting in
			BookMeetingCardView(
				meeting: meeting,
				service: viewModel.meetingService,
				isParticipant: true,
                onCompletedNavigate: { fetched in
                    navigationPath.wrappedValue.append(BookClubRoute.result(fetched))
                },
                onFetchError: { showFetchErrorModal = true },
                onSummaryPending: { showSummaryPendingModal = true }
			)
		}
	}

	// MARK: - Search

	private var searchContent: some View {
		VStack(spacing: 0) {
			searchBar
                .padding(.bottom, 8)

			ScrollView(showsIndicators: false) {
				VStack(alignment: .leading, spacing: 0) {
					ZStack(alignment: .top) {
						if viewModel.meetingSearchResults.isEmpty {
							emptyStateView(message: "검색된 모임이 없습니다")
						} else {
							meetingResultsSection
						}
					}
					.frame(height: 522)
				}
				.padding(.top, 8)
				.contentShape(Rectangle())
				.onTapGesture { isSearchFocused = false }
			}
			.scrollDismissesKeyboard(.immediately)
			.scrollBounceBehavior(.basedOnSize)
		}
		.onChange(of: viewModel.searchText) {
			currentMeetingPage = 0
			Task {
				await viewModel.searchMeetings(query: viewModel.searchText)
			}
		}
	}

	private func emptyStateView(message: String) -> some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                RadialGradient(
                    stops: [
                        Gradient.Stop(color: Color.green01.opacity(0.4), location: 0.2982),
                        Gradient.Stop(color: Color.green01.opacity(0.0), location: 0.7019)
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: w * 0.5951
                )

                Image("leaf_left")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 108)
                    .position(x: 30, y: h * 0.13)

                Image("leaf_right")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 108)
                    .position(x: w - 30, y: h * 0.22)

                Image("search_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 152, height: 131)
                    .position(x: w / 2, y: h * 0.46)

                Text(message)
                    .pointText5Style
                    .foregroundStyle(Color.green900)
                    .position(x: w / 2, y: h * 0.67)
            }
            .allowsHitTesting(false)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - searchBar
    
	private var searchBar: some View {
        HStack(spacing: 10.42) {
            Image(.iconMagnifyingglass)
                .resizable()
                .scaledToFill()
                .frame(width: 20, height: 20)
                .clipped()
				.foregroundStyle(Color.gray600)

			TextField("모임 검색", text: Bindable(viewModel).searchText)
				.font(.body1Regular)
                .foregroundStyle(Color.gray500)
				.focused($isSearchFocused)
		}
        .frame(height: 46)
		.padding(.horizontal, 11)
		.background(.white)
		.clipShape(RoundedRectangle(cornerRadius: 10))
		.overlay {
			RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray200, lineWidth: 0.5)
		}
        .padding(.horizontal, 19)
	}

	// MARK: - Meeting Results

	private var meetingPages: [[BookMeeting]] {
		let pages = stride(from: 0, to: viewModel.meetingSearchResults.count, by: 3).map { start in
			Array(viewModel.meetingSearchResults[start..<min(start + 3, viewModel.meetingSearchResults.count)])
		}
		return Array(pages.prefix(3))
	}

	@ViewBuilder
	private var meetingResultsSection: some View {
		if !viewModel.meetingSearchResults.isEmpty {
			VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .top) {
                    VStack(spacing: 12) {
                        ForEach(meetingPages[currentMeetingPage], id: \.id) { meeting in
                            BookMeetingCardView(
                                meeting: meeting,
                                service: viewModel.meetingService,
                                onCompletedNavigate: { fetched in
                                    navigationPath.wrappedValue.append(BookClubRoute.result(fetched))
                                },
                                onFetchError: { showFetchErrorModal = true },
                                onSummaryPending: { showSummaryPendingModal = true }
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                }

				pageIndicator
                    .padding(.top, 92)
                    .padding(.bottom, 40)
			}
            .background(alignment: .topLeading) {
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [Color.green01, Color.green01.opacity(0)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 281
                        )
                    )
                    .frame(width: 562, height: 454)
                    .opacity(0.40)
                    .offset(x: -175, y: 575)
                    .allowsHitTesting(false)
            }
		}
	}

	private var pageIndicator: some View {
		HStack(spacing: 12) {
			Button {
				if currentMeetingPage > 0 { currentMeetingPage -= 1 }
			} label: {
                Image(.iconChevronLeft)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 6, height: 12)
                    .clipped()
                    .foregroundStyle(Color.gray600)
			}

			HStack(spacing: 6) {
				ForEach(0..<meetingPages.count, id: \.self) { page in
					Button {
						currentMeetingPage = page
					} label: {
						Text("\(page + 1)")
							.font(.body2Regular)
							.foregroundStyle(page == currentMeetingPage ? Color.gray50 : Color.gray600)
							.frame(width: 20, height: 20)
							.background(page == currentMeetingPage ? Color.green700 : Color.clear)
							.clipShape(Circle())
					}
				}
			}

			Button {
				if currentMeetingPage < meetingPages.count - 1 { currentMeetingPage += 1 }
			} label: {
                Image(.iconChevronRight)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 6, height: 12)
                    .clipped()
                    .foregroundStyle(Color.gray600)
			}
		}
		.frame(maxWidth: .infinity)
	}

}


#Preview {
	NavigationStack {
		BookClubView()
	}
}
