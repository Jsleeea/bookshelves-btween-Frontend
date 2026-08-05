//
//  HomeRoute.swift
//  BookBetween
//

import Foundation

enum HomeRoute: Hashable {
    case notificationInbox
    case meetingDetail(BookMeeting)
    case bookDetail(Book)
    case recentBookDetail(UserBookRecord)
}
