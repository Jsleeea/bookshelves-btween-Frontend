//
//  NotificationTarget.swift
//  BookBetween
//

import Foundation
import Alamofire
import Moya

struct NotificationTarget: TargetType {
    enum Endpoint {
        case registerFCMToken(String)
        case fetchNotifications(page: Int, size: Int)
        case fetchNewNotifications(afterId: Int, size: Int)
        case markAsRead(notificationId: Int)
        case deleteNotification(notificationId: Int)
    }

    let baseURL: URL
    let endpoint: Endpoint

    var path: String {
        switch endpoint {
        case .registerFCMToken:
            return "/api/v1/notifications/fcm/tokens"
        case .fetchNotifications:
            return "/api/v1/notifications"
        case .fetchNewNotifications:
            return "/api/v1/notifications/new"
        case .markAsRead(let notificationId):
            return "/api/v1/notifications/\(notificationId)/read"
        case .deleteNotification(let notificationId):
            return "/api/v1/notifications/\(notificationId)"
        }
    }

    var method: Moya.Method {
        switch endpoint {
        case .registerFCMToken:
            return .post
        case .fetchNotifications, .fetchNewNotifications:
            return .get
        case .markAsRead:
            return .patch
        case .deleteNotification:
            return .delete
        }
    }

    var task: Moya.Task {
        switch endpoint {
        case .registerFCMToken(let token):
            return .requestParameters(
                parameters: ["fcmToken": token],
                encoding: JSONEncoding.default
            )
        case let .fetchNotifications(page, size):
            return .requestParameters(
                parameters: [
                    "page": page,
                    "size": size
                ],
                encoding: URLEncoding.queryString
            )
        case let .fetchNewNotifications(afterId, size):
            return .requestParameters(
                parameters: [
                    "afterId": afterId,
                    "size": size
                ],
                encoding: URLEncoding.queryString
            )
        case .markAsRead, .deleteNotification:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
    }

    var sampleData: Data {
        NotificationStubData.data(for: endpoint)
    }
}
