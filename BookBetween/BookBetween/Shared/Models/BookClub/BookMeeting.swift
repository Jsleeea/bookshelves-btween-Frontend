//
//  BookMeeting.swift
//  BookBetween
//
//  Created by 이준성 on 7/2/26.
//

import Foundation

struct MeetingSummaryItem: Decodable {
    let questionOrder: Int
    let question: String
    let summary: String
}

enum BookMeetingStatus: Decodable {
    case recruiting
    case upcoming
    case completed

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        switch value {
        case "RECRUITING": self = .recruiting
        case "UPCOMING", "SCHEDULED": self = .upcoming
        case "COMPLETED", "DONE": self = .completed
        default: self = .upcoming
        }
    }

    var title: String {
        switch self {
        case .recruiting: return "모집중"
        case .upcoming: return "참여예정"
        case .completed: return "참여완료"
        }
    }
}

struct BookMeeting: Decodable {
    let id: Int
    let chatroomId: Int
    let book: Book

    let title: String?
    let description: String?

    let recruitmentStartDate: Date?
    let recruitmentEndDate: Date?

    let readingStartDate: Date?
    let readingEndDate: Date?

    let meetingDate: Date
    let timerMinutes: Int

    let maxParticipants: Int
    let currentParticipants: Int

    let status: BookMeetingStatus
    let meetingSummary: [MeetingSummaryItem]?

    enum CodingKeys: String, CodingKey {
        case id, chatroomId, book
        case meetingDate = "startDate"
        case timerMinutes = "duration"
        case maxParticipants, currentParticipants, status, meetingSummary
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        chatroomId = try container.decode(Int.self, forKey: .chatroomId)
        book = try container.decode(Book.self, forKey: .book)
        timerMinutes = try container.decode(Int.self, forKey: .timerMinutes)
        maxParticipants = try container.decode(Int.self, forKey: .maxParticipants)
        currentParticipants = try container.decode(Int.self, forKey: .currentParticipants)
        meetingSummary = try container.decodeIfPresent([MeetingSummaryItem].self, forKey: .meetingSummary)
        status = try container.decodeIfPresent(BookMeetingStatus.self, forKey: .status) ?? .completed

        let dateString = try container.decode(String.self, forKey: .meetingDate)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        meetingDate = formatter.date(from: dateString) ?? Date()

        title = nil
        description = nil
        recruitmentStartDate = nil
        recruitmentEndDate = nil
        readingStartDate = nil
        readingEndDate = nil
    }

    init(
        id: Int,
        chatroomId: Int = 0,
        book: Book,
        title: String? = nil,
        description: String? = nil,
        recruitmentStartDate: Date? = nil,
        recruitmentEndDate: Date? = nil,
        readingStartDate: Date? = nil,
        readingEndDate: Date? = nil,
        meetingDate: Date,
        timerMinutes: Int,
        maxParticipants: Int,
        currentParticipants: Int,
        status: BookMeetingStatus,
        meetingSummary: [MeetingSummaryItem]? = nil
    ) {
        self.id = id
        self.chatroomId = chatroomId
        self.book = book
        self.title = title
        self.description = description
        self.recruitmentStartDate = recruitmentStartDate
        self.recruitmentEndDate = recruitmentEndDate
        self.readingStartDate = readingStartDate
        self.readingEndDate = readingEndDate
        self.meetingDate = meetingDate
        self.timerMinutes = timerMinutes
        self.maxParticipants = maxParticipants
        self.currentParticipants = currentParticipants
        self.status = status
        self.meetingSummary = meetingSummary
    }
}
