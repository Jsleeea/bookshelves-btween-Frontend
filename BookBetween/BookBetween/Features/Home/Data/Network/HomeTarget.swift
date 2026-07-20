//
//  HomeTarget.swift
//  BookBetween
//

import Foundation
import Alamofire
import Moya

struct HomeTarget: TargetType {
    enum Endpoint {
        case fetchHome
    }

    let baseURL: URL
    let endpoint: Endpoint

    var path: String {
        switch endpoint {
        case .fetchHome:
            return "/api/v1/home"
        }
    }

    var method: Moya.Method {
        switch endpoint {
        case .fetchHome:
            return .get
        }
    }

    var task: Moya.Task {
        switch endpoint {
        case .fetchHome:
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
        Data()
    }
}
