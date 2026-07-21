//
//  BookService.swift
//  BookBetween
//

import Foundation
import Moya

protocol BookServiceProtocol {
    func searchBooks(query: String, page: Int, size: Int) async throws -> BookSearchPage
    func fetchBookDetail(isbn: String) async throws -> BookDetail
    func fetchRecentSearches() async throws -> [RecentSearchItem]
}

final class BookService: BookServiceProtocol {
    private let baseURL: URL
    private let provider: MoyaProvider<BookTarget>

    init(configuration: NetworkConfiguration) {
        self.baseURL = configuration.baseURL
        self.provider = MoyaProvider<BookTarget>(
            plugins: [
                AuthorizationPlugin(accessToken: configuration.accessToken)
            ]
        )
    }

    init(baseURL: URL, provider: MoyaProvider<BookTarget>) {
        self.baseURL = baseURL
        self.provider = provider
    }

    static func stubbed() -> BookService {
        let baseURL = URL(string: "https://stub.bookbetween.local")!
        let provider = MoyaProvider<BookTarget>(
            stubClosure: { _ in .immediate }
        )
        return BookService(baseURL: baseURL, provider: provider)
    }

    func searchBooks(
        query: String,
        page: Int = 1,
        size: Int = 15
    ) async throws -> BookSearchPage {
        do {
            let response = try await provider.requestAsync(
                BookTarget(
                    baseURL: baseURL,
                    endpoint: .search(query: query, page: page, size: size)
                )
            )
            return try response.decodePayload(BookSearchResultDTO.self).toDomain()
        } catch let error as MoyaError {
            throw NetworkError.transport(error)
        }
    }

    func fetchBookDetail(isbn: String) async throws -> BookDetail {
        do {
            let response = try await provider.requestAsync(
                BookTarget(baseURL: baseURL, endpoint: .detail(isbn: isbn))
            )
            return try response.decodePayload(BookDetailResultDTO.self).toDomain()
        } catch let error as MoyaError {
            throw NetworkError.transport(error)
        }
    }

    func fetchRecentSearches() async throws -> [RecentSearchItem] {
        do {
            let response = try await provider.requestAsync(
                BookTarget(baseURL: baseURL, endpoint: .recentSearches)
            )
            return try response.decodePayload(RecentSearchResultDTO.self).toDomain()
        } catch let error as MoyaError {
            throw NetworkError.transport(error)
        }
    }
}
