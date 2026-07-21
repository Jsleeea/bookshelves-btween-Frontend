//
//  BookStubData.swift
//  BookBetween
//

import Foundation

enum BookStubData {
    static func data(for endpoint: BookTarget.Endpoint) -> Data {
        let json: String

        switch endpoint {
        case let .search(_, page, size):
            json = searchResponse(page: page, size: size)
        case .detail:
            json = detailResponse
        case .recentSearches:
            json = recentSearchesResponse
        }

        return Data(json.utf8)
    }

    private static func searchResponse(page: Int, size: Int) -> String {
        if page > 1 {
            return """
            {
              "isSuccess": true,
              "code": "BOOK200",
              "message": "도서 검색에 성공했습니다.",
              "result": {
                "books": [
                  {
                    "isbn": "9788937460449",
                    "title": "데미안",
                    "author": "헤르만 헤세",
                    "publisher": "민음사",
                    "publishedDate": "2000-12-20",
                    "description": "한 인간이 자신에게 이르는 길을 그린 성장 소설입니다.",
                    "coverImageUrl": null,
                    "saveable": true
                  }
                ],
                "page": \(page),
                "size": \(size),
                "hasNext": false
              }
            }
            """
        }

        return """
        {
          "isSuccess": true,
          "code": "BOOK200",
          "message": "도서 검색에 성공했습니다.",
          "result": {
            "books": [
              {
                "isbn": "9788936434595",
                "title": "혼모노",
                "author": "성해나",
                "publisher": "창비",
                "publishedDate": "2024-03-29",
                "description": "진짜와 가짜, 믿음에 대한 질문을 던지는 소설집입니다.",
                "coverImageUrl": null,
                "saveable": true
              },
              {
                "isbn": null,
                "title": "이끼숲",
                "author": "천선란",
                "publisher": "자이언트북스",
                "publishedDate": "2023-05-25",
                "description": "서로를 지키며 살아가는 사람들의 이야기입니다.",
                "coverImageUrl": null,
                "saveable": false
              },
              {
                "isbn": "9788937460883",
                "title": "오만과 편견",
                "author": "제인 오스틴",
                "publisher": "민음사",
                "publishedDate": "2003-09-20",
                "description": "편견과 오해를 넘어 서로를 이해하는 이야기입니다.",
                "coverImageUrl": null,
                "saveable": true
              }
            ],
            "page": 1,
            "size": \(size),
            "hasNext": true
          }
        }
        """
    }

    private static let detailResponse = """
    {
      "isSuccess": true,
      "code": "BOOK200",
      "message": "책 상세 조회에 성공했습니다.",
      "result": {
        "book": {
          "id": null,
          "isbn": "9788936434595",
          "title": "혼모노",
          "author": "성해나",
          "publisher": "창비",
          "publishedDate": "2024-03-29",
          "description": "진짜와 가짜, 믿음에 대한 질문을 던지는 소설집입니다.",
          "coverImageUrl": null,
          "kdcCode": "813",
          "kdcName": "문학"
        },
        "memberBook": {
          "id": 10,
          "progress": 70,
          "rating": 4.5,
          "memo": "진짜란 무엇인가?"
        }
      }
    }
    """

    private static let recentSearchesResponse = """
    {
      "isSuccess": true,
      "code": "BOOK200",
      "message": "최근 검색어 조회에 성공했습니다.",
      "result": {
        "recentSearches": [
          {
            "keyword": "혼모노",
            "searchedAt": "2026-07-21T09:30:00+09:00"
          },
          {
            "keyword": "천선란",
            "searchedAt": "2026-07-20T18:10:00+09:00"
          },
          {
            "keyword": "데미안",
            "searchedAt": "2026-07-19T12:00:00+09:00"
          }
        ]
      }
    }
    """
}
