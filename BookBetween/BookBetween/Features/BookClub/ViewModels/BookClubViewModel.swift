//
//  BookClubViewModel.swift
//  BookBetween
//

import Foundation
import Observation

enum BookClubTab: CaseIterable {
	case myMeetings
	case createdMeetings
	case search

	var title: String {
		switch self {
		case .myMeetings: return "참여 모임"
		case .createdMeetings: return "내가 만든 모임"
		case .search: return "모임 검색"
		}
	}

	var horizontalPadding: CGFloat {
		switch self {
        case .myMeetings: return 10
		case .createdMeetings: return 10
		case .search: return 10
		}
	}

	var verticalPadding: CGFloat {
		switch self {
		case .myMeetings: return 5
		case .createdMeetings: return 5
		case .search: return 5
		}
	}
}

@Observable
final class BookClubViewModel {

	// MARK: - Properties

	var selectedTab: BookClubTab = .myMeetings
	var searchText: String = ""
	var participatingMeetings: [BookMeeting] = []
	var createdMeetings: [BookMeeting] = []

	var selectedYear: Int = 0
	var selectedMonth: Int = 0

	var filteredParticipatingMeetings: [BookMeeting] {
		participatingMeetings.filter { meeting in
			let components = Calendar.current.dateComponents([.year, .month], from: meeting.meetingDate)
			let yearMatch = selectedYear == 0 || components.year == selectedYear
			let monthMatch = selectedMonth == 0 || components.month == selectedMonth
			return yearMatch && monthMatch
		}
	}

	var filteredCreatedMeetings: [BookMeeting] {
		createdMeetings.filter { meeting in
			let components = Calendar.current.dateComponents([.year, .month], from: meeting.meetingDate)
			let yearMatch = selectedYear == 0 || components.year == selectedYear
			let monthMatch = selectedMonth == 0 || components.month == selectedMonth
			return yearMatch && monthMatch
		}
	}

	var allBooks: [Book] = [
		Book(id: 101, title: "혼모노", author: "성해나", publisher: "창비", kdcName: "한국소설"),
		Book(id: 102, title: "빛은 얼마나 깊이 스미는가", author: "김초엽", publisher: "창비", kdcName: "SF소설"),
		Book(id: 103, title: "프로젝트 헤일메리", author: "앤디 위어", publisher: "알에이치코리아", kdcName: "SF소설"),
	]

	var recruitingMeetings: [BookMeeting] = []

	var meetingSearchResults: [BookMeeting] {
		guard !searchText.isEmpty else { return [] }
		return recruitingMeetings.filter {
			$0.book.title.localizedCaseInsensitiveContains(searchText)
		}
	}

	var bookSearchResults: [Book] {
		guard !searchText.isEmpty else { return [] }
		return allBooks.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
	}

	// MARK: - Init

	init() {
		let calendar = Calendar.current
		let date1 = calendar.date(from: DateComponents(year: 2026, month: 6, day: 19, hour: 21)) ?? Date()
		let date2 = calendar.date(from: DateComponents(year: 2026, month: 6, day: 20, hour: 6)) ?? Date()
		let date3 = calendar.date(from: DateComponents(year: 2026, month: 11, day: 30, hour: 19)) ?? Date()
		let date4 = calendar.date(from: DateComponents(year: 2026, month: 12, day: 5, hour: 20)) ?? Date()

		self.recruitingMeetings = [
			BookMeeting(
				id: 1,
				book: Book(id: 201, title: "혼모노", author: "성해나", description: "성해나 작가의 단편 소설집 『혼모노』는 진짜와 가짜, 믿음에 대한 날카로운 질문을 던지는 작품입니다.", kdcName: "한국소설"),
				meetingDate: date3, timerMinutes: 30,
				maxParticipants: 6, currentParticipants: 4,
				status: .recruiting
			),
			BookMeeting(
				id: 2,
				book: Book(id: 202, title: "빛은 얼마나 깊이 스미는가", author: "김초엽", description: "우주의 끝에서 혼자 깨어난 과학자가 인류를 구하기 위해 사투를 벌이는 이야기.", kdcName: "SF소설"),
				meetingDate: date4, timerMinutes: 45,
				maxParticipants: 5, currentParticipants: 2,
				status: .recruiting
			),
			BookMeeting(
				id: 3,
				book: Book(id: 203, title: "혼모노", author: "성해나", kdcName: "한국소설"),
				meetingDate: date3, timerMinutes: 60,
				maxParticipants: 4, currentParticipants: 1,
				status: .recruiting
			),
		]

		self.participatingMeetings = [
			BookMeeting(
				id: 4,
				book: Book(
					id: 301,
					title: "빛은 얼마나 깊이 스미는가",
					author: "김초엽",
					description: "우주의 끝에서 혼자 깨어난 과학자가 인류를 구하기 위해 사투를 벌이는 이야기. 인간과 외계 생명체의 우정을 따뜻하게 그려낸 SF 소설."
				),
				readingStartDate: date1,
				readingEndDate: date1,
				meetingDate: date1,
				timerMinutes: 60,
				maxParticipants: 6,
				currentParticipants: 2,
				status: .completed
			),
			BookMeeting(
				id: 5,
				book: Book(id: 302, title: "혼모노", author: "성해나"),
				readingStartDate: date2,
				readingEndDate: date2,
				meetingDate: date2,
				timerMinutes: 60,
				maxParticipants: 6,
				currentParticipants: 4,
				status: .upcoming
			),
			BookMeeting(
				id: 6,
				book: Book(id: 303, title: "혼모노", author: "성해나"),
				readingStartDate: date2,
				readingEndDate: date2,
				meetingDate: date2,
				timerMinutes: 60,
				maxParticipants: 6,
				currentParticipants: 4,
				status: .upcoming
			)
		]

		self.createdMeetings = [
			BookMeeting(
				id: 7,
				book: Book(id: 401, title: "빛은 얼마나 깊이 스미는가", author: "김초엽"),
				readingStartDate: date2,
				readingEndDate: date2,
				meetingDate: date2,
				timerMinutes: 60,
				maxParticipants: 6,
				currentParticipants: 2,
				status: .upcoming
			),
			BookMeeting(
				id: 8,
				book: Book(id: 402, title: "혼모노", author: "성해나"),
				readingStartDate: date2,
				readingEndDate: date2,
				meetingDate: date2,
				timerMinutes: 60,
				maxParticipants: 6,
				currentParticipants: 4,
				status: .upcoming
			)
		]
	}
}
