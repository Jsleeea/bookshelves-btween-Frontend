//
//  BookTarget.swift
//  BookBetween
//

import Foundation
import Alamofire
import Moya

struct BookTarget: TargetType {
    enum Endpoint {
        case search(
            query: String,
            page: Int,
            size: Int,
            saveRecent: Bool
        )
        case detail(isbn: String)
        case recentSearches
        case upsertMemberBook(
            isbn: String,
            request: MemberBookUpsertRequestDTO
        )
        case memberBooks(status: String, page: Int, size: Int)
        case deleteMemberBook(isbn: String)
        case readingStatistics(year: Int?, month: Int?)
        case readingCalendar(year: Int, month: Int)
    }

    let baseURL: URL
    let endpoint: Endpoint

    var path: String {
        switch endpoint {
        case .search:
            return "/api/v1/books/search"
        case .detail(let isbn):
            return "/api/v1/books/\(isbn)"
        case .recentSearches:
            return "/api/v1/books/search/recent"
        case .upsertMemberBook(let isbn, _):
            return "/api/v1/member-books/\(isbn)"
        case .memberBooks:
            return "/api/v1/member-books"
        case .deleteMemberBook(let isbn):
            return "/api/v1/member-books/\(isbn)"
        case .readingStatistics:
            return "/api/v1/member-books/statistics"
        case .readingCalendar:
            return "/api/v1/member-books/calendar"
        }
    }

    var method: Moya.Method {
        switch endpoint {
        case .search, .detail, .recentSearches, .memberBooks,
             .readingStatistics, .readingCalendar:
            return .get
        case .upsertMemberBook:
            return .put
        case .deleteMemberBook:
            return .delete
        }
    }

    var task: Moya.Task {
        switch endpoint {
        case let .search(query, page, size, saveRecent):
            return .requestParameters(
                parameters: [
                    "query": query,
                    "page": page,
                    "size": size,
                    "saveRecent": saveRecent
                ],
                encoding: URLEncoding.queryString
            )
        case .detail, .recentSearches, .deleteMemberBook:
            return .requestPlain
        case let .memberBooks(status, page, size):
            return .requestParameters(
                parameters: ["status": status, "page": page, "size": size],
                encoding: URLEncoding.queryString
            )
        case let .readingStatistics(year, month):
            var parameters: [String: Int] = [:]
            parameters["year"] = year
            parameters["month"] = month

            guard !parameters.isEmpty else {
                return .requestPlain
            }

            return .requestParameters(
                parameters: parameters,
                encoding: URLEncoding.queryString
            )
        case let .readingCalendar(year, month):
            return .requestParameters(
                parameters: ["year": year, "month": month],
                encoding: URLEncoding.queryString
            )
        case .upsertMemberBook(_, let request):
            return .requestJSONEncodable(request)
        }
    }

    var headers: [String: String]? {
        [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
    }

    var sampleData: Data {
        BookStubData.data(for: endpoint)
    }
}
