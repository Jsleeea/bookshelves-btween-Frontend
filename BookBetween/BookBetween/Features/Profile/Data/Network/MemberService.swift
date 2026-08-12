//
//  MemberService.swift
//  BookBetween
//

import Foundation
import Moya

// MARK: - 회원 서비스 인터페이스

protocol MemberServiceProtocol {
    func fetchMyProfile() async throws -> MemberProfile
    func updateMyProfile(
        request: MemberProfileUpdateRequestDTO
    ) async throws -> MemberProfile
    func withdrawMyAccount() async throws -> MemberWithdrawalResultDTO
}

// MARK: - 회원 네트워크 서비스

final class MemberService: MemberServiceProtocol {
    // MARK: - 네트워크 설정

    private let baseURL: URL
    private let provider: MoyaProvider<MemberTarget>
    private let requestExecutor: AuthenticatedRequestExecutor

    // MARK: - 초기화

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

    // MARK: - 내 회원 정보 조회

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

    // MARK: - 회원 정보 수정

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

    // MARK: - 회원 탈퇴

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
