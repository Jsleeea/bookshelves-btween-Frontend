import Foundation

enum SearchRoute: Hashable {
    case createMeeting(Book)
    case bookDetail(BookSearchItem)
}
