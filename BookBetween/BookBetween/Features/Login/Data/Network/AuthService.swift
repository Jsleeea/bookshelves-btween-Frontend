//
//  AuthService.swift
//  BookBetween
//

import Foundation
import Moya

// MARK: - 인증 서비스 규약

protocol AuthServiceProtocol {
    func socialLogin(
        provider: SocialProvider,
        providerToken: String
    ) async throws -> SocialLoginResultDTO
    func logout() async throws
    func reissue(refreshToken: String) async throws -> TokenReissueResultDTO
    func restore(
        restoreToken: String
    ) async throws -> AccountRestoreResultDTO
}

final class AuthService: AuthServiceProtocol {
    // MARK: - 의존성

    private let baseURL: URL
    private let provider: MoyaProvider<AuthTarget>

    // MARK: - 초기화

    init(configuration: NetworkConfiguration) {
        self.baseURL = configuration.baseURL
        self.provider = MoyaProvider<AuthTarget>(
            plugins: [
                AuthorizationPlugin(accessToken: configuration.accessToken)
            ]
        )
    }

    init(baseURL: URL, provider: MoyaProvider<AuthTarget>) {
        self.baseURL = baseURL
        self.provider = provider
    }

    // MARK: - 인증 요청

    func socialLogin(
        provider: SocialProvider,
        providerToken: String
    ) async throws -> SocialLoginResultDTO {
        let request = SocialLoginRequestDTO(
            provider: provider,
            providerToken: providerToken
        )

        do {
            let response = try await self.provider.requestAsync(
                AuthTarget(
                    baseURL: self.baseURL,
                    endpoint: .socialLogin(request)
                )
            )
            let result = try response.decodePayload(
                SocialLoginResultDTO.self
            )

            return result
        } catch let error as MoyaError {
            throw NetworkError.transport(error)
        }
    }

    func logout() async throws {
        do {
            let response = try await provider.requestAsync(
                AuthTarget(
                    baseURL: baseURL,
                    endpoint: .logout
                )
            )
            let _: APIEmptyResultDTO = try response.decodePayload(
                APIEmptyResultDTO.self
            )

        } catch let error as MoyaError {
            throw NetworkError.transport(error)
        }
    }

    func reissue(
        refreshToken: String
    ) async throws -> TokenReissueResultDTO {
        let request = TokenReissueRequestDTO(
            refreshToken: refreshToken
        )

        do {
            let response = try await provider.requestAsync(
                AuthTarget(
                    baseURL: baseURL,
                    endpoint: .reissue(request)
                )
            )
            let result = try response.decodePayload(
                TokenReissueResultDTO.self
            )

            return result
        } catch let error as MoyaError {
            throw NetworkError.transport(error)
        }
    }

    func restore(
        restoreToken: String
    ) async throws -> AccountRestoreResultDTO {
        let request = AccountRestoreRequestDTO(
            restoreToken: restoreToken
        )

        do {
            let response = try await provider.requestAsync(
                AuthTarget(
                    baseURL: baseURL,
                    endpoint: .restore(request)
                )
            )
            let result = try response.decodePayload(
                AccountRestoreResultDTO.self
            )

            return result
        } catch let error as MoyaError {
            throw NetworkError.transport(error)
        }
    }
}
