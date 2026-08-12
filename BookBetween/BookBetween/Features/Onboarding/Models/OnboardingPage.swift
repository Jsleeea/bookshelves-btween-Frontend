//
//  OnboardingPage.swift
//  BookBetween
//
//  Created by 최윤석 on 7/4/26.
//

import SwiftUI

// MARK: - 온보딩 페이지 모델

struct OnboardingPage: Identifiable {
  let id: Int
  let titleParts: [OnboardingTitlePart]
  let description: String

  var fullTitle: String {
    self.titleParts.map(\.text).joined()
  }
}

// MARK: - 온보딩 제목 스타일 모델

struct OnboardingTitlePart: Identifiable {
  let id = UUID()
  let text: String
  let color: Color
}
