//
//  BookMeetingDiscussion.swift
//  BookBetween
//

import Foundation

struct DiscussionTopic: Identifiable {
	let id: Int
	let title: String
	let content: String
	let quote: String?
}

struct BookMeetingDiscussion {
	let meeting: BookMeeting
	let topics: [DiscussionTopic]
	let keywords: [String]
}
