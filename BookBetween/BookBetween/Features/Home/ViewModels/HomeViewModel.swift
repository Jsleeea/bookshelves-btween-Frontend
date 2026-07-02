//
//  HomeViewModel.swift
//  BookBetween
//
//  Created by 이준성 on 7/2/26.
//

import Foundation
import Observation

@Observable
final class HomeViewModel {
    var home: Home

    init() {
        self.home = Home(
            user: User(id: "1", nickname: "책 먹는 여우", profileImageURL: nil),
            dailyRecommendation: DailyBookRecommendation(
                book: Book(
                    id: "recommend-1",
                    title: "랑과 나의 사막",
                    author: "천선란",
                    description: nil,
                    thumbnailURL: nil,
                    thumbnailImageName: "book_cover_recommend"
                ),
                description: "멸망한 세계의 어느날 나의 주인이 죽었다"
            ),
            recentBooks: [
                UserBookRecord(
                    book: Book(
                        id: "recent-1",
                        title: "아무 희미한 빛으로도",
                        author: "최은영",
                        description: nil,
                        thumbnailURL: nil,
                        thumbnailImageName: "book_cover_recent"
                    ),
                    progress: 0.75,
                    oneLineReview: nil,
                    rating: 4.5
                )
            ],
            recruitingMeetings: [
                BookMeeting(
                    id: "meeting-1",
                    book: Book(
                        id: "meeting-book-1",
                        title: "빛은 얼마나 깊이 스미는가",
                        author: "",
                        description: nil,
                        thumbnailURL: nil,
                        thumbnailImageName: "book_cover_meeting_1"
                    ),
                    title: nil,
                    description: "",
                    recruitmentStartDate: Date(),
                    recruitmentEndDate: Date(),
                    readingStartDate: Date(),
                    readingEndDate: Date(),
                    meetingDate: Date(),
                    timerMinutes: 60,
                    maxParticipants: 6,
                    currentParticipants: 2,
                    status: .recruiting
                ),
                BookMeeting(
                    id: "meeting-2",
                    book: Book(
                        id: "meeting-book-2",
                        title: "프로젝트 헤일미리",
                        author: "",
                        description: nil,
                        thumbnailURL: nil,
                        thumbnailImageName: "book_cover_meeting_2"
                    ),
                    title: nil,
                    description: "",
                    recruitmentStartDate: Date(),
                    recruitmentEndDate: Date(),
                    readingStartDate: Date(),
                    readingEndDate: Date(),
                    meetingDate: Date(),
                    timerMinutes: 60,
                    maxParticipants: 6,
                    currentParticipants: 2,
                    status: .recruiting
                )
            ]
        )
    }
}
