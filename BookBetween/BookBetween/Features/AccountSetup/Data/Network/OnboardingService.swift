//
//  OnboardingService.swift
//  BookBetween
//

import Foundation
import Moya

protocol OnboardingServiceProtocol {
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
}
