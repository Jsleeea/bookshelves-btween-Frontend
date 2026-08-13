//
//  LoginViewModel.swift
//  BookBetween
//

import Foundation
import Observation

// MARK: - 로그인 화면 이동

enum LoginDestination: Equatable {
    case accountSetup
    case main
    case accountRecovery
}

// MARK: - 로그인 화면 상태

enum LoginViewState: Equatable {
    case idle
    case loading
    case success(LoginDestination)
    case failure(LoginFailure)
}

// MARK: - 로그인 실패 유형

enum LoginFailure: Equatable {
    case cancelled
    case failed(String)

    var title: String {
        switch self {
        case .cancelled:
            return "로그인이 취소되었습니다."
        case .failed:
            return "로그인에 실패했습니다."
        }
    }

    var message: String {
        switch self {
        case .cancelled:
            return "원하는 로그인 방법을 다시 선택해주세요."
        case .failed(let message):
            return message
        }
    }
}

@MainActor
@Observable
final class LoginViewModel {
    // MARK: - 의존성

    private let kakaoLoginService: KakaoLoginServiceProtocol
    private let googleLoginService: GoogleLoginServiceProtocol
    private let appleLoginService: AppleLoginServiceProtocol
    private let authService: AuthServiceProtocol
    private let authTokenStore: AuthTokenStoreProtocol
    private let authSessionStore: AuthSessionStoreProtocol

    // MARK: - 상태

    @ObservationIgnored
    private var reissueTask: Task<Void, Error>?

    private(set) var state: LoginViewState = .idle
    private(set) var activeLoginProvider: SocialProvider?
    private(set) var isRecoveringAccount = false
    private(set) var scheduledDeletionAt: String?
    var accountRecoveryErrorMessage: String?

    // MARK: - 화면 표시 상태

    var isLoading: Bool {
        state == .loading
    }

    var isKakaoLoading: Bool {
        isLoading && activeLoginProvider == .kakao
    }

    var isGoogleLoading: Bool {
        isLoading && activeLoginProvider == .google
    }

    var isAppleLoading: Bool {
        isLoading && activeLoginProvider == .apple
    }

    // MARK: - 초기화

    init(
        kakaoLoginService: KakaoLoginServiceProtocol,
        googleLoginService: GoogleLoginServiceProtocol,
        appleLoginService: AppleLoginServiceProtocol,
        authService: AuthServiceProtocol,
        authTokenStore: AuthTokenStoreProtocol = AuthTokenStore(),
        authSessionStore: AuthSessionStoreProtocol = AuthSessionStore()
    ) {
        self.kakaoLoginService = kakaoLoginService
        self.googleLoginService = googleLoginService
        self.appleLoginService = appleLoginService
        self.authService = authService
        self.authTokenStore = authTokenStore
        self.authSessionStore = authSessionStore
        self.scheduledDeletionAt = authSessionStore.scheduledDeletionAt()
    }

    // MARK: - 소셜 로그인

    func loginWithKakao() async {
        guard !isLoading else {
            return
        }

        state = .loading
        activeLoginProvider = .kakao
        defer { activeLoginProvider = nil }

        do {
            let providerToken = try await kakaoLoginService.login()
            state = try await requestSocialLogin(
                provider: .kakao,
                providerToken: providerToken
            )
        } catch {
            state = Self.loginFailure(from: error)
        }
    }

    func loginWithGoogle() async {
        guard !isLoading else {
            return
        }

        state = .loading
        activeLoginProvider = .google
        defer { activeLoginProvider = nil }

        do {
            let providerToken = try await googleLoginService.login()
            state = try await requestSocialLogin(
                provider: .google,
                providerToken: providerToken
            )
        } catch {
            state = Self.loginFailure(from: error)
        }
    }

    func loginWithApple() async {
        guard !isLoading else {
            return
        }

        state = .loading
        activeLoginProvider = .apple
        defer { activeLoginProvider = nil }

        do {
            let providerToken = try await appleLoginService.login()
            state = try await requestSocialLogin(
                provider: .apple,
                providerToken: providerToken
            )
        } catch {
            state = Self.loginFailure(from: error)
        }
    }

    func socialLogin(
        provider: SocialProvider,
        providerToken: String
    ) async {
        guard !isLoading else {
            return
        }

        state = .loading
        activeLoginProvider = provider
        defer { activeLoginProvider = nil }

        do {
            state = try await requestSocialLogin(
                provider: provider,
                providerToken: providerToken
            )
        } catch {
            state = Self.loginFailure(from: error)
        }
    }

    // MARK: - 상태 초기화

    func resetState() {
        accountRecoveryErrorMessage = nil
        activeLoginProvider = nil
        state = .idle
    }

    // MARK: - 세션 복원

    func restoreSession() async {
        guard state == .idle,
              let memberStatus = authSessionStore.memberStatus() else {
            return
        }

        switch memberStatus {
        case .pendingOnboarding, .active:
            await restoreAuthenticatedSession(
                memberStatus: memberStatus
            )

        case .withdrawn:
            restoreAccountRecoverySession()

        case .suspended, .anonymized:
            clearLocalSession()
        }
    }

    // MARK: - 계정 설정 완료

    func completeAccountSetup() {
        guard state == .success(.accountSetup) else {
            return
        }

        authSessionStore.saveMemberStatus(.active)
        state = .success(.main)
    }

    // MARK: - 계정 복구

    func restoreAccount() async {
        guard !isRecoveringAccount else {
            return
        }

        isRecoveringAccount = true
        accountRecoveryErrorMessage = nil
        defer { isRecoveringAccount = false }

        do {
            guard let restoreToken = try authTokenStore.restoreToken(),
                  !restoreToken.isEmpty else {
                throw LoginViewModelError.missingRestoreToken
            }

            let result = try await authService.restore(
                restoreToken: restoreToken
            )

            guard result.memberStatus == .active else {
                throw LoginViewModelError.unexpectedMemberStatus
            }
            guard !result.accessToken.isEmpty,
                  !result.refreshToken.isEmpty else {
                throw LoginViewModelError.missingServiceTokens
            }

            try authTokenStore.replaceWithSession(
                accessToken: result.accessToken,
                refreshToken: result.refreshToken
            )
            authSessionStore.saveMemberStatus(.active)
            authSessionStore.saveScheduledDeletionAt(nil)
            scheduledDeletionAt = nil
            printSessionTokenStorageStatus()
            state = .success(.main)
        } catch {
            accountRecoveryErrorMessage = error.localizedDescription
        }
    }

    func cancelAccountRecovery() {
        accountRecoveryErrorMessage = nil
        clearLocalSession()
    }

    // MARK: - 로그아웃 및 탈퇴

    func logout() async throws {
        try await authService.logout()
        try authTokenStore.clearSession()
        authSessionStore.clear()
        printSessionTokenDeletionStatus()
        state = .idle
    }

    func completeAccountWithdrawal() {
        clearLocalSession()
        printSessionTokenDeletionStatus()
    }

    // MARK: - 토큰 재발급

    func reissueTokens() async throws {
        if let reissueTask {
            return try await reissueTask.value
        }

        let task = Task { [authService, authTokenStore] in
            guard let refreshToken = try authTokenStore.refreshToken(),
                  !refreshToken.isEmpty else {
                throw LoginViewModelError.missingRefreshToken
            }

            #if DEBUG
            let previousAccessToken = try? authTokenStore.accessToken()
            #endif

            let result = try await authService.reissue(
                refreshToken: refreshToken
            )

            guard !result.accessToken.isEmpty,
                  !result.refreshToken.isEmpty else {
                throw LoginViewModelError.missingServiceTokens
            }

            try authTokenStore.replaceWithSession(
                accessToken: result.accessToken,
                refreshToken: result.refreshToken
            )

            #if DEBUG
            do {
                let storedAccessToken = try authTokenStore.accessToken()
                let storedRefreshToken = try authTokenStore.refreshToken()

                print("""
                [TokenRotation]
                accessToken 교체: \(previousAccessToken != storedAccessToken && storedAccessToken?.isEmpty == false)
                refreshToken 교체: \(refreshToken != storedRefreshToken && storedRefreshToken?.isEmpty == false)
                """)
            } catch {
                print("[TokenRotation] Keychain 토큰 교체 상태 확인 실패")
            }
            #endif
        }

        reissueTask = task
        defer { reissueTask = nil }

        do {
            try await task.value
        } catch {
            if Self.requiresLoginAfterReissueFailure(error) {
                try? authTokenStore.clearSession()
                authSessionStore.clear()
                state = .idle
            }

            throw error
        }
    }

    // MARK: - 오류 표시 값

    var errorMessage: String? {
        guard case .failure(let failure) = state else {
            return nil
        }

        return failure.message
    }

    var errorTitle: String {
        guard case .failure(let failure) = state else {
            return "로그인에 실패했습니다."
        }

        return failure.title
    }

    // MARK: - 로그인 응답 처리

    private func requestSocialLogin(
        provider: SocialProvider,
        providerToken: String
    ) async throws -> LoginViewState {
        let result = try await authService.socialLogin(
            provider: provider,
            providerToken: providerToken
        )

        return try makeSuccessState(from: result)
    }

    private func makeSuccessState(
        from result: SocialLoginResultDTO
    ) throws -> LoginViewState {
        switch result.memberStatus {
        case .pendingOnboarding:
            let tokens = try Self.serviceTokens(from: result)
            try authTokenStore.replaceWithSession(
                accessToken: tokens.accessToken,
                refreshToken: tokens.refreshToken
            )
            authSessionStore.saveMemberStatus(.pendingOnboarding)
            authSessionStore.saveScheduledDeletionAt(nil)
            scheduledDeletionAt = nil
            printSessionTokenStorageStatus()
            return .success(.accountSetup)

        case .active:
            let tokens = try Self.serviceTokens(from: result)
            try authTokenStore.replaceWithSession(
                accessToken: tokens.accessToken,
                refreshToken: tokens.refreshToken
            )
            authSessionStore.saveMemberStatus(.active)
            authSessionStore.saveScheduledDeletionAt(nil)
            scheduledDeletionAt = nil
            printSessionTokenStorageStatus()
            return .success(.main)

        case .withdrawn:
            guard let restoreToken = result.restoreToken,
                  !restoreToken.isEmpty else {
                throw LoginViewModelError.missingRestoreToken
            }
            try authTokenStore.replaceWithRestoreToken(restoreToken)
            authSessionStore.saveMemberStatus(.withdrawn)
            authSessionStore.saveScheduledDeletionAt(
                result.scheduledDeletionAt
            )
            scheduledDeletionAt = result.scheduledDeletionAt
            return .success(.accountRecovery)

        case .suspended:
            clearLocalSession()
            throw LoginViewModelError.suspendedMember

        case .anonymized:
            clearLocalSession()
            throw LoginViewModelError.unexpectedMemberStatus
        }
    }

    // MARK: - 저장 세션 복원

    private func restoreAuthenticatedSession(
        memberStatus: MemberStatus
    ) async {
        guard let refreshToken = try? authTokenStore.refreshToken(),
              !refreshToken.isEmpty else {
            clearLocalSession()
            return
        }

        state = .loading

        do {
            try await reissueTokens()

            switch memberStatus {
            case .pendingOnboarding:
                state = .success(.accountSetup)
            case .active:
                state = .success(.main)
            case .withdrawn, .suspended, .anonymized:
                clearLocalSession()
            }

            #if DEBUG
            print("""
            [SessionRestore]
            memberStatus: \(memberStatus.rawValue)
            restored: true
            """)
            #endif
        } catch {
            if state != .idle {
                state = .failure(
                    .failed("로그인 상태를 복원하지 못했습니다. 다시 시도해주세요.")
                )
            }
        }
    }

    private func restoreAccountRecoverySession() {
        guard let restoreToken = try? authTokenStore.restoreToken(),
              !restoreToken.isEmpty else {
            clearLocalSession()
            return
        }

        scheduledDeletionAt = authSessionStore.scheduledDeletionAt()
        state = .success(.accountRecovery)
    }

    private func clearLocalSession() {
        try? authTokenStore.clearAll()
        authSessionStore.clear()
        scheduledDeletionAt = nil
        accountRecoveryErrorMessage = nil
        state = .idle
    }

    // MARK: - 토큰 검증

    private static func serviceTokens(
        from result: SocialLoginResultDTO
    ) throws -> (accessToken: String, refreshToken: String) {
        guard let accessToken = result.accessToken,
              !accessToken.isEmpty,
              let refreshToken = result.refreshToken,
              !refreshToken.isEmpty else {
            throw LoginViewModelError.missingServiceTokens
        }

        return (accessToken, refreshToken)
    }

    // MARK: - 디버그 로그

    private func printSessionTokenStorageStatus() {
        #if DEBUG
        let accessToken = try? authTokenStore.accessToken()
        let refreshToken = try? authTokenStore.refreshToken()

        print("""
        [Keychain]
        accessToken 저장: \(accessToken?.isEmpty == false)
        refreshToken 저장: \(refreshToken?.isEmpty == false)
        """)
        #endif
    }

    private func printSessionTokenDeletionStatus() {
        #if DEBUG
        do {
            let accessToken = try authTokenStore.accessToken()
            let refreshToken = try authTokenStore.refreshToken()

            print("""
            [Keychain]
            accessToken 삭제: \(accessToken == nil)
            refreshToken 삭제: \(refreshToken == nil)
            """)
        } catch {
            print("[Keychain] 토큰 삭제 상태 확인 실패")
        }
        #endif
    }

    // MARK: - 오류 판별

    private static func requiresLoginAfterReissueFailure(
        _ error: Error
    ) -> Bool {
        guard let networkError = error as? NetworkError else {
            return false
        }

        switch networkError {
        case .server(let statusCode, _, _):
            return statusCode == 401 || statusCode == 403
        case .transport, .decoding, .emptyResult:
            return false
        }
    }

    private static func loginFailure(from error: Error) -> LoginViewState {
        let error = error as NSError

        let isCancelled = switch (error.domain, error.code) {
        case ("KakaoSDKCommon.SdkError", 0),
             ("com.google.GIDSignIn", -5),
             ("com.apple.AuthenticationServices.AuthorizationError", 1000),
             ("com.apple.AuthenticationServices.AuthorizationError", 1001):
            true
        default:
            false
        }

        return .failure(
            isCancelled ? .cancelled : .failed(error.localizedDescription)
        )
    }

}

// MARK: - 로그인 ViewModel 오류

private enum LoginViewModelError: LocalizedError {
    case missingServiceTokens
    case missingRefreshToken
    case missingRestoreToken
    case suspendedMember
    case unexpectedMemberStatus

    var errorDescription: String? {
        switch self {
        case .missingServiceTokens:
            return "로그인 토큰을 확인할 수 없습니다. 다시 시도해주세요."
        case .missingRefreshToken:
            return "토큰을 재발급할 수 없습니다. 다시 로그인해주세요."
        case .missingRestoreToken:
            return "계정 복구 정보를 확인할 수 없습니다. 다시 로그인해주세요."
        case .suspendedMember:
            return "이용이 정지된 계정입니다."
        case .unexpectedMemberStatus:
            return "로그인 상태를 확인할 수 없습니다. 다시 시도해주세요."
        }
    }
}
