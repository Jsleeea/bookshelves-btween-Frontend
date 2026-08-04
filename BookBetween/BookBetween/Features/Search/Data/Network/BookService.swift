//
//  BookService.swift
//  BookBetween
//

import Foundation
import Moya

protocol BookServiceProtocol {
    func searchBooks(query: String, page: Int, size: Int) async throws -> BookSearchPage
    func searchBooks(
        query: String,
        page: Int,
        size: Int,
        saveRecent: Bool
    ) async throws -> BookSearchPage
    func fetchBookDetail(isbn: String) async throws -> BookDetail
    func fetchRecentSearches() async throws -> [RecentSearchItem]
    func upsertMemberBook(
        isbn: String,
        progress: Int,
        rating: Double?,
        memo: String?
    ) async throws
    func fetchMemberBooks(status: String, page: Int, size: Int) async throws -> [UserBookRecord]
    func deleteMemberBook(isbn: String) async throws
    func fetchReadingStatistics(
        year: Int?,
        month: Int?
    ) async throws -> ReadingStatisticsResultDTO
    func fetchReadingCalendar(
        year: Int,
        month: Int
    ) async throws -> ReadingCalendarResultDTO
}

final class BookService: BookServiceProtocol {
    private let baseURL: URL
    private let provider: MoyaProvider<BookTarget>
    private let requestExecutor: AuthenticatedRequestExecutor

    init(configuration: NetworkConfiguration) {
        self.baseURL = configuration.baseURL
        self.provider = MoyaProvider<BookTarget>(
            plugins: [
                AuthorizationPlugin(accessToken: configuration.accessToken)
            ]
        )
        self.requestExecutor = AuthenticatedRequestExecutor(
            reissueTokens: configuration.reissueTokens
        )
    }

    init(baseURL: URL, provider: MoyaProvider<BookTarget>) {
        self.baseURL = baseURL
        self.provider = provider
        self.requestExecutor = AuthenticatedRequestExecutor(
            reissueTokens: nil
        )
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
        try await searchBooks(
            query: query,
            page: page,
            size: size,
            saveRecent: true
        )
    }

    func searchBooks(
        query: String,
        page: Int,
        size: Int,
        saveRecent: Bool
    ) async throws -> BookSearchPage {
        try await requestExecutor.execute {
            do {
                let response = try await provider.requestAsync(
                    BookTarget(
                        baseURL: baseURL,
                        endpoint: .search(
                            query: query,
                            page: page,
                            size: size,
                            saveRecent: saveRecent
                        )
                    )
                )
                return try response.decodePayload(
                    BookSearchResultDTO.self
                ).toDomain()
            } catch let error as MoyaError {
                throw NetworkError.transport(error)
            }
        }
    }

    func fetchBookDetail(isbn: String) async throws -> BookDetail {
        try await requestExecutor.execute {
            do {
                let response = try await provider.requestAsync(
                    BookTarget(
                        baseURL: baseURL,
                        endpoint: .detail(isbn: isbn)
                    )
                )
                return try response.decodePayload(
                    BookDetailResultDTO.self
                ).toDomain()
            } catch let error as MoyaError {
                throw NetworkError.transport(error)
            }
        }
    }

    func fetchRecentSearches() async throws -> [RecentSearchItem] {
        try await requestExecutor.execute {
            do {
                let response = try await provider.requestAsync(
                    BookTarget(
                        baseURL: baseURL,
                        endpoint: .recentSearches
                    )
                )
                return try response.decodePayload(
                    RecentSearchResultDTO.self
                ).toDomain()
            } catch let error as MoyaError {
                throw NetworkError.transport(error)
            }
        }
    }

    func upsertMemberBook(
        isbn: String,
        progress: Int,
        rating: Double?,
        memo: String?
    ) async throws {
        try await requestExecutor.execute {
            do {
                let request = MemberBookUpsertRequestDTO(
                    progress: progress,
                    rating: rating,
                    memo: memo
                )
                let response = try await provider.requestAsync(
                    BookTarget(
                        baseURL: baseURL,
                        endpoint: .upsertMemberBook(
                            isbn: isbn,
                            request: request
                        )
                    )
                )
                _ = try response.decodePayload(
                    MemberBookUpsertResultDTO.self
                )
            } catch let error as MoyaError {
                throw NetworkError.transport(error)
            }
        }
    }

    func fetchMemberBooks(status: String, page: Int, size: Int) async throws -> [UserBookRecord] {
        try await requestExecutor.execute {
            do {
                let response = try await provider.requestAsync(
                    BookTarget(
                        baseURL: baseURL,
                        endpoint: .memberBooks(status: status, page: page, size: size)
                    )
                )
                return try response.decodePayload(MemberBooksListDTO.self).toDomain()
            } catch let error as MoyaError {
                throw NetworkError.transport(error)
            }
        }
    }

    func deleteMemberBook(isbn: String) async throws {
        try await requestExecutor.execute {
            do {
                let response = try await provider.requestAsync(
                    BookTarget(
                        baseURL: baseURL,
                        endpoint: .deleteMemberBook(isbn: isbn)
                    )
                )
                try response.validateAPIResponse()
            } catch let error as MoyaError {
                throw NetworkError.transport(error)
            }
        }
    }

    func fetchReadingStatistics(
        year: Int? = nil,
        month: Int? = nil
    ) async throws -> ReadingStatisticsResultDTO {
        try await requestExecutor.execute {
            do {
                let response = try await provider.requestAsync(
                    BookTarget(
                        baseURL: baseURL,
                        endpoint: .readingStatistics(
                            year: year,
                            month: month
                        )
                    )
                )
                let result = try response.decodePayload(
                    ReadingStatisticsResultDTO.self
                )

                #if DEBUG
                print("""
                [ReadingStatistics]
                URL: \(response.request?.url?.absoluteString ?? "확인 불가")
                HTTP: \(response.statusCode)
                year: \(result.year), month: \(result.month)
                """)
                #endif

                return result
            } catch let error as MoyaError {
                throw NetworkError.transport(error)
            }
        }
    }

    func fetchReadingCalendar(
        year: Int,
        month: Int
    ) async throws -> ReadingCalendarResultDTO {
        try await requestExecutor.execute {
            do {
                let response = try await provider.requestAsync(
                    BookTarget(
                        baseURL: baseURL,
                        endpoint: .readingCalendar(
                            year: year,
                            month: month
                        )
                    )
                )
                let result = try response.decodePayload(
                    ReadingCalendarResultDTO.self
                )

                #if DEBUG
                print("""
                [ReadingCalendar]
                URL: \(response.request?.url?.absoluteString ?? "확인 불가")
                HTTP: \(response.statusCode)
                year: \(result.year), month: \(result.month)
                daysCount: \(result.days.count)
                """)
                #endif

                return result
            } catch let error as MoyaError {
                throw NetworkError.transport(error)
            }
        }
    }
}
