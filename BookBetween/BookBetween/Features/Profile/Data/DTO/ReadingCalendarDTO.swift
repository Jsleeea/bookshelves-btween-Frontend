//
//  ReadingCalendarDTO.swift
//  BookBetween
//

import Foundation

nonisolated struct ReadingCalendarResultDTO: Decodable {
    let year: Int
    let month: Int
    let days: [ReadingCalendarDayDTO]
}

nonisolated struct ReadingCalendarDayDTO: Decodable {
    let date: String
    let coverImageUrl: String?
}
