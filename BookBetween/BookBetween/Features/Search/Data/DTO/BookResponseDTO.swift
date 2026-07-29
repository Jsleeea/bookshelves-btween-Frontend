//
//  BookResponseDTO.swift
//  BookBetween
//

import Foundation

struct MemberBookUpsertRequestDTO: Encodable {
    let progress: Int
    let rating: Double?
    let memo: String?
}

struct MemberBookUpsertResultDTO: Decodable {
    let memberBookHistory: MemberBookHistoryDTO?
}

struct MemberBookHistoryDTO: Decodable {
    let id: Int
}

struct BookSearchResultDTO: Decodable {
    let books: [BookSearchItemDTO]
    let page: Int
    let size: Int
    let hasNext: Bool
}

struct BookSearchItemDTO: Decodable {
    let isbn: String?
    let title: String
    let author: String
    let publisher: String?
    let publishedDate: String?
    let description: String?
    let coverImageUrl: String?
    let saveable: Bool

    private enum CodingKeys: String, CodingKey {
        case isbn
        case title
        case author
        case publisher
        case publishedDate
        case description
        case coverImageUrl
        case saveable
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        isbn = try container.decodeIfPresent(String.self, forKey: .isbn)
        title = try container.decodeIfPresent(String.self, forKey: .title)
            ?? "제목 정보 없음"
        author = try container.decodeIfPresent(String.self, forKey: .author)
            ?? "저자 미상"
        publisher = try container.decodeIfPresent(
            String.self,
            forKey: .publisher
        )
        publishedDate = try container.decodeIfPresent(
            String.self,
            forKey: .publishedDate
        )
        description = try container.decodeIfPresent(
            String.self,
            forKey: .description
        )
        coverImageUrl = try container.decodeIfPresent(
            String.self,
            forKey: .coverImageUrl
        )
        saveable = try container.decodeIfPresent(
            Bool.self,
            forKey: .saveable
        ) ?? false
    }
}

struct BookDetailResultDTO: Decodable {
    let book: BookDetailBookDTO
    let memberBook: BookDetailMemberBookDTO?
}

struct BookDetailBookDTO: Decodable {
    let id: Int?
    let isbn: String
    let title: String
    let author: String
    let publisher: String?
    let publishedDate: String?
    let description: String?
    let coverImageUrl: String?
    let kdcCode: String?
    let kdcName: String?
}

struct BookDetailMemberBookDTO: Decodable {
    let id: Int
    let progress: Int
    let rating: Double?
    let memo: String?
}

struct RecentSearchResultDTO: Decodable {
    let recentSearches: [RecentSearchItemDTO]
}

struct RecentSearchItemDTO: Decodable {
    let keyword: String
    let searchedAt: String
}

extension BookSearchResultDTO {
    func toDomain() -> BookSearchPage {
        BookSearchPage(
            books: books.map { item in
                BookSearchItem(
                    book: Book(
                        isbn: item.isbn,
                        title: item.title,
                        author: item.author,
                        publisher: item.publisher,
                        publishedDate: item.publishedDate,
                        description: item.description,
                        coverImageUrl: item.coverImageUrl
                    ),
                    isSaveable: item.saveable
                )
            },
            page: page,
            size: size,
            hasNext: hasNext
        )
    }
}

extension BookDetailResultDTO {
    func toDomain() -> BookDetail {
        let domainBook = Book(
            id: book.id,
            isbn: book.isbn,
            title: book.title,
            author: book.author,
            publisher: book.publisher,
            publishedDate: book.publishedDate,
            description: book.description,
            coverImageUrl: book.coverImageUrl,
            kdcCode: book.kdcCode,
            kdcName: book.kdcName
        )

        let record = memberBook.map { memberBook in
            UserBookRecord(
                id: memberBook.id,
                book: domainBook,
                progress: memberBook.progress,
                rating: memberBook.rating,
                memo: memberBook.memo
            )
        }

        return BookDetail(book: domainBook, memberBook: record)
    }
}

extension RecentSearchResultDTO {
    func toDomain() throws -> [RecentSearchItem] {
        try recentSearches.map { item in
            guard let searchedAt = RecentSearchDateParser.date(
                from: item.searchedAt
            ) else {
                throw BookDTOError.invalidDate(item.searchedAt)
            }

            return RecentSearchItem(
                keyword: item.keyword,
                searchedAt: searchedAt
            )
        }
    }
}

private enum RecentSearchDateParser {
    private static let fractionalSecondsFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]
        return formatter
    }()

    private static let standardFormatter = ISO8601DateFormatter()

    static func date(from value: String) -> Date? {
        fractionalSecondsFormatter.date(from: value)
            ?? standardFormatter.date(from: value)
    }
}

enum BookDTOError: LocalizedError {
    case invalidDate(String)

    var errorDescription: String? {
        switch self {
        case .invalidDate:
            return "최근 검색어 응답의 날짜 형식이 올바르지 않습니다."
        }
    }
}
