//
//  ProfileViewModel.swift
//  BookBetween
//

import Foundation
import Observation

// MARK: - 마이페이지 뷰 모델

@Observable
@MainActor
final class ProfileViewModel {
    // MARK: - 속성

    private let calendar: Calendar
    private let memberService: MemberServiceProtocol?

    var displayedMonth: Date
    private(set) var profile: MemberProfile?
    private(set) var isLoading = false
    var errorMessage: String?

    var calendarDays: [CalendarDay] {
        makeCalendarDays(for: displayedMonth)
    }

    // MARK: - 초기화

    init(
        memberService: MemberServiceProtocol? = nil,
        calendar: Calendar = .current,
        displayedMonth: Date = Date()
    ) {
        var sundayFirstCalendar = calendar
        sundayFirstCalendar.firstWeekday = 1

        self.calendar = sundayFirstCalendar
        self.memberService = memberService
        self.displayedMonth = sundayFirstCalendar.date(
            from: sundayFirstCalendar.dateComponents([.year, .month], from: displayedMonth)
        ) ?? displayedMonth
    }

    func fetchMyProfile() async {
        guard let memberService,
              !isLoading else {
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            profile = try await memberService.fetchMyProfile()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func updateMyProfile(
        request: MemberProfileUpdateRequestDTO
    ) async throws {
        guard let memberService else {
            throw NetworkError.emptyResult
        }

        profile = try await memberService.updateMyProfile(
            request: request
        )
    }

    // MARK: - 월 이동

    func moveToPreviousMonth() {
        moveMonth(by: -1)
    }

    func moveToNextMonth() {
        moveMonth(by: 1)
    }

    private func moveMonth(by value: Int) {
        guard let newMonth = calendar.date(
            byAdding: .month,
            value: value,
            to: displayedMonth
        ) else {
            return
        }

        displayedMonth = newMonth
    }

    // MARK: - 캘린더 날짜 생성

    private func makeCalendarDays(for month: Date) -> [CalendarDay] {
        let monthComponents = calendar.dateComponents([.year, .month], from: month)

        guard
            let monthStart = calendar.date(from: monthComponents),
            let daysInMonth = calendar.range(of: .day, in: .month, for: monthStart)?.count
        else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let leadingDayCount = (firstWeekday - calendar.firstWeekday + 7) % 7
        let requiredDayCount = leadingDayCount + daysInMonth
        let calculatedCellCount = ((requiredDayCount + 6) / 7) * 7
        let cellCount = max(35, calculatedCellCount)

        guard let calendarStartDate = calendar.date(
            byAdding: .day,
            value: -leadingDayCount,
            to: monthStart
        ) else {
            return []
        }

        return (0..<cellCount).compactMap { offset in
            guard let date = calendar.date(
                byAdding: .day,
                value: offset,
                to: calendarStartDate
            ) else {
                return nil
            }

            return CalendarDay(
                date: date,
                day: calendar.component(.day, from: date),
                isCurrentMonth: calendar.isDate(
                    date,
                    equalTo: monthStart,
                    toGranularity: .month
                )
            )
        }
    }
}
