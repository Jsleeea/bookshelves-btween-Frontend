import Foundation

private let meetingDateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    f.locale = Locale(identifier: "en_US_POSIX")
    return f
}()

struct MeetingResultDTO: Decodable {
    let id: Int
    let chatroomId: Int?
    let book: MeetingBookDTO
    let startDate: String
    let duration: Int
    let maxParticipants: Int
    let currentParticipants: Int
    let status: String?
    let meetingSummary: [MeetingSummaryItemDTO]?
}

struct MeetingBookDTO: Decodable {
    let id: Int?
    let isbn: String?
    let title: String
    let author: String
    let publisher: String?
    let description: String?
    let coverImageUrl: String?
    let kdcCode: String?
    let kdcName: String?
}

struct MeetingSummaryItemDTO: Decodable {
    let order: Int
    // 대화가 적어 채울 내용이 없는 주제는 서버가 빈 문자열 대신 null을 내려줍니다.
    let title: String?
    let summary: String?
}

extension MeetingResultDTO {
    func toDomain() throws -> BookMeeting {
        guard let meetingDate = meetingDateFormatter.date(from: startDate) else {
            throw MeetingDTOError.invalidDate(startDate)
        }

        let statusValue = status.map { BookMeetingStatus($0) } ?? .completed

        return BookMeeting(
            id: id,
            chatroomId: chatroomId ?? 0,
            book: Book(
                id: book.id,
                isbn: book.isbn,
                title: book.title,
                author: book.author,
                publisher: book.publisher,
                description: book.description,
                coverImageUrl: book.coverImageUrl,
                kdcCode: book.kdcCode,
                kdcName: book.kdcName
            ),
            meetingDate: meetingDate,
            timerMinutes: duration,
            maxParticipants: maxParticipants,
            currentParticipants: currentParticipants,
            status: statusValue,
            meetingSummary: meetingSummary?.map {
                MeetingSummaryItem(
                    order: $0.order,
                    title: $0.title ?? "",
                    summary: $0.summary ?? ""
                )
            }
        )
    }
}

struct MeetingParticipationResultDTO: Decodable {
    let meetingParticipantId: Int
}

struct MeetingCreateRequestBody: Encodable {
    let isbn: String
    let startDate: String
    let startTime: String
    let maxParticipants: Int
    let duration: Int
}

struct MeetingCreateResultDTO: Decodable {
    let id: Int
}

struct MeetingListResultDTO: Decodable {
    let meetings: [MeetingListItemDTO]
    let page: Int
    let size: Int
    let hasNext: Bool
}

struct MeetingListItemDTO: Decodable {
    let id: Int
    let chatroomId: Int?
    let status: String
    let startDate: String
    let currentParticipants: Int
    let maxParticipants: Int
    let duration: Int
    let book: MeetingListBookDTO
}

struct MeetingListBookDTO: Decodable {
    let id: Int?
    let title: String
    let coverImageUrl: String?
}

extension MeetingListResultDTO {
    func toDomain() -> [BookMeeting] {
        return meetings.compactMap { item in
            guard let meetingDate = meetingDateFormatter.date(from: item.startDate) else { return nil }
            let statusValue = BookMeetingStatus(item.status)
            return BookMeeting(
                id: item.id,
                chatroomId: item.chatroomId ?? 0,
                book: Book(id: item.book.id, title: item.book.title, author: "", coverImageUrl: item.book.coverImageUrl),
                meetingDate: meetingDate,
                timerMinutes: item.duration,
                maxParticipants: item.maxParticipants,
                currentParticipants: item.currentParticipants,
                status: statusValue
            )
        }
    }
}

enum MeetingDTOError: LocalizedError {
    case invalidDate(String)

    var errorDescription: String? {
        switch self {
        case .invalidDate:
            return "모임 응답의 날짜 형식이 올바르지 않습니다."
        }
    }
}
