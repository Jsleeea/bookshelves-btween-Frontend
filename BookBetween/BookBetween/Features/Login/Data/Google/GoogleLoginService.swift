//
//  GoogleLoginService.swift
//  BookBetween
//

import GoogleSignIn
import UIKit

@MainActor
protocol GoogleLoginServiceProtocol {
    func login() async throws -> String
}

@MainActor
final class GoogleLoginService: GoogleLoginServiceProtocol {
    func login() async throws -> String {
        let presentingViewController = try presentingViewController()
        let result = try await GIDSignIn.sharedInstance.signIn(
            withPresenting: presentingViewController
        )

        guard let idToken = result.user.idToken?.tokenString,
              !idToken.isEmpty else {
            throw GoogleLoginServiceError.missingIDToken
        }

        return idToken
    }

    private func presentingViewController() throws -> UIViewController {
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
              let rootViewController = windowScene.windows
            .first(where: \.isKeyWindow)?.rootViewController else {
            throw GoogleLoginServiceError.missingPresentingViewController
        }

        return topViewController(from: rootViewController)
    }

    private func topViewController(
        from viewController: UIViewController
    ) -> UIViewController {
        if let presentedViewController = viewController.presentedViewController {
            return topViewController(from: presentedViewController)
        }

        if let navigationController = viewController as? UINavigationController,
           let visibleViewController = navigationController.visibleViewController {
            return topViewController(from: visibleViewController)
        }

        if let tabBarController = viewController as? UITabBarController,
           let selectedViewController = tabBarController.selectedViewController {
            return topViewController(from: selectedViewController)
        }

        return viewController
    }
}

nonisolated enum GoogleLoginServiceError: LocalizedError {
    case missingIDToken
    case missingPresentingViewController

    var errorDescription: String? {
        switch self {
        case .missingIDToken:
            return "구글 로그인 토큰을 확인할 수 없습니다. 다시 시도해주세요."
        case .missingPresentingViewController:
            return "구글 로그인 화면을 열 수 없습니다. 다시 시도해주세요."
        }
    }
}
