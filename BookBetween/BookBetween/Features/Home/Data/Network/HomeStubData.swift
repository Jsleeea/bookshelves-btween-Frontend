//
//  HomeStubData.swift
//  BookBetween
//

import Foundation

enum HomeStubData {
    static func data(for endpoint: HomeTarget.Endpoint) -> Data {
        switch endpoint {
        case .fetchHome:
            return Data(homeResponse.utf8)
        }
    }

    private static let homeResponse = """
    {
      "isSuccess": true,
      "code": "HOME200_1",
      "message": "홈 화면 조회에 성공했습니다.",
      "result": {
        "member": {
          "nickname": "책 먹는 여우"
        },
        "recommendedAt": "2026-07-31",
        "recommendedBook": {
          "recommendationMessage": "감정을 배우는 소년의 조용한 성장 기록",
          "book": {
            "id": 1,
            "isbn": "9788936434267",
            "title": "아몬드",
            "author": "손원평",
            "publisher": "창비",
            "coverImageUrl": null,
            "kdcCode": "813",
            "kdcName": "한국소설"
          }
        },
        "recentBook": {
          "memberBook": {
            "id": 10,
            "progress": 70,
            "status": "READING",
            "rating": 4.5,
            "updatedAt": "2026-07-30T04:30:00"
          },
          "book": {
            "id": 2,
            "isbn": "9788936434595",
            "title": "혼모노",
            "author": "성해나",
            "publisher": "창비",
            "coverImageUrl": null,
            "kdcCode": "813",
            "kdcName": "한국소설"
          }
        },
        "meetings": [
          {
            "meeting": {
              "id": 21,
              "status": "RECRUITING",
              "startDate": "2026-08-02T19:00:00",
              "currentParticipants": 4,
              "maxParticipants": 6,
              "duration": 30
            },
            "book": {
              "id": 2,
              "title": "혼모노",
              "publisher": "창비",
              "coverImageUrl": null
            }
          },
          {
            "meeting": {
              "id": 22,
              "status": "RECRUITING",
              "startDate": "2026-07-21T18:00:00+09:00",
              "currentParticipants": 3,
              "maxParticipants": 5,
              "duration": 40
            },
            "book": {
              "id": 2,
              "title": "프로젝트 헤일메리",
              "publisher": "RHK(알에이치코리아)",
              "coverImageUrl": null
            }
          },
          {
            "meeting": {
              "id": 23,
              "status": "RECRUITING",
              "startDate": "2026-07-22T20:00:00+09:00",
              "currentParticipants": 2,
              "maxParticipants": 6,
              "duration": 50
            },
            "book": {
              "id": 3,
              "title": "데미안",
              "publisher": "민음사",
              "coverImageUrl": null
            }
          }
        ]
      }
    }
    """
}
