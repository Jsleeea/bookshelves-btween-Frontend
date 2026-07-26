//
//  MyLibraryViewModel.swift
//  BookBetween
//

import Foundation
import Observation

enum MyLibraryTab: CaseIterable {
	case all
	case read
	case reading
	case toRead

	var title: String {
		switch self {
		case .all: return "전체"
		case .read: return "읽은 책"
		case .reading: return "읽는 중"
		case .toRead: return "읽기 전"
		}
	}
}

@Observable
final class MyLibraryViewModel {

	// MARK: - Properties

	var selectedTab: MyLibraryTab = .all
	var records: [UserBookRecord] = []

	var filteredRecords: [UserBookRecord] {
		switch self.selectedTab {
		case .all:
			return self.records
		case .read:
			return self.records.filter { $0.progress >= 100 }
		case .reading:
			return self.records.filter { $0.progress > 0 && $0.progress < 100 }
		case .toRead:
			return self.records.filter { $0.progress == 0 }
		}
	}

	// MARK: - Init

	init() {
		self.records = [
			UserBookRecord(
				id: 1,
				book: Book(
					id: 1,
					title: "싯다르타",
					author: "최은영",
					description: "헤르만 헤세의 대표작. 인도를 배경으로 한 청년 싯다르타의 깨달음의 여정을 담은 소설로, 자아를 찾아 떠나는 구도의 길과 삶의 의미에 대한 깊은 통찰을 담고 있습니다.",
					kdcName: "인도철학"
				),
				progress: 100,
				rating: 4.5,
				memo: "강은 어디에나 있다. 입구이자 출구이며, 시작이자 끝이다."
			),
			UserBookRecord(
				id: 2,
				book: Book(
					id: 2,
					title: "혼모노",
					author: "성해나",
					description: "성해나 작가의 단편 소설집 『혼모노』는 진짜와 가짜, 믿음에 대한 날카로운 질문을 던지는 작품입니다.\n표제작 『혼모노』는 신발을 읽고 20대 애기 무당에게 자리를 빼앗긴 베테랑 무당이 진정한 자신의 정체성을 찾아가는 과정을 그립니다.",
					kdcName: "한국소설"
				),
				progress: 0,
				rating: nil,
				memo: "진짜란 무엇인가?"
			),
			UserBookRecord(
				id: 3,
				book: Book(
					id: 3,
					title: "오만과 편견",
					author: "제인 오스틴",
					description: "19세기 영국을 배경으로 엘리자베스 베넷과 다아시의 사랑 이야기를 통해 당시 사회의 오만함과 편견을 날카롭게 풍자한 소설입니다.",
					kdcName: "영국소설"
				),
				progress: 70,
				rating: 4.5,
				memo: "사라지지 않는 것이 있다면, 그건 마음의 결"
			)
		]
	}
}
