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
    private let chatService: any ChatServiceProtocol
    private let chatSocketService: (any ChatSocketServiceProtocol)?

    init(
        loginViewModel: LoginViewModel,
        accountSetupViewModel: AccountSetupViewModel,
        memberService: MemberServiceProtocol? = nil,
        bookService: BookServiceProtocol = BookService.stubbed(),
        homeService: any HomeServiceProtocol = HomeService.stubbed(),
        meetingService: (any MeetingServiceProtocol)? = nil,
        notificationService: any NotificationServiceProtocol =
            NotificationService.stubbed(),
        chatService: any ChatServiceProtocol = ChatService.stubbed(),
        chatSocketService: (any ChatSocketServiceProtocol)? = nil
    ) {
        _loginViewModel = State(initialValue: loginViewModel)
        _accountSetupViewModel = State(initialValue: accountSetupViewModel)
        self.memberService = memberService
        self.bookService = bookService
        self.homeService = homeService
        self.meetingService = meetingService
        self.notificationService = notificationService
        self.chatService = chatService
        self.chatSocketService = chatSocketService
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
                chatService: chatService,
                chatSocketService: chatSocketService,
                onLogout: {
                    try await loginViewModel.logout()
                },
                onWithdraw: {
                    try await withdrawAccount()
                }
            )

        case .success(.accountRecovery):
            accountRecoveryContent

        case .idle, .loading, .failure:
            LoginView(viewModel: loginViewModel)
        }
    }

    private var accountRecoveryContent: some View {
        ZStack {
            LoginView(viewModel: loginViewModel)
                .allowsHitTesting(false)

            Color.black.opacity(0.3)
                .ignoresSafeArea()

            AccountRecoveryModalView(
                onCancel: {
                    guard !loginViewModel.isRecoveringAccount else {
                        return
                    }

                    loginViewModel.cancelAccountRecovery()
                },
                onConfirm: {
                    Task {
                        await loginViewModel.restoreAccount()
                    }
                }
            )
        }
        .alert(
            "계정을 복구하지 못했습니다.",
            isPresented: Binding(
                get: {
                    loginViewModel.accountRecoveryErrorMessage != nil
                },
                set: { isPresented in
                    if !isPresented {
                        loginViewModel.accountRecoveryErrorMessage = nil
                    }
                }
            )
        ) {
            Button("확인", role: .cancel) {
                loginViewModel.accountRecoveryErrorMessage = nil
            }
        } message: {
            Text(
                loginViewModel.accountRecoveryErrorMessage
                    ?? "다시 시도해주세요."
            )
        }
    }

    private func withdrawAccount() async throws {
        guard let memberService else {
            throw NetworkError.emptyResult
        }

        _ = try await memberService.withdrawMyAccount()
        loginViewModel.completeAccountWithdrawal()
    }
}

private enum AppLaunchPhase: Equatable {
    case splash
    case landing
    case onboarding
    case authentication
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
