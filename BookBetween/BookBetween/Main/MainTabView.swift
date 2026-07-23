//
//  MainTabView.swift
//  BookBetween
//
//  Created by 이준성 on 6/25/26.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: TabCase = .home
<<<<<<< Updated upstream
    @State private var homeNavigationPath = NavigationPath()

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                NavigationStack(path: $homeNavigationPath) {
                    HomeView()
                        .navigationDestination(for: HomeRoute.self) { route in
                            switch route {
                            case .notificationInbox:
                                NotificationInboxView()
                            }
                        }
=======
    @State private var hideTabBar = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .home:
                    NavigationStack { HomeView() }
                case .search:
                    NavigationStack { SearchView() }
                case .bookClub:
                    NavigationStack { BookClubView() }
                case .myLibrary:
                    NavigationStack { MyLibraryView() }
                case .profile:
                    NavigationStack { ProfileView() }
>>>>>>> Stashed changes
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .onPreferenceChange(HideTabBarPreferenceKey.self) { hideTabBar = $0 }

<<<<<<< Updated upstream
            if shouldShowTabBar {
                CustomTabBar(selectedTab: $selectedTab)
                    .ignoresSafeArea(.keyboard, edges: .bottom)
=======
            if !hideTabBar {
                CustomTabBar(selectedTab: $selectedTab)
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                    .transition(.move(edge: .bottom))
>>>>>>> Stashed changes
            }
        }
        .animation(.easeInOut(duration: 0.2), value: hideTabBar)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onChange(of: selectedTab) { hideTabBar = false }
    }

    private var shouldShowTabBar: Bool {
        selectedTab != .home || homeNavigationPath.isEmpty
    }
}

#Preview {
    MainTabView()
}
