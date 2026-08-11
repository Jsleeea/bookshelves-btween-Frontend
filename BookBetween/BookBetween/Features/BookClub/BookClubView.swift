import SwiftUI

struct BookClubView: View {
	@State private var viewModel: BookClubViewModel
	@FocusState private var isSearchFocused: Bool
    @State private var searchSubmitted = false
    @State private var showFetchErrorModal = false
    @State private var showSummaryPendingModal = false
    private let navigationPath: Binding<NavigationPath>
    private let onNavigateToBookSearch: ((String) -> Void)?

	init(
		meetingService: (any MeetingServiceProtocol)? = nil,
		bookService: (any BookServiceProtocol)? = nil,
        memberService: (any MemberServiceProtocol)? = nil,
		chatService: (any ChatServiceProtocol)? = nil,
		chatSocketService: (any ChatSocketServiceProtocol)? = nil,
        navigationPath: Binding<NavigationPath> = .constant(NavigationPath()),
        onNavigateToBookSearch: ((String) -> Void)? = nil
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
        self.onNavigateToBookSearch = onNavigateToBookSearch
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
                let meetings = viewModel.selectedTab == .myMeetings
                    ? viewModel.filteredParticipatingMeetings
                    : viewModel.filteredCreatedMeetings

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

                GeometryReader { contentGeo in
                    ZStack {
                        if meetings.isEmpty && !viewModel.isLoadingMeetings {
                            SearchIdleView(height: contentGeo.size.height, customTitle: "모임이 없습니다")
                                .padding(.horizontal, 19)
                                .transition(.opacity)
                        } else {
                            ScrollView(showsIndicators: false) {
                                VStack(spacing: 12) {
                                    meetingList(meetings)
                                }
                                .padding(.top, 1)
                                .padding(.bottom, 100)
                            }
                            .refreshable {
                                await viewModel.fetchMyMeetings()
                            }
                        }
                    }
                    .animation(.easeInOut(duration: 0.2), value: meetings.isEmpty && !viewModel.isLoadingMeetings)
                }
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
            case .chat(let chatroomId, let meetingId, let bookAuthor):
                if let chatService = viewModel.chatService, let chatSocketService = viewModel.chatSocketService {
                    ChatView(
                        viewModel: ChatViewModel(
                            chatroomId: chatroomId,
                            meetingId: meetingId,
                            chatService: chatService,
                            socketService: chatSocketService,
                            meetingService: viewModel.meetingService
                        ),
                        bookAuthor: bookAuthor
                    )
                } else {
                    ChatView(
                        chatroomId: chatroomId,
                        meetingId: meetingId,
                        meetingService: viewModel.meetingService,
                        bookAuthor: bookAuthor
                    )
                }
            case .result(let meeting):
                BookMeetingResultView(meeting: meeting, service: viewModel.meetingService)
            case .create(let book):
                BookMeetingCreateView(book: book, service: viewModel.meetingService) {
                    navigationPath.wrappedValue = NavigationPath()
                    viewModel.selectedTab = .myMeetings
                    Task { await viewModel.fetchMyMeetings() }
                }
            }
        }
        .alert("데이터를 불러오지 못했습니다", isPresented: $showFetchErrorModal) {
            Button("확인", role: .cancel) {}
        }
        .overlay {
            ZStack {
                if showSummaryPendingModal {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    CommonNoticeModalView(type: .error, title: "요약이 완료되지 않았습니다") {
                        showSummaryPendingModal = false
                    }
                }
            }
            .animation(.easeInOut(duration: 0.2), value: showSummaryPendingModal)
        }
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

            GeometryReader { contentGeo in
                ZStack {
                    if viewModel.searchText.isEmpty || !searchSubmitted {
                        SearchIdleView(height: contentGeo.size.height, customTitle: "검색어를 입력해주세요")
                            .padding(.horizontal, 19)
                            .transition(.opacity)
                    } else if viewModel.meetingSearchResults.isEmpty {
                        SearchIdleView(
                            height: contentGeo.size.height,
                            mode: .emptyResult,
                            customTitle: "해당 도서로 생성된 모임이 없습니다\n도서를 검색해 모임을 생성해보세요",
                            actionTitle: "도서 검색 탭으로 이동하기",
                            onAction: { onNavigateToBookSearch?(viewModel.searchText) }
                        )
                        .padding(.horizontal, 19)
                        .transition(.opacity)
                    } else {
                        ScrollView(showsIndicators: false) {
                            meetingResultsSection
                                .padding(.top, 8)
                                .contentShape(Rectangle())
                                .onTapGesture { isSearchFocused = false }
                        }
                        .scrollDismissesKeyboard(.immediately)
                        .scrollBounceBehavior(.basedOnSize)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture { isSearchFocused = false }
                .animation(.easeInOut(duration: 0.2), value: viewModel.searchText.isEmpty)
                .animation(.easeInOut(duration: 0.2), value: searchSubmitted)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
		}
		.onChange(of: viewModel.searchText) {
            searchSubmitted = false
		}
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
                .onSubmit {
                    guard !viewModel.searchText.isEmpty else { return }
                    searchSubmitted = true
                    Task { await viewModel.searchMeetings(query: viewModel.searchText) }
                }
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

	@ViewBuilder
	private var meetingResultsSection: some View {
		VStack(spacing: 12) {
			ForEach(viewModel.meetingSearchResults, id: \.id) { meeting in
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
		.padding(.bottom, 100)
	}

}


#Preview {
	NavigationStack {
		BookClubView()
	}
}
