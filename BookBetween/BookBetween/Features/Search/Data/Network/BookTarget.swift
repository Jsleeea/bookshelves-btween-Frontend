//
//  BookTarget.swift
//  BookBetween
//

import Foundation
import Alamofire
import Moya

struct BookTarget: TargetType {
    enum Endpoint {
        case search(query: String, page: Int, size: Int)
        case detail(isbn: String)
        case recentSearches
        case upsertMemberBook(
            isbn: String,
            request: MemberBookUpsertRequestDTO
        )
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
        }
    }

    var method: Moya.Method {
        switch endpoint {
        case .search, .detail, .recentSearches:
            return .get
        case .upsertMemberBook:
            return .put
        }
    }

    var task: Moya.Task {
        switch endpoint {
        case let .search(query, page, size):
            return .requestParameters(
                parameters: [
                    "query": query,
                    "page": page,
                    "size": size
                ],
                encoding: URLEncoding.queryString
            )
        case .detail, .recentSearches:
            return .requestPlain
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
