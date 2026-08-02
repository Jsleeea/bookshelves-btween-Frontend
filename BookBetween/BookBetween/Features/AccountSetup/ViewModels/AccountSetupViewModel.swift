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
    private(set) var terms: [OnboardingTermDTO] = []
    private(set) var requiredTermsIds: [Int] = []
    private(set) var hasLoadedTerms = false
    private(set) var isLoadingTerms = false
    private(set) var termsErrorMessage: String?

    var isLoading: Bool {
        state == .loading
    }

    var errorMessage: String? {
        guard case .failure(let message) = state else {
            return nil
        }

        return message
    }

    var serviceTerm: OnboardingTermDTO? {
        terms.first { $0.type == .service }
    }

    var privacyTerm: OnboardingTermDTO? {
        terms.first { $0.type == .privacy }
    }

    func agreedTermsIds(
        isServiceTermAgreed: Bool,
        isPrivacyTermAgreed: Bool
    ) -> [Int] {
        var agreedTermsIds: [Int] = []

        if isServiceTermAgreed,
           let serviceTerm {
            agreedTermsIds.append(serviceTerm.id)
        }

        if isPrivacyTermAgreed,
           let privacyTerm {
            agreedTermsIds.append(privacyTerm.id)
        }

        return agreedTermsIds.sorted()
    }

    func hasAgreedToAllRequiredTerms(
        agreedTermsIds: [Int]
    ) -> Bool {
        guard hasLoadedTerms,
              !requiredTermsIds.isEmpty else {
            return false
        }

        return Set(requiredTermsIds).isSubset(of: Set(agreedTermsIds))
    }

    init(onboardingService: OnboardingServiceProtocol) {
        self.onboardingService = onboardingService
    }

    func fetchTerms() async {
        guard !hasLoadedTerms,
              !isLoadingTerms else {
            return
        }

        isLoadingTerms = true
        termsErrorMessage = nil
        defer { isLoadingTerms = false }

        do {
            terms = try await onboardingService.fetchTerms()
            requiredTermsIds = terms
                .filter(\.isRequired)
                .map(\.id)
                .sorted()
            hasLoadedTerms = true
        } catch {
            termsErrorMessage = error.localizedDescription
        }
    }

    func completeOnboarding(
        nickname: GeneratedNickname,
        categoryIds: [Int],
        agreedTermsIds: [Int]
    ) async {
        guard !isLoading else {
            return
        }

        guard hasAgreedToAllRequiredTerms(
            agreedTermsIds: agreedTermsIds
        ) else {
            state = .failure(
                AccountSetupViewModelError.missingRequiredTerms
                    .localizedDescription
            )
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

    func resetTermsError() {
        termsErrorMessage = nil
    }
}

private enum AccountSetupViewModelError: LocalizedError {
    case invalidMemberStatus
    case missingRequiredTerms

    var errorDescription: String? {
        switch self {
        case .invalidMemberStatus:
            return "온보딩 완료 상태를 확인할 수 없습니다."
        case .missingRequiredTerms:
            return "필수 약관에 모두 동의해주세요."
        }
    }
}
