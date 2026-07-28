//
//  MemberProfileDTO.swift
//  BookBetween
//

import Foundation

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
