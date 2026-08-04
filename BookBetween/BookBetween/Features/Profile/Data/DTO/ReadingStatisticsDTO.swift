//
//  ReadingStatisticsDTO.swift
//  BookBetween
//

import Foundation

nonisolated struct ReadingStatisticsResultDTO: Decodable {
    let year: Int
    let month: Int
    let completedBookCount: Int
    let reviewCount: Int
    let averageRating: Double
    let categoryStatistics: [ReadingCategoryStatisticsDTO]
}

nonisolated struct ReadingCategoryStatisticsDTO: Decodable {
    let name: String
    let count: Int
    let percentage: Int
}
