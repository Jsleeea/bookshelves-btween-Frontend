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
    @State private var pendingBookSearch = ""
    @State private var summaryCompletedMeeting: BookMeeting?
    @State private var summaryResultMeeting: BookMeeting?
    @State private var showSummaryResult = false
    @State private var meetingStartedMeeting: BookMeeting?
    @State private var meetingStartedNotificationCursor = 0

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
                                        service: meetingService,
                                        onParticipated: {
                                            selectedTab = .bookClub
                                            bookClubPath = NavigationPath()
                                        }
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
                                service: bookService,
                                initialQuery: pendingBookSearch
                            ),
                            meetingService: meetingService,
                            onMeetingCreated: {
                                selectedTab = .bookClub
                                bookClubPath = NavigationPath()
                            }
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
                            navigationPath: $bookClubPath,
                            onNavigateToBookSearch: { query in
                                pendingBookSearch = query
                                selectedTab = .search
                            }
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
            .environment(\.showSummaryCompleted) { meeting in
                summaryCompletedMeeting = meeting
            }
            .environment(\.goToHome) {
                selectedTab = .home
                homeNavigationPath = NavigationPath()
                bookClubPath = NavigationPath()
            }

            if shouldShowTabBar {
                CustomTabBar(selectedTab: $selectedTab)
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                    .transition(.move(edge: .bottom))
            }

            if let meeting = summaryCompletedMeeting {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)
                SummaryCompletedModalView(
                    meeting: meeting,
                    onClose: {
                        summaryCompletedMeeting = nil
                    },
                    onConfirm: {
                        summaryCompletedMeeting = nil
                        summaryResultMeeting = meeting
                        showSummaryResult = true
                    }
                )
                .transition(.scale(scale: 0.9).combined(with: .opacity))
            }

            if let meeting = meetingStartedMeeting {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)
                MeetingStartedModalView(
                    meeting: meeting,
                    onClose: {
                        meetingStartedMeeting = nil
                    },
                    onParticipate: {
                        meetingStartedMeeting = nil
                        bookClubPath.append(
                            BookClubRoute.chat(
                                chatroomId: meeting.chatroomId,
                                meetingId: meeting.id,
                                bookAuthor: meeting.book.author
                            )
                        )
                        selectedTab = .bookClub
                    }
                )
                .transition(.scale(scale: 0.9).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: summaryCompletedMeeting != nil)
        .animation(.easeInOut(duration: 0.2), value: meetingStartedMeeting != nil)
        .task {
            await watchMeetingStartedNotifications()
        }
        .sheet(isPresented: $showSummaryResult) {
            if let meeting = summaryResultMeeting {
                NavigationStack {
                    BookMeetingResultView(meeting: meeting, service: meetingService)
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: shouldShowTabBar)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onChange(of: selectedTab) { oldValue, _ in
            hideTabBar = false
            if oldValue == .search {
                pendingBookSearch = ""
            }
        }
    }

    private var shouldShowTabBar: Bool {
        !hideTabBar && (selectedTab != .home || homeNavigationPath.isEmpty)
    }

    // MARK: - Meeting Started Notification Polling

    private func watchMeetingStartedNotifications() async {
        if let initialPage = try? await notificationService.fetchNotifications(page: 1, size: 1) {
            meetingStartedNotificationCursor = initialPage.notifications.first?.id ?? 0
        }

        while !Task.isCancelled {
            do {
                try await Task.sleep(for: .seconds(30))
            } catch {
                return
            }

            guard let batch = try? await notificationService.fetchNewNotifications(
                afterId: meetingStartedNotificationCursor,
                size: 20
            ) else { continue }

            meetingStartedNotificationCursor = max(meetingStartedNotificationCursor, batch.nextCursor)

            for notification in batch.notifications where notification.type == .meetingStarted {
                guard
                    let meetingId = notification.targetId,
                    let meetingService,
                    let meeting = try? await meetingService.fetchMeetingDetail(meetingId: meetingId)
                else { continue }

                meetingStartedMeeting = meeting
            }

            for notification in batch.notifications where notification.type == .aiSummaryReady {
                guard
                    let meetingId = notification.targetId,
                    let meetingService,
                    let meeting = try? await meetingService.fetchMeetingDetail(meetingId: meetingId)
                else { continue }

                summaryCompletedMeeting = meeting
            }
        }
    }
}

#Preview {
    MainTabView()
}
