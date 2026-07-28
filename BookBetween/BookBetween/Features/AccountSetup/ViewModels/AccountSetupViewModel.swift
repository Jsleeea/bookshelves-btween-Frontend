//
//  AccountSetupViewModel.swift
//  BookBetween
//

import Foundation
import Observation

enum AccountSetupViewState: Equatable {
    case idle
    case loading
    case success
    case failure(String)
}

@MainActor
@Observable
final class AccountSetupViewModel {
    private let onboardingService: OnboardingServiceProtocol

    private(set) var state: AccountSetupViewState = .idle

    var isLoading: Bool {
        state == .loading
    }

    var errorMessage: String? {
        guard case .failure(let message) = state else {
            return nil
        }

        return message
    }

    init(onboardingService: OnboardingServiceProtocol) {
        self.onboardingService = onboardingService
    }

    func completeOnboarding(
        nickname: GeneratedNickname,
        categoryIds: [Int],
        agreedTermsIds: [Int]
    ) async {
        guard !isLoading else {
            return
        }

        state = .loading

        let request = OnboardingRequestDTO(
            nicknameNoun: nickname.noun,
            nicknameModifier: nickname.modifier,
            nicknameAnimal: nickname.animal,
            profileBackgroundColor: nickname.profileBackgroundColor,
            categoryIds: categoryIds,
            agreedTermsIds: agreedTermsIds
        )

        do {
            let result = try await onboardingService.completeOnboarding(
                request: request
            )

            guard result.memberStatus == .active else {
                throw AccountSetupViewModelError.invalidMemberStatus
            }

            state = .success
        } catch {
            state = .failure(error.localizedDescription)
        }
    }

    func resetState() {
        state = .idle
    }
}

private enum AccountSetupViewModelError: LocalizedError {
    case invalidMemberStatus

    var errorDescription: String? {
        switch self {
        case .invalidMemberStatus:
            return "온보딩 완료 상태를 확인할 수 없습니다."
        }
    }
}
