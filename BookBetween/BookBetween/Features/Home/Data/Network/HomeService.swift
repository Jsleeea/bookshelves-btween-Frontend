//
//  HomeService.swift
//  BookBetween
//

import Foundation
import Moya

protocol HomeServiceProtocol {
    func fetchHome() async throws -> Home
}

final class HomeService: HomeServiceProtocol {
    private let baseURL: URL
    private let provider: MoyaProvider<HomeTarget>

    init(configuration: NetworkConfiguration) {
        self.baseURL = configuration.baseURL
        self.provider = MoyaProvider<HomeTarget>(
            plugins: [
                AuthorizationPlugin(accessToken: configuration.accessToken)
            ]
        )
    }

    init(baseURL: URL, provider: MoyaProvider<HomeTarget>) {
        self.baseURL = baseURL
        self.provider = provider
    }

    static func stubbed() -> HomeService {
        let baseURL = URL(string: "https://stub.bookbetween.local")!
        let provider = MoyaProvider<HomeTarget>(
            stubClosure: { _ in .immediate }
        )
        return HomeService(baseURL: baseURL, provider: provider)
    }

    func fetchHome() async throws -> Home {
        do {
            let response = try await provider.requestAsync(
                HomeTarget(baseURL: baseURL, endpoint: .fetchHome)
            )
            let result = try response.decodePayload(HomeResultDTO.self)
            return try result.toDomain()
        } catch let error as MoyaError {
            throw NetworkError.transport(error)
        }
    }
}
