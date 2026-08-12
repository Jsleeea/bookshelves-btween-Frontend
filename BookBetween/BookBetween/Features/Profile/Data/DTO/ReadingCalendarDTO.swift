//
//  ReadingCalendarDTO.swift
//  BookBetween
//

import Foundation

// MARK: - 독서 캘린더 DTO

nonisolated struct ReadingCalendarResultDTO: Decodable {
    let year: Int
    let month: Int
    let days: [ReadingCalendarDayDTO]
}

// MARK: - 독서 캘린더 날짜 DTO

nonisolated struct ReadingCalendarDayDTO: Decodable {
    let date: String
    let coverImageUrl: String?
}
