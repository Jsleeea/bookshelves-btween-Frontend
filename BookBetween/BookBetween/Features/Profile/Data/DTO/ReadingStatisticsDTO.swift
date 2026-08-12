//
//  ReadingStatisticsDTO.swift
//  BookBetween
//

import Foundation

// MARK: - 독서 통계 DTO

nonisolated struct ReadingStatisticsResultDTO: Decodable {
    let year: Int
    let month: Int
    let completedBookCount: Int
    let reviewCount: Int
    let averageRating: Double
    let categoryStatistics: [ReadingCategoryStatisticsDTO]
}

// MARK: - 장르별 독서 통계 DTO

nonisolated struct ReadingCategoryStatisticsDTO: Decodable {
    let name: String
    let count: Int
    let percentage: Int
}
