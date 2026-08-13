//
//  AppleLoginService.swift
//  BookBetween
//

import AuthenticationServices
import Foundation
import UIKit

// MARK: - Apple 로그인 서비스 규약

@MainActor
protocol AppleLoginServiceProtocol {
    func login() async throws -> String
}

@MainActor
final class AppleLoginService: NSObject, AppleLoginServiceProtocol {
    // MARK: - 상태

    private var continuation: CheckedContinuation<String, Error>?
    private var authorizationController: ASAuthorizationController?
    private var presentationWindow: ASPresentationAnchor?

    // MARK: - 로그인 요청

    func login() async throws -> String {
        guard continuation == nil else {
            throw AppleLoginServiceError.loginAlreadyInProgress
        }

        guard let presentationWindow = activePresentationWindow() else {
            throw AppleLoginServiceError.missingPresentationWindow
        }

        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            self.presentationWindow = presentationWindow

            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]

            let controller = ASAuthorizationController(
                authorizationRequests: [request]
            )
            controller.delegate = self
            controller.presentationContextProvider = self
            authorizationController = controller
            controller.performRequests()
        }
    }

    // MARK: - 화면 표시 대상

    private func activePresentationWindow() -> ASPresentationAnchor? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }?
            .windows
            .first { $0.isKeyWindow }
    }

    // MARK: - 로그인 완료 처리

    private func finish(with result: Result<String, Error>) {
        guard let continuation else {
            return
        }

        self.continuation = nil
        authorizationController = nil
        presentationWindow = nil

        switch result {
        case .success(let identityToken):
            continuation.resume(returning: identityToken)

        case .failure(let error):
            continuation.resume(throwing: error)
        }
    }
}

// MARK: - Apple 로그인 결과 처리

extension AppleLoginService: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let credential = authorization.credential
            as? ASAuthorizationAppleIDCredential else {
            finish(with: .failure(AppleLoginServiceError.invalidCredential))
            return
        }

        guard let identityTokenData = credential.identityToken,
              let identityToken = String(
                data: identityTokenData,
                encoding: .utf8
              ),
              !identityToken.isEmpty else {
            finish(with: .failure(AppleLoginServiceError.missingIdentityToken))
            return
        }

        finish(with: .success(identityToken))
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        finish(with: .failure(error))
    }
}

// MARK: - Apple 로그인 표시 환경

extension AppleLoginService: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(
        for controller: ASAuthorizationController
    ) -> ASPresentationAnchor {
        guard let presentationWindow else {
            preconditionFailure("Apple 로그인 화면을 표시할 UIWindow가 없습니다.")
        }

        return presentationWindow
    }
}

// MARK: - Apple 로그인 오류

nonisolated enum AppleLoginServiceError: LocalizedError {
    case loginAlreadyInProgress
    case missingPresentationWindow
    case invalidCredential
    case missingIdentityToken

    var errorDescription: String? {
        switch self {
        case .loginAlreadyInProgress:
            return "Apple 로그인이 이미 진행 중입니다."
        case .missingPresentationWindow:
            return "Apple 로그인 화면을 열 수 없습니다. 다시 시도해주세요."
        case .invalidCredential:
            return "Apple 로그인 정보를 확인할 수 없습니다. 다시 시도해주세요."
        case .missingIdentityToken:
            return "Apple 로그인 토큰을 확인할 수 없습니다. 다시 시도해주세요."
        }
    }
}
