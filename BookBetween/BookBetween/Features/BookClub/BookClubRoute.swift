import Foundation

enum BookClubRoute: Hashable {
    case detail(BookMeeting, isParticipant: Bool)
    case chat(chatroomId: Int, meetingId: Int, bookAuthor: String)
    case result(BookMeeting)
    case create(Book)
}
