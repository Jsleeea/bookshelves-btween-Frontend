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

    var pillWidth: CGFloat {
        switch self {
        case .myMeetings: return 70
        case .createdMeetings: return 90
        case .search: return 70
        }
    }
}

@Observable
final class BookClubViewModel {

	// MARK: - Properties

	var selectedTab: BookClubTab = .myMeetings
	var meetingService: (any MeetingServiceProtocol)?
    private let bookService: (any BookServiceProtocol)?
    private let memberService: (any MemberServiceProtocol)?
    var chatService: (any ChatServiceProtocol)?
    var chatSocketService: (any ChatSocketServiceProtocol)?
	var searchText: String = ""
	var participatingMeetings: [BookMeeting] = []
	var createdMeetings: [BookMeeting] = []

	var selectedYear: Int = 0
	var selectedMonth: Int = 0
    var joinedYear: Int? = nil

	var filteredParticipatingMeetings: [BookMeeting] {
		let meetings: [BookMeeting]
		if meetingService == nil {
			meetings = participatingMeetings.filter { meeting in
				let components = Calendar.current.dateComponents([.year, .month], from: meeting.meetingDate)
				let yearMatch = selectedYear == 0 || components.year == selectedYear
				let monthMatch = selectedMonth == 0 || components.month == selectedMonth
				return yearMatch && monthMatch
			}
		} else {
			var seen = Set<Int>()
			meetings = (participatingMeetings + createdMeetings)
				.filter { seen.insert($0.id).inserted }
		}
		return sortedMeetings(meetings)
	}

	var filteredCreatedMeetings: [BookMeeting] {
		if meetingService == nil {
			let meetings = createdMeetings.filter { meeting in
				let components = Calendar.current.dateComponents([.year, .month], from: meeting.meetingDate)
				let yearMatch = selectedYear == 0 || components.year == selectedYear
				let monthMatch = selectedMonth == 0 || components.month == selectedMonth
				return yearMatch && monthMatch
			}
			return sortedMeetings(meetings)
		}
		return sortedMeetings(createdMeetings)
	}

	private func sortedMeetings(_ meetings: [BookMeeting]) -> [BookMeeting] {
		let statusPriority: (BookMeetingStatus) -> Int = {
			switch $0 {
			case .inProgress: return 0
			case .upcoming:   return 1
			case .recruiting: return 2
			case .completed:  return 3
			}
		}
		return meetings.sorted { a, b in
			let pa = statusPriority(a.status), pb = statusPriority(b.status)
			if pa != pb { return pa < pb }
			// 참여완료는 최근 날짜가 위, 나머지는 가까운 미래가 위
			return a.status == .completed
				? a.meetingDate > b.meetingDate
				: a.meetingDate < b.meetingDate
		}
	}

	private let allBooks: [Book] = [
		Book(id: 101, title: "혼모노", author: "성해나", publisher: "창비", kdcName: "한국소설"),
		Book(id: 102, title: "빛은 얼마나 깊이 스미는가", author: "김초엽", publisher: "창비", kdcName: "SF소설"),
		Book(id: 103, title: "프로젝트 헤일메리", author: "앤디 위어", publisher: "알에이치코리아", kdcName: "SF소설"),
	]

	var recruitingMeetings: [BookMeeting] = []

	var apiSearchResults: [BookMeeting] = []
	var apiBookSearchResults: [Book] = []
	var isSearchLoading = false

	var meetingSearchResults: [BookMeeting] {
		guard !searchText.isEmpty else { return [] }
		if meetingService != nil {
			return apiSearchResults
		}
		return recruitingMeetings.filter {
			$0.book.title.localizedCaseInsensitiveContains(searchText)
		}
	}

	var bookSearchResults: [Book] {
		guard !searchText.isEmpty else { return [] }
		if bookService != nil {
			return apiBookSearchResults
		}
		return allBooks.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
	}

	// MARK: - Init

	init(
		meetingService: (any MeetingServiceProtocol)? = nil,
		bookService: (any BookServiceProtocol)? = nil,
        memberService: (any MemberServiceProtocol)? = nil,
		chatService: (any ChatServiceProtocol)? = nil,
		chatSocketService: (any ChatSocketServiceProtocol)? = nil
	) {
		self.meetingService = meetingService
        self.bookService = bookService
        self.memberService = memberService
        self.chatService = chatService
        self.chatSocketService = chatSocketService

        guard meetingService == nil else { return }

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
				id: 9,
				book: Book(id: 304, title: "싯다르타", author: "헤르만 헤세", description: "인도를 배경으로 한 청년 싯다르타의 깨달음을 향한 정신적 여정을 그린 소설."),
				meetingDate: Date(),
				timerMinutes: 24,
				maxParticipants: 4,
				currentParticipants: 3,
				status: .inProgress
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

	// MARK: - Actions

    func fetchJoinedYear() async {
        guard let memberService else { return }
        guard let profile = try? await memberService.fetchMyProfile() else { return }
        let joinedAt = Calendar.current.date(byAdding: .day, value: -profile.joinedDays, to: Date()) ?? Date()
        joinedYear = Calendar.current.component(.year, from: joinedAt)
    }

	func fetchMyMeetings() async {
		guard let meetingService else { return }
		let year: Int? = selectedYear > 0 ? selectedYear : nil
		let month: Int? = (selectedYear > 0 && selectedMonth > 0) ? selectedMonth : nil

		async let participatingResult = meetingService.fetchMyMeetings(isLeader: false, year: year, month: month, page: 1, size: 50)
		async let createdResult = meetingService.fetchMyMeetings(isLeader: true, year: year, month: month, page: 1, size: 50)

		if let meetings = try? await participatingResult { participatingMeetings = meetings }
		if let meetings = try? await createdResult { createdMeetings = meetings }
	}

	func searchMeetings(query: String) async {
		guard !query.isEmpty else {
			apiSearchResults = []
			apiBookSearchResults = []
			return
		}

		isSearchLoading = true
		defer { isSearchLoading = false }

		if let svc = meetingService {
			do {
				apiSearchResults = try await svc.searchMeetings(name: query, page: 1, size: 20)
			} catch {
				apiSearchResults = []
			}
		} else {
			apiSearchResults = []
		}

		if let svc = bookService {
			do {
				let page = try await svc.searchBooks(query: query, page: 1, size: 20, saveRecent: false)
				let items = page.books.filter { $0.isSaveable }.map { $0.book }
				var seenIsbns = Set<String>()
				var seenTitles = Set<String>()
				apiBookSearchResults = items.filter { book in
					if let isbn = book.isbn {
						return seenIsbns.insert(isbn).inserted && seenTitles.insert(book.title).inserted
					}
					return seenTitles.insert(book.title).inserted
				}
			} catch {
				apiBookSearchResults = []
			}
		} else {
			apiBookSearchResults = []
		}
	}

	func participateMeeting(meetingId: Int) async -> Bool {
		guard let meetingService else { return false }
		do {
			_ = try await meetingService.participateMeeting(meetingId: meetingId)
			return true
		} catch {
			return false
		}
	}
}
