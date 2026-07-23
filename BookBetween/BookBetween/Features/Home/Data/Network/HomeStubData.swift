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
      "code": "HOME200",
      "message": "홈 화면 조회에 성공했습니다.",
      "result": {
        "member": {
          "nickname": "책 먹는 여우"
        },
        "recommendedAt": "2026-07-14",
        "recommendedBook": {
          "recommendationMessage": "멸망한 세계의 어느날 나의 주인이 죽었다",
          "book": {
            "id": 1,
            "isbn": "9788936434595",
            "title": "랑과 나의 사막",
            "author": "천선란",
            "publisher": "창비",
            "coverImageUrl": null,
            "kdcCode": "813",
            "kdcName": "문학"
          }
        },
        "recentBook": {
          "memberBook": {
            "id": 10,
            "progress": 70,
            "status": "READING",
            "rating": 4.5
          },
          "memberBookHistory": {
            "id": 25,
            "createdAt": "2026-07-14T04:30:00+09:00"
          },
          "book": {
            "id": 1,
            "isbn": "9788936434595",
            "title": "혼모노",
            "author": "성해나",
            "publisher": "창비",
            "coverImageUrl": null,
            "kdcCode": null,
            "kdcName": null
          }
        },
        "meetings": [
          {
            "meeting": {
              "id": 21,
              "status": "RECRUITING",
              "startDate": "2026-07-20T19:00:00+09:00",
              "currentParticipants": 4,
              "maxParticipants": 6,
              "duration": 30
            },
            "book": {
              "id": 1,
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
