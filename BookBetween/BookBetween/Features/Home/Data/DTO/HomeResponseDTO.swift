//
//  HomeResponseDTO.swift
//  BookBetween
//

import Foundation

struct HomeResultDTO: Decodable {
    let member: HomeMemberDTO
    let recommendedAt: String
    let recommendedBook: HomeRecommendedBookDTO
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
    let memberBookHistory: HomeMemberBookHistoryDTO
    let book: HomeBookDTO
}

struct HomeMemberBookDTO: Decodable {
    let id: Int
    let progress: Int
    let status: String
    let rating: Double?
}

struct HomeMemberBookHistoryDTO: Decodable {
    let id: Int
    let createdAt: String
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
    let publisher: String
    let coverImageUrl: String?
    let kdcCode: String?
    let kdcName: String?
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
            recommendedBook: HomeRecommendedBook(
                recommendationMessage: recommendedBook.recommendationMessage,
                book: recommendedBook.book.toDomain()
            ),
            recentBook: try recentBook.map { recentBook in
                HomeRecentBook(
                    memberBook: HomeMemberBook(
                        id: recentBook.memberBook.id,
                        progress: recentBook.memberBook.progress,
                        status: recentBook.memberBook.status,
                        rating: recentBook.memberBook.rating
                    ),
                    memberBookHistory: HomeMemberBookHistory(
                        id: recentBook.memberBookHistory.id,
                        createdAt: try parseISO8601Date(recentBook.memberBookHistory.createdAt)
                    ),
                    book: recentBook.book.toDomain()
                )
            },
            meetings: try meetings.map { item in
                HomeMeetingItem(
                    meeting: HomeMeetingSummary(
                        id: item.meeting.id,
                        status: item.meeting.status,
                        startDate: try parseISO8601Date(item.meeting.startDate),
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

    private func parseISO8601Date(_ value: String) throws -> Date {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: value) else {
            throw HomeDTOError.invalidDate(value)
        }
        return date
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
