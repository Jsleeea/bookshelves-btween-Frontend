import Foundation
import Alamofire
import Moya

struct MeetingTarget: TargetType {
    enum Endpoint {
        case getMeetingDetail(meetingId: Int)
        case participateMeeting(meetingId: Int)
        case searchMeetings(name: String, page: Int, size: Int)
        case createMeeting(isbn: String, body: MeetingCreateRequestBody)
        case fetchMyMeetings(isLeader: Bool, year: Int?, month: Int?, page: Int, size: Int)
    }

    let baseURL: URL
    let endpoint: Endpoint

    var path: String {
        switch endpoint {
        case .getMeetingDetail(let meetingId):
            return "/api/v1/meetings/\(meetingId)"
        case .participateMeeting(let meetingId):
            return "/api/v1/meetings/\(meetingId)/participation"
        case .searchMeetings:
            return "/api/v1/meetings"
        case .createMeeting(let isbn, _):
            return "/api/v1/\(isbn)/recruitment"
        case .fetchMyMeetings:
            return "/api/v1/meetings/me"
        }
    }

    var method: Moya.Method {
        switch endpoint {
        case .getMeetingDetail:
            return .get
        case .participateMeeting:
            return .post
        case .searchMeetings:
            return .get
        case .createMeeting:
            return .post
        case .fetchMyMeetings:
            return .get
        }
    }

    var task: Moya.Task {
        switch endpoint {
        case .getMeetingDetail:
            return .requestPlain
        case .participateMeeting:
            return .requestPlain
        case .searchMeetings(let name, let page, let size):
            return .requestParameters(
                parameters: ["name": name, "page": page, "size": size],
                encoding: URLEncoding.queryString
            )
        case .createMeeting(_, let body):
            return .requestJSONEncodable(body)
        case .fetchMyMeetings(let isLeader, let year, let month, let page, let size):
            var params: [String: Any] = ["isLeader": isLeader, "page": page, "size": size]
            if let year { params["year"] = year }
            if let month { params["month"] = month }
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        }
    }

    var headers: [String: String]? {
        [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
    }

    var sampleData: Data {
        Data()
    }
}
