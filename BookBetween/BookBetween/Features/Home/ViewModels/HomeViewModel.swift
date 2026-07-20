//
//  HomeViewModel.swift
//  BookBetween
//
//  Created by 이준성 on 7/2/26.
//

import Foundation
import Observation

@Observable
@MainActor
final class HomeViewModel {
    var home: Home
    let nickname = "책 먹는 여우"
    var isLoading = false
    var errorMessage: String?

    private let service: (any HomeServiceProtocol)?

    init(service: (any HomeServiceProtocol)? = nil) {
        self.service = service

        let dateFormatter = ISO8601DateFormatter()
        let date: (String) -> Date = { value in
            dateFormatter.date(from: value) ?? Date()
        }

        self.home = Home(
            recommendedAt: "2026-07-14",
            recommendedBook: HomeRecommendedBook(
                book: Book(
                    id: 1,
                    isbn: "9788936434595",
                    title: "랑과 나의 사막",
                    author: "천선란",
                    publisher: "창비",
                    coverImageUrl: "https://image.example.com/book.jpg",
                    kdcCode: "813",
                    kdcName: "현대문학"
                )
            ),
            recentBook: HomeRecentBook(
                memberBook: HomeMemberBook(
                    id: 10,
                    progress: 70,
                    status: "READING",
                    rating: 4.5
                ),
                memberBookHistory: HomeMemberBookHistory(
                    id: 25,
                    createdAt: date("2026-07-14T04:30:00+09:00")
                ),
                book: Book(
                    id: 1,
                    isbn: "9788936434595",
                    title: "아무 희미한 빛으로도",
                    author: "최은영",
                    publisher: "창비",
                    coverImageUrl: "https://image.example.com/book.jpg"
                )
            ),
            meetings: [
                HomeMeetingItem(
                    meeting: HomeMeetingSummary(
                        id: 21,
                        status: "RECRUITING",
                        startDate: date("2026-07-20T19:00:00+09:00"),
                        currentParticipants: 4,
                        maxParticipants: 6,
                        duration: 30
                    ),
                    book: HomeMeetingBook(
                        id: 1,
                        title: "혼모노",
                        publisher: "창비",
                        coverImageUrl: "https://image.example.com/book1.jpg"
                    )
                ),
                HomeMeetingItem(
                    meeting: HomeMeetingSummary(
                        id: 22,
                        status: "RECRUITING",
                        startDate: date("2026-07-21T18:00:00+09:00"),
                        currentParticipants: 3,
                        maxParticipants: 5,
                        duration: 40
                    ),
                    book: HomeMeetingBook(
                        id: 2,
                        title: "프로젝트 헤일메리",
                        publisher: "RHK(알에이치코리아)",
                        coverImageUrl: "https://image.example.com/book2.jpg"
                    )
                ),
                HomeMeetingItem(
                    meeting: HomeMeetingSummary(
                        id: 23,
                        status: "RECRUITING",
                        startDate: date("2026-07-22T20:00:00+09:00"),
                        currentParticipants: 2,
                        maxParticipants: 6,
                        duration: 50
                    ),
                    book: HomeMeetingBook(
                        id: 3,
                        title: "데미안",
                        publisher: "민음사",
                        coverImageUrl: "https://image.example.com/book3.jpg"
                    )
                )
            ]
        )
    }

    func fetchHome() async {
        guard let service, !isLoading else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            home = try await service.fetchHome()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
