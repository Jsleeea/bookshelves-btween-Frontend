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
                title: "서비스 이용약관",
                content: """
                제1조 목적
                본 약관은 책장사이가 제공하는 서비스의 이용 조건과 절차를 규정합니다.

                제2조 회원가입 및 계정
                1. 이용자는 소셜 로그인을 통해 가입할 수 있습니다.
                2. 타인의 계정을 이용하거나 공유해서는 안 됩니다.
                """,
                type: .service,
                version: "1.0",
                isRequired: true
            ),
            OnboardingTermDTO(
                id: 2,
                title: "개인정보 수집 및 이용 동의",
                content: """
                책장사이는 서비스 제공에 필요한 최소한의 개인정보를 수집·이용합니다.

                1. 수집·이용 목적
                - 소셜 로그인 및 회원 식별
                - 회원가입, 계정 관리 및 계정 복구

                2. 수집 항목
                - 소셜 로그인 제공자
                - 소셜 계정 고유 식별값

                서비스 이용 과정에서 아래 정보가 추가로 생성·저장될 수 있습니다.
                """,
                type: .privacy,
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
