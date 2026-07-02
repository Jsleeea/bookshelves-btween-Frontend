//
//  BookMeeting.swift
//  BookBetween
//
//  Created by 이준성 on 7/2/26.
//

import Foundation

enum BookMeetingStatus {
    case recruiting
    case upcoming
    case completed
    
    var title: String {
        switch self {
        case .recruiting:
            return "모집중"
        case .upcoming:
            return "참여예정"
        case .completed:
            return "참여완료"
        }
    }
}

struct BookMeeting {
    let id: String
    let book: Book

    let title: String?
    let description: String

    let recruitmentStartDate: Date
    let recruitmentEndDate: Date

    let readingStartDate: Date
    let readingEndDate: Date

    let meetingDate: Date
    let timerMinutes: Int

    let maxParticipants: Int
    let currentParticipants: Int

    let status: BookMeetingStatus
}
