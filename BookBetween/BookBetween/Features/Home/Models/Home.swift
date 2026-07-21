//
//  Home.swift
//  BookBetween
//
//  Created by 이준성 on 7/2/26.
//

import Foundation

struct Home {
    let member: HomeMember
    let recommendedAt: String
    let recommendedBook: HomeRecommendedBook
    let recentBook: HomeRecentBook?
    let meetings: [HomeMeetingItem]
}

struct HomeMember {
    let nickname: String
}

struct HomeRecommendedBook {
    let recommendationMessage: String
    let book: Book
}

struct HomeRecentBook {
    let memberBook: HomeMemberBook
    let memberBookHistory: HomeMemberBookHistory
    let book: Book

    var record: UserBookRecord {
        UserBookRecord(
            id: memberBook.id,
            book: book,
            progress: memberBook.progress,
            rating: memberBook.rating
        )
    }
}

struct HomeMemberBook {
    let id: Int
    let progress: Int
    let status: String
    let rating: Double?
}

struct HomeMemberBookHistory {
    let id: Int
    let createdAt: Date
}

struct HomeMeetingItem: Identifiable {
    let meeting: HomeMeetingSummary
    let book: HomeMeetingBook

    var id: Int { meeting.id }
}

struct HomeMeetingSummary {
    let id: Int
    let status: String
    let startDate: Date
    let currentParticipants: Int
    let maxParticipants: Int
    let duration: Int
}

struct HomeMeetingBook {
    let id: Int
    let title: String
    let publisher: String
    let coverImageUrl: String?
}
