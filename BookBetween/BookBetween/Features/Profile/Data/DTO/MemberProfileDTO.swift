//
//  MemberProfileDTO.swift
//  BookBetween
//

import Foundation

// MARK: - 회원 정보 수정 요청

nonisolated struct MemberProfileUpdateRequestDTO: Encodable {
    let nicknameNoun: String?
    let nicknameModifier: String?
    let nicknameAnimal: String?
    let profileBackgroundColor: ProfileBackgroundColorCode?
    let categoryIds: [Int]?

    init(
        nickname: GeneratedNickname? = nil,
        profileBackgroundColor: ProfileBackgroundColorCode? = nil,
        categoryIds: [Int]? = nil
    ) {
        self.nicknameNoun = nickname?.noun
        self.nicknameModifier = nickname?.modifier
        self.nicknameAnimal = nickname?.animal
        self.profileBackgroundColor = profileBackgroundColor
        self.categoryIds = categoryIds
    }
}

// MARK: - 회원 탈퇴 응답

nonisolated struct MemberWithdrawalResultDTO: Decodable {
    let scheduledDeletionAt: String
}

// MARK: - 회원 정보 응답

nonisolated struct MemberProfileResultDTO: Decodable {
    let id: Int
    let nickname: String
    let nicknameNoun: String
    let nicknameModifier: String
    let nicknameAnimal: String
    let profileBackgroundColor: String
    let createdAt: String
    let categories: [MemberCategoryDTO]

    func toDomain() -> MemberProfile {
        MemberProfile(
            memberId: id,
            nickname: nickname,
            nicknameNoun: nicknameNoun,
            nicknameModifier: nicknameModifier,
            nicknameAnimal: nicknameAnimal,
            profileBackgroundColor: profileBackgroundColor,
            joinedDays: calculateJoinedDays(from: createdAt),
            categories: categories.map { $0.toDomain() }
        )
    }

    private func calculateJoinedDays(
        from createdAt: String,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> Int {
        let dateText = String(createdAt.prefix(10))
        let components = dateText.split(separator: "-").compactMap {
            Int($0)
        }

        guard components.count == 3,
              let createdDate = calendar.date(
                from: DateComponents(
                    year: components[0],
                    month: components[1],
                    day: components[2]
                )
              ) else {
            return 1
        }

        let elapsedDays = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: createdDate),
            to: calendar.startOfDay(for: now)
        ).day ?? 0

        return max(elapsedDays + 1, 1)
    }
}

nonisolated struct MemberCategoryDTO: Decodable {
    let id: Int
    let name: String

    func toDomain() -> MemberCategory {
        MemberCategory(
            categoryId: id,
            name: name
        )
    }
}
