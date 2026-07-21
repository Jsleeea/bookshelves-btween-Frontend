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
        }
    }

    var method: Moya.Method {
        .get
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
