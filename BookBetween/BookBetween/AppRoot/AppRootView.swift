//
//  AppRootView.swift
//  BookBetween
//
//  Created by 이준성 on 6/25/26.
//

import SwiftUI

struct AppRootView: View {
    @AppStorage("hasCompletedIntro")
    private var hasCompletedIntro = false

    @State private var launchPhase: AppLaunchPhase = .splash
    @State private var loginViewModel: LoginViewModel
    @State private var accountSetupViewModel: AccountSetupViewModel
    private let memberService: MemberServiceProtocol?
    private let bookService: BookServiceProtocol
    private let homeService: any HomeServiceProtocol
    private let meetingService: (any MeetingServiceProtocol)?
    private let notificationService: any NotificationServiceProtocol

    init(
        loginViewModel: LoginViewModel,
        accountSetupViewModel: AccountSetupViewModel,
        memberService: MemberServiceProtocol? = nil,
        bookService: BookServiceProtocol = BookService.stubbed(),
        homeService: any HomeServiceProtocol = HomeService.stubbed(),
        meetingService: (any MeetingServiceProtocol)? = nil,
        notificationService: any NotificationServiceProtocol =
            NotificationService.stubbed()
    ) {
        _loginViewModel = State(initialValue: loginViewModel)
        _accountSetupViewModel = State(initialValue: accountSetupViewModel)
        self.memberService = memberService
        self.bookService = bookService
        self.homeService = homeService
        self.meetingService = meetingService
        self.notificationService = notificationService
    }

    var body: some View {
        Group {
            switch launchPhase {
            case .splash:
                SplashView()
                    .task {
                        try? await Task.sleep(for: .seconds(1.5))

                        guard !Task.isCancelled else {
                            return
                        }

                        await loginViewModel.restoreSession()

                        guard !Task.isCancelled else {
                            return
                        }

                        launchPhase = hasCompletedIntro
                            ? .authentication
                            : .landing
                    }

            case .landing:
                LandingView {
                    launchPhase = .onboarding
                }

            case .onboarding:
                OnboardingView {
                    hasCompletedIntro = true
                    launchPhase = .authentication
                }

            case .authentication:
                authenticationContent
            }
        }
        .animation(.easeInOut, value: launchPhase)
        .animation(.easeInOut, value: loginViewModel.state)
    }

    @ViewBuilder
    private var authenticationContent: some View {
        switch loginViewModel.state {
        case .success(.accountSetup):
            AccountSetupView(
                viewModel: accountSetupViewModel
            ) {
                loginViewModel.completeAccountSetup()
            }

        case .success(.main):
            MainTabView(
                memberService: memberService,
                bookService: bookService,
                homeService: homeService,
                meetingService: meetingService,
                notificationService: notificationService,
                onLogout: {
                    try await loginViewModel.logout()
                }
            )

        case .success(.accountRecovery):
            AccountRecoveryPlaceholderView()

        case .idle, .loading, .failure:
            LoginView(viewModel: loginViewModel)
        }
    }
}

private enum AppLaunchPhase: Equatable {
    case splash
    case landing
    case onboarding
    case authentication
}

private struct AccountRecoveryPlaceholderView: View {
    var body: some View {
        Text("계정 복구 화면 준비 중입니다.")
    }
}

#Preview {
    AppRootView(
        loginViewModel: LoginViewModel(
            kakaoLoginService: PreviewKakaoLoginService(),
            authService: AuthService(
                baseURL: URL(string: "https://stub.bookbetween.local")!,
                provider: AuthStubProviderFactory.make(
                    scenario: .pendingOnboarding
                )
            )
        ),
        accountSetupViewModel: AccountSetupViewModel(
            onboardingService: PreviewOnboardingService()
        )
    )
}

private final class PreviewKakaoLoginService: KakaoLoginServiceProtocol {
    func login() async throws -> String {
        "preview-kakao-provider-token"
    }
}
