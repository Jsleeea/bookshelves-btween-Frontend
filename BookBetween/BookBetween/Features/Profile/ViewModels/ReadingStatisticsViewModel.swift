//
//  ReadingStatisticsViewModel.swift
//  BookBetween
//

import Foundation
import Observation

@Observable
@MainActor
final class ReadingStatisticsViewModel {
    // MARK: - 의존성

    private let bookService: any BookServiceProtocol
    private let calendar: Calendar

    // MARK: - 상태

    private(set) var selectedMonth: Date
    private(set) var statistics: ReadingStatisticsResultDTO?
    private(set) var isLoading = false
    var errorMessage: String?

    private var latestRequestID = UUID()

    // MARK: - 화면 표시 값

    var completedBookCount: Int {
        statistics?.completedBookCount ?? 0
    }

    var reviewCount: Int {
        statistics?.reviewCount ?? 0
    }

    var averageRating: Double {
        statistics?.averageRating ?? 0
    }

    var categoryStatistics: [ReadingCategoryStatisticsDTO] {
        statistics?.categoryStatistics ?? []
    }

    // MARK: - 초기화

    init(
        bookService: any BookServiceProtocol,
        calendar: Calendar = .current,
        selectedMonth: Date = .now
    ) {
        self.bookService = bookService
        self.calendar = calendar
        self.selectedMonth = calendar.dateInterval(
            of: .month,
            for: selectedMonth
        )?.start ?? selectedMonth
    }

    // MARK: - 통계 조회

    func fetchStatistics() async {
        let requestID = UUID()
        latestRequestID = requestID

        let components = calendar.dateComponents(
            [.year, .month],
            from: selectedMonth
        )

        guard let year = components.year,
              let month = components.month else {
            errorMessage = "조회할 연도와 월을 확인해주세요."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let result = try await bookService.fetchReadingStatistics(
                year: year,
                month: month
            )

            guard latestRequestID == requestID else {
                return
            }

            statistics = result
            isLoading = false
        } catch {
            guard latestRequestID == requestID else {
                return
            }

            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func selectMonth(_ date: Date) async {
        selectedMonth = calendar.dateInterval(
            of: .month,
            for: date
        )?.start ?? date

        await fetchStatistics()
    }
}
