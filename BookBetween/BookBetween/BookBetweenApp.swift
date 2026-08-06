//
//  BookBetweenApp.swift
//  BookBetween
//
//  Created by 이준성 on 6/25/26.
//

import SwiftUI
import KakaoSDKAuth
import KakaoSDKCommon

@main
struct BookBetweenApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    private let loginViewModel: LoginViewModel
    private let accountSetupViewModel: AccountSetupViewModel
    private let memberService: MemberServiceProtocol
    private let bookService: BookServiceProtocol
    private let homeService: any HomeServiceProtocol
    private let meetingService: MeetingService
    private let notificationService: NotificationServiceProtocol
    private let chatService: any ChatServiceProtocol
    private let chatSocketService: any ChatSocketServiceProtocol

    init() {
        guard let kakaoNativeAppKey = Bundle.main.object(
            forInfoDictionaryKey: "KAKAO_NATIVE_APP_KEY"
        ) as? String,
        !kakaoNativeAppKey.isEmpty else {
            preconditionFailure("KAKAO_NATIVE_APP_KEY가 설정되지 않았습니다.")
        }

        KakaoSDK.initSDK(appKey: kakaoNativeAppKey)

        guard let apiBaseURL = URL(
            string: "https://api.bookshelves-btween.com"
        ) else {
            preconditionFailure("API Base URL을 생성하지 못했습니다.")
        }

        let authTokenStore = AuthTokenStore()
        let authSessionStore = AuthSessionStore()
        let authNetworkConfiguration = NetworkConfiguration(
            baseURL: apiBaseURL,
            accessToken: {
                try? authTokenStore.accessToken()
            }
        )

        let authService = AuthService(
            configuration: authNetworkConfiguration
        )
        let loginViewModel = LoginViewModel(
            kakaoLoginService: KakaoLoginService(),
            authService: authService,
            authTokenStore: authTokenStore,
            authSessionStore: authSessionStore
        )
        let authenticatedNetworkConfiguration = NetworkConfiguration(
            baseURL: apiBaseURL,
            accessToken: {
                try? authTokenStore.accessToken()
            },
            reissueTokens: {
                try await loginViewModel.reissueTokens()
            }
        )

        self.loginViewModel = loginViewModel
        self.accountSetupViewModel = AccountSetupViewModel(
            onboardingService: OnboardingService(
                configuration: authenticatedNetworkConfiguration
            )
        )
        self.memberService = MemberService(
            configuration: authenticatedNetworkConfiguration
        )
        self.bookService = BookService(
            configuration: authenticatedNetworkConfiguration
        )
        self.homeService = HomeService(
            configuration: authenticatedNetworkConfiguration
        )
        self.meetingService = MeetingService(
            configuration: authenticatedNetworkConfiguration
        )
        self.notificationService = NotificationService(
            configuration: authenticatedNetworkConfiguration
        )
        self.chatService = ChatService(
            configuration: authenticatedNetworkConfiguration
        )
        self.chatSocketService = ChatSocketService(
            configuration: authenticatedNetworkConfiguration
        )
    }

    var body: some Scene {
        WindowGroup {
            AppRootView(
                loginViewModel: loginViewModel,
                accountSetupViewModel: accountSetupViewModel,
                memberService: memberService,
                bookService: bookService,
                homeService: homeService,
                meetingService: meetingService,
                notificationService: notificationService,
                chatService: chatService,
                chatSocketService: chatSocketService
            )
                .onOpenURL { url in
                    if AuthApi.isKakaoTalkLoginUrl(url) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }
                }
        }
    }
}
