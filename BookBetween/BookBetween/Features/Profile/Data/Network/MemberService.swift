//
//  MemberService.swift
//  BookBetween
//

import Foundation
import Moya

protocol MemberServiceProtocol {
    func fetchMyProfile() async throws -> MemberProfile
    func updateMyProfile(
        request: MemberProfileUpdateRequestDTO
    ) async throws -> MemberProfile
    func withdrawMyAccount() async throws -> MemberWithdrawalResultDTO
}

final class MemberService: MemberServiceProtocol {
    private let baseURL: URL
    private let provider: MoyaProvider<MemberTarget>
    private let requestExecutor: AuthenticatedRequestExecutor

    init(configuration: NetworkConfiguration) {
        self.baseURL = configuration.baseURL
        self.provider = MoyaProvider<MemberTarget>(
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

    func fetchMyProfile() async throws -> MemberProfile {
        try await requestExecutor.execute {
            do {
                let response = try await provider.requestAsync(
                    MemberTarget(
                        baseURL: baseURL,
                        endpoint: .me
                    )
                )
                let result = try response.decodePayload(
                    MemberProfileResultDTO.self
                )

                #if DEBUG
                print("""
                [MemberProfile]
                URL: \(response.request?.url?.absoluteString ?? "확인 불가")
                HTTP: \(response.statusCode)
                """)
                #endif

                return result.toDomain()
            } catch let error as MoyaError {
                throw NetworkError.transport(error)
            }
        }
    }

    func updateMyProfile(
        request: MemberProfileUpdateRequestDTO
    ) async throws -> MemberProfile {
        try await requestExecutor.execute {
            do {
                let response = try await provider.requestAsync(
                    MemberTarget(
                        baseURL: baseURL,
                        endpoint: .updateMe(request)
                    )
                )
                let result = try response.decodePayload(
                    MemberProfileResultDTO.self
                )

                #if DEBUG
                print("""
                [MemberProfileUpdate]
                URL: \(response.request?.url?.absoluteString ?? "확인 불가")
                HTTP: \(response.statusCode)
                """)
                #endif

                return result.toDomain()
            } catch let error as MoyaError {
                throw NetworkError.transport(error)
            }
        }
    }

    func withdrawMyAccount() async throws -> MemberWithdrawalResultDTO {
        try await requestExecutor.execute {
            do {
                let response = try await provider.requestAsync(
                    MemberTarget(
                        baseURL: baseURL,
                        endpoint: .withdraw
                    )
                )
                let result = try response.decodePayload(
                    MemberWithdrawalResultDTO.self
                )

                #if DEBUG
                print("""
                [MemberWithdrawal]
                URL: \(response.request?.url?.absoluteString ?? "확인 불가")
                HTTP: \(response.statusCode)
                scheduledDeletionAt: \(result.scheduledDeletionAt)
                """)
                #endif

                return result
            } catch let error as MoyaError {
                throw NetworkError.transport(error)
            }
        }
    }
}
