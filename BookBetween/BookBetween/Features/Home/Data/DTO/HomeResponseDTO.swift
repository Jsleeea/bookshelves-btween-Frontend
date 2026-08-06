//
//  HomeResponseDTO.swift
//  BookBetween
//

import Foundation

struct HomeResultDTO: Decodable {
    let member: HomeMemberDTO
    let recommendedAt: String?
    let recommendedBook: HomeRecommendedBookDTO?
    let recentBook: HomeRecentBookDTO?
    let meetings: [HomeMeetingItemDTO]
}

struct HomeMemberDTO: Decodable {
    let nickname: String
}

struct HomeRecommendedBookDTO: Decodable {
    let recommendationMessage: String
    let book: HomeBookDTO
}

struct HomeRecentBookDTO: Decodable {
    let memberBook: HomeMemberBookDTO
    let book: HomeBookDTO
}

struct HomeMemberBookDTO: Decodable {
    let id: Int
    let progress: Int
    let status: String
    let rating: Double?
    let updatedAt: String
}

struct HomeMeetingItemDTO: Decodable {
    let meeting: HomeMeetingSummaryDTO
    let book: HomeMeetingBookDTO
}

struct HomeMeetingSummaryDTO: Decodable {
    let id: Int
    let status: String
    let startDate: String
    let currentParticipants: Int
    let maxParticipants: Int
    let duration: Int
}

struct HomeBookDTO: Decodable {
    let id: Int
    let isbn: String
    let title: String
    let author: String
    let publisher: String?
    let coverImageUrl: String?
    let kdcCode: String?
    let kdcName: String?

    private enum CodingKeys: String, CodingKey {
        case id, isbn, title, author, publisher, coverImageUrl, kdcCode, kdcName
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        isbn = try container.decode(String.self, forKey: .isbn)
        title = try container.decodeIfPresent(String.self, forKey: .title)
            ?? "제목 정보 없음"
        author = try container.decodeIfPresent(String.self, forKey: .author)
            ?? "저자 미상"
        publisher = try container.decodeIfPresent(String.self, forKey: .publisher)
        coverImageUrl = try container.decodeIfPresent(String.self, forKey: .coverImageUrl)
        kdcCode = try container.decodeIfPresent(String.self, forKey: .kdcCode)
        kdcName = try container.decodeIfPresent(String.self, forKey: .kdcName)
    }
}

struct HomeMeetingBookDTO: Decodable {
    let id: Int
    let title: String
    let publisher: String
    let coverImageUrl: String?
}

extension HomeResultDTO {
    func toDomain() throws -> Home {
        Home(
            member: HomeMember(nickname: member.nickname),
            recommendedAt: recommendedAt,
            recommendedBook: recommendedBook.map {
                HomeRecommendedBook(
                    recommendationMessage: $0.recommendationMessage,
                    book: $0.book.toDomain()
                )
            },
            recentBook: try recentBook.map { recentBook in
                HomeRecentBook(
                    memberBook: HomeMemberBook(
                        id: recentBook.memberBook.id,
                        progress: recentBook.memberBook.progress,
                        status: recentBook.memberBook.status,
                        rating: recentBook.memberBook.rating,
                        updatedAt: try parseAPIDate(
                            recentBook.memberBook.updatedAt
                        )
                    ),
                    book: recentBook.book.toDomain()
                )
            },
            meetings: try meetings.map { item in
                HomeMeetingItem(
                    meeting: HomeMeetingSummary(
                        id: item.meeting.id,
                        status: item.meeting.status,
                        startDate: try parseAPIDate(item.meeting.startDate),
                        currentParticipants: item.meeting.currentParticipants,
                        maxParticipants: item.meeting.maxParticipants,
                        duration: item.meeting.duration
                    ),
                    book: HomeMeetingBook(
                        id: item.book.id,
                        title: item.book.title,
                        publisher: item.book.publisher,
                        coverImageUrl: item.book.coverImageUrl
                    )
                )
            }
        )
    }

    private func parseAPIDate(_ value: String) throws -> Date {
        let iso8601Formatter = ISO8601DateFormatter()
        if let date = iso8601Formatter.date(from: value) {
            return date
        }

        let fractionalISO8601Formatter = ISO8601DateFormatter()
        fractionalISO8601Formatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]
        if let date = fractionalISO8601Formatter.date(from: value) {
            return date
        }

        let localFormatter = DateFormatter()
        localFormatter.locale = Locale(identifier: "en_US_POSIX")
        localFormatter.calendar = Calendar(identifier: .gregorian)
        localFormatter.timeZone = .current
        localFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        let localDateComponents = value.split(
            separator: ".",
            maxSplits: 1,
            omittingEmptySubsequences: false
        )
        guard let date = localFormatter.date(from: String(localDateComponents[0])) else {
            throw HomeDTOError.invalidDate(value)
        }

        guard localDateComponents.count == 2 else {
            return date
        }

        let fractionalDigits = localDateComponents[1].prefix { $0.isNumber }
        guard !fractionalDigits.isEmpty,
              let fractionalSeconds = Double("0.\(fractionalDigits)") else {
            throw HomeDTOError.invalidDate(value)
        }

        return date.addingTimeInterval(fractionalSeconds)
    }
}

private extension HomeBookDTO {
    func toDomain() -> Book {
        Book(
            id: id,
            isbn: isbn,
            title: title,
            author: author,
            publisher: publisher,
            coverImageUrl: coverImageUrl,
            kdcCode: kdcCode,
            kdcName: kdcName
        )
    }
}

enum HomeDTOError: LocalizedError {
    case invalidDate(String)

    var errorDescription: String? {
        switch self {
        case .invalidDate:
            return "홈 응답의 날짜 형식이 올바르지 않습니다."
        }
    }
}
