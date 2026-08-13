//
//  NicknameGenerator.swift
//  BookBetween
//

import Foundation
import SwiftUI

// MARK: - 랜덤 닉네임 생성기

struct GeneratedNickname {
    let noun: String
    let modifier: String
    let animal: String
    let animalImageName: String
    let profileBackgroundColor: ProfileBackgroundColorCode

    var text: String {
        "\(noun) \(modifier) \(animal)"
    }

    static let placeholder = GeneratedNickname(
        noun: "책",
        modifier: "먹는",
        animal: "곰",
        animalImageName: "animal_bear",
        profileBackgroundColor: .brown
    )
}

nonisolated enum ProfileBackgroundColorCode: String, Codable {
    case brown = "BROWN"
    case purple = "PURPLE"
    case blue = "BLUE"
    case green = "GREEN"
    case red = "RED"
    case yellow = "YELLOW"
}

// MARK: - 프로필 배경 그라데이션

extension ProfileBackgroundColorCode {
    private var endColor: Color {
        switch self {
        case .purple:
            Color(red: 0.47, green: 0.47, blue: 0.75)
        case .blue:
            Color(red: 0.51, green: 0.73, blue: 0.96)
        case .green:
            Color(red: 0.6, green: 0.76, blue: 0.65)
        case .red:
            Color(red: 1, green: 0.46, blue: 0.3)
        case .yellow:
            Color(red: 0.94, green: 0.79, blue: 0.37)
        case .brown:
            Color(red: 0.69, green: 0.5, blue: 0.28)
        }
    }

    var profileGradient: LinearGradient {
        LinearGradient(
            stops: [
                Gradient.Stop(color: Color.white.opacity(0.4), location: 0),
                Gradient.Stop(color: self.endColor, location: 1)
            ],
            startPoint: UnitPoint(x: -0.17, y: 0.17),
            endPoint: UnitPoint(x: 1.17, y: 0.83)
        )
    }
}

enum NicknameGenerator {
    // MARK: - 랜덤 닉네임 단어 목록

    private static let subjects = [
        "책", "문장", "책장", "책갈피", "서재", "소설", "시집", "단어",
        "문단", "페이지", "표지", "잉크", "글자", "필사", "목차", "여백",
        "문고", "도서", "장면", "구절", "결말", "북마크", "책등", "한줄평",
        "동화", "고전", "이야기", "책방", "도서관"
    ]

    private static let adjectives = [
        "먹는", "읽는", "빌리는", "엎는", "던지는", "모으는", "여는",
        "덮는", "고르는", "숨기는", "줍는", "찾는", "따라가는", "물고 온",
        "기다리는", "속삭이는", "좋아하는", "기록하는", "간직하는", "훔치는",
        "지키는", "넘기는", "쏟는", "적는", "옮기는", "나르는"
    ]

    private static let animals: [NicknameAnimal] = [
        NicknameAnimal(name: "곰", imageName: "animal_bear", backgroundColor: .brown),
        NicknameAnimal(name: "다람쥐", imageName: "animal_squirrel", backgroundColor: .brown),
        NicknameAnimal(name: "여우", imageName: "animal_fox", backgroundColor: .brown),
        NicknameAnimal(name: "고슴도치", imageName: "animal_hedgehog", backgroundColor: .brown),
        NicknameAnimal(name: "나무늘보", imageName: "animal_sloth", backgroundColor: .brown),
        NicknameAnimal(name: "올빼미", imageName: "animal_owl", backgroundColor: .purple),
        NicknameAnimal(name: "너구리", imageName: "animal_raccoon", backgroundColor: .purple),
        NicknameAnimal(name: "북극곰", imageName: "animal_polar_bear", backgroundColor: .purple),
        NicknameAnimal(name: "판다", imageName: "animal_panda", backgroundColor: .purple),
        NicknameAnimal(name: "코알라", imageName: "animal_koala", backgroundColor: .purple),
        NicknameAnimal(name: "코끼리", imageName: "animal_elephant", backgroundColor: .blue),
        NicknameAnimal(name: "고래", imageName: "animal_whale", backgroundColor: .blue),
        NicknameAnimal(name: "상어", imageName: "animal_shark", backgroundColor: .blue),
        NicknameAnimal(name: "펭귄", imageName: "animal_penguin", backgroundColor: .blue),
        NicknameAnimal(name: "악어", imageName: "animal_crocodile", backgroundColor: .green),
        NicknameAnimal(name: "개구리", imageName: "animal_frog", backgroundColor: .green),
        NicknameAnimal(name: "거북이", imageName: "animal_turtle", backgroundColor: .green),
        NicknameAnimal(name: "토끼", imageName: "animal_rabbit", backgroundColor: .red),
        NicknameAnimal(name: "수달", imageName: "animal_otter", backgroundColor: .red),
        NicknameAnimal(name: "비버", imageName: "animal_beaver", backgroundColor: .red),
        NicknameAnimal(name: "얼룩말", imageName: "animal_zebra", backgroundColor: .red),
        NicknameAnimal(name: "사자", imageName: "animal_lion", backgroundColor: .yellow),
        NicknameAnimal(name: "호랑이", imageName: "animal_tiger", backgroundColor: .yellow),
        NicknameAnimal(name: "치타", imageName: "animal_cheetah", backgroundColor: .yellow),
        NicknameAnimal(name: "기린", imageName: "animal_giraffe", backgroundColor: .yellow)
    ]

    // MARK: - 랜덤 닉네임 생성

    static func animalImageName(for animalName: String) -> String {
        animals.first { $0.name == animalName }?.imageName
            ?? GeneratedNickname.placeholder.animalImageName
    }

    static func defaultBackgroundColor(for animalName: String) -> ProfileBackgroundColorCode {
        animals.first { $0.name == animalName }?.backgroundColor
            ?? GeneratedNickname.placeholder.profileBackgroundColor
    }

    static func animalName(fromNickname nickname: String) -> String {
        nickname.split(separator: " ").last.map(String.init) ?? nickname
    }

    static func generate(excluding currentNickname: String? = nil) -> GeneratedNickname {
        var nickname = makeNickname()

        while nickname.text == currentNickname {
            nickname = makeNickname()
        }

        return nickname
    }

    private static func makeNickname() -> GeneratedNickname {
        guard
            let subject = subjects.randomElement(),
            let adjective = adjectives.randomElement(),
            let animal = animals.randomElement()
        else {
            return .placeholder
        }

        return GeneratedNickname(
            noun: subject,
            modifier: adjective,
            animal: animal.name,
            animalImageName: animal.imageName,
            profileBackgroundColor: animal.backgroundColor
        )
    }
}

// MARK: - 닉네임 동물 정보

private struct NicknameAnimal {
    let name: String
    let imageName: String
    let backgroundColor: ProfileBackgroundColorCode
}
