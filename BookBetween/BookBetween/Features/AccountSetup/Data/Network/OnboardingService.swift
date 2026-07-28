//
//  OnboardingService.swift
//  BookBetween
//

import Foundation
import Moya

protocol OnboardingServiceProtocol {
    func fetchTerms() async throws -> [OnboardingTermDTO]
    func completeOnboarding(
        request: OnboardingRequestDTO
    ) async throws -> OnboardingResultDTO
}

final class OnboardingService: OnboardingServiceProtocol {
    private let baseURL: URL
    private let provider: MoyaProvider<OnboardingTarget>
    private let requestExecutor: AuthenticatedRequestExecutor

    init(configuration: NetworkConfiguration) {
        self.baseURL = configuration.baseURL
        self.provider = MoyaProvider<OnboardingTarget>(
            plugins: [
                AuthorizationPlugin(
                    accessToken: configuration.accessToken
                )
            ]
        )
        self.requestExecutor = AuthenticatedRequestExecutor(
            reissueTokens: configuration.reissueTokens
        )
    }

    func completeOnboarding(
        request: OnboardingRequestDTO
    ) async throws -> OnboardingResultDTO {
        try await requestExecutor.execute {
            do {
                let response = try await provider.requestAsync(
                    OnboardingTarget(
                        baseURL: baseURL,
                        endpoint: .complete(request)
                    )
                )
                let result = try response.decodePayload(
                    OnboardingResultDTO.self
                )

                #if DEBUG
                print("""
                [Onboarding]
                URL: \(response.request?.url?.absoluteString ?? "확인 불가")
                HTTP: \(response.statusCode)
                memberStatus: \(result.memberStatus.rawValue)
                """)
                #endif

                return result
            } catch let error as MoyaError {
                throw NetworkError.transport(error)
            }
        }
    }

    func fetchTerms() async throws -> [OnboardingTermDTO] {
        do {
            let response = try await provider.requestAsync(
                OnboardingTarget(
                    baseURL: baseURL,
                    endpoint: .terms
                )
            )
            let terms = try response.decodePayload(
                [OnboardingTermDTO].self
            )

            #if DEBUG
            print("""
            [OnboardingTerms]
            URL: \(response.request?.url?.absoluteString ?? "확인 불가")
            HTTP: \(response.statusCode)
            termsCount: \(terms.count)
            """)
            #endif

            return terms
        } catch let error as MoyaError {
            throw NetworkError.transport(error)
        }
    }
}

final class PreviewOnboardingService: OnboardingServiceProtocol {
    func fetchTerms() async throws -> [OnboardingTermDTO] {
        [
            OnboardingTermDTO(
                id: 1,
                title: "이용약관",
                content: "",
                version: "1.0",
                isRequired: true
            ),
            OnboardingTermDTO(
                id: 2,
                title: "개인정보 처리방침",
                content: "",
                version: "1.0",
                isRequired: true
            )
        ]
    }

    func completeOnboarding(
        request: OnboardingRequestDTO
    ) async throws -> OnboardingResultDTO {
        throw CancellationError()
    }
}
