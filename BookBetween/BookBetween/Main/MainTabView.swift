//
//  MainTabView.swift
//  BookBetween
//
//  Created by 이준성 on 6/25/26.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: TabCase = .home
    @State private var hideTabBar = false
    @State private var homeNavigationPath = NavigationPath()
    @State private var bookClubPath = NavigationPath()

    private let memberService: MemberServiceProtocol?
    private let bookService: BookServiceProtocol
    private let homeService: any HomeServiceProtocol
    private let meetingService: (any MeetingServiceProtocol)?
    private let notificationService: any NotificationServiceProtocol
    private let chatService: any ChatServiceProtocol
    private let chatSocketService: (any ChatSocketServiceProtocol)?
    private let onLogout: () async throws -> Void
    private let onWithdraw: () async throws -> Void

    init(
        memberService: MemberServiceProtocol? = nil,
        bookService: BookServiceProtocol = BookService.stubbed(),
        homeService: any HomeServiceProtocol = HomeService.stubbed(),
        meetingService: (any MeetingServiceProtocol)? = nil,
        notificationService: any NotificationServiceProtocol =
            NotificationService.stubbed(),
        chatService: any ChatServiceProtocol = ChatService.stubbed(),
        chatSocketService: (any ChatSocketServiceProtocol)? = nil,
        onLogout: @escaping () async throws -> Void = {},
        onWithdraw: @escaping () async throws -> Void = {}
    ) {
        self.memberService = memberService
        self.bookService = bookService
        self.homeService = homeService
        self.meetingService = meetingService
        self.notificationService = notificationService
        self.chatService = chatService
        self.chatSocketService = chatSocketService
        self.onLogout = onLogout
        self.onWithdraw = onWithdraw
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .home:
                    NavigationStack(path: $homeNavigationPath) {
                        HomeView(
                            viewModel: HomeViewModel(
                                service: homeService
                            ),
                            bookService: bookService,
                            meetingService: meetingService
                        )
                            .navigationDestination(for: HomeRoute.self) { route in
                                switch route {
                                case .notificationInbox:
                                    NotificationInboxView(
                                        viewModel: NotificationInboxViewModel(
                                            service: notificationService
                                        ),
                                        meetingService: meetingService,
                                        chatService: chatService,
                                        chatSocketService: chatSocketService
                                    )
                                case .meetingDetail(let meeting):
                                    BookMeetingDetailView(
                                        meeting: meeting,
                                        service: meetingService
                                    )
                                case .bookDetail(let book):
                                    BookRecordDetailView(
                                        book: book,
                                        isSaveable: book.isbn != nil,
                                        service: bookService,
                                        loadsRemoteDetail: true
                                    )
                                case .recentBookDetail(let record):
                                    BookRecordDetailView(
                                        record: record,
                                        service: bookService,
                                        loadsRemoteDetail: true
                                    )
                                }
                            }
                    }
                case .search:
                    NavigationStack {
                        SearchView(
                            viewModel: SearchViewModel(
                                service: bookService
                            ),
                            meetingService: meetingService
                        )
                    }
                case .bookClub:
                    NavigationStack(path: $bookClubPath) {
                        BookClubView(
                            meetingService: meetingService,
                            bookService: bookService,
                            memberService: memberService,
                            chatService: chatService,
                            chatSocketService: chatSocketService,
                            navigationPath: $bookClubPath
                        )
                    }
                case .myLibrary:
                    NavigationStack {
                        MyLibraryView(bookService: bookService)
                    }
                case .profile:
                    NavigationStack {
                        ProfileView(
                            viewModel: ProfileViewModel(
                                memberService: memberService,
                                bookService: bookService
                            ),
                            statisticsViewModel: ReadingStatisticsViewModel(
                                bookService: bookService
                            ),
                            onLogout: onLogout,
                            onWithdraw: onWithdraw
                        )
                    }
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .onPreferenceChange(HideTabBarPreferenceKey.self) { hideTabBar = $0 }

            if shouldShowTabBar {
                CustomTabBar(selectedTab: $selectedTab)
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                    .transition(.move(edge: .bottom))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: shouldShowTabBar)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onChange(of: selectedTab) { hideTabBar = false }
    }

    private var shouldShowTabBar: Bool {
        !hideTabBar && (selectedTab != .home || homeNavigationPath.isEmpty)
    }
}

#Preview {
    MainTabView()
}
