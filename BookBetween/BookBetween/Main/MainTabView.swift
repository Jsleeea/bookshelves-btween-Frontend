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

    private let memberService: MemberServiceProtocol?
    private let bookService: BookServiceProtocol
    private let meetingService: (any MeetingServiceProtocol)?
    private let onLogout: () async throws -> Void

    init(
        memberService: MemberServiceProtocol? = nil,
        bookService: BookServiceProtocol = BookService.stubbed(),
        meetingService: (any MeetingServiceProtocol)? = nil,
        onLogout: @escaping () async throws -> Void = {}
    ) {
        self.memberService = memberService
        self.bookService = bookService
        self.meetingService = meetingService
        self.onLogout = onLogout
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .home:
                    NavigationStack(path: $homeNavigationPath) {
                        HomeView()
                            .navigationDestination(for: HomeRoute.self) { route in
                                switch route {
                                case .notificationInbox:
                                    NotificationInboxView()
                                }
                            }
                    }
                case .search:
                    NavigationStack {
                        SearchView(
                            viewModel: SearchViewModel(
                                service: bookService
                            )
                        )
                    }
                case .bookClub:
                    NavigationStack { BookClubView(meetingService: meetingService, bookService: bookService) }
                case .myLibrary:
                    NavigationStack { MyLibraryView() }
                case .profile:
                    NavigationStack {
                        ProfileView(
                            viewModel: ProfileViewModel(
                                memberService: memberService
                            ),
                            onLogout: onLogout
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
