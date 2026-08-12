//
//  OnboardingTitleSection.swift
//  BookBetween
//
//  Created by 최윤석 on 7/4/26.
//

import SwiftUI

// MARK: - 온보딩 제목 영역

struct OnboardingTitleSection: View {
  let page: OnboardingPage

  // MARK: - 화면 구성

  var body: some View {
    VStack(spacing: 20) {
      self.titleText

      Text(self.page.description)
        .body1RegularStyle
        .foregroundStyle(Color.gray600)
        .multilineTextAlignment(.center)
    }
  }

  // MARK: - 제목 텍스트

  @ViewBuilder
  private var titleText: some View {
    HStack(spacing: 0) {
      ForEach(self.page.titleParts) { titlePart in
        Text(titlePart.text)
          .head2Style
          .foregroundStyle(titlePart.color)
      }
    }
    .multilineTextAlignment(.center)
  }
}

#Preview {
  OnboardingTitleSection(
    page: OnboardingPage(
      id: 0,
      titleParts: [
        OnboardingTitlePart(text: "익명으로 ", color: Color.green800),
        OnboardingTitlePart(text: "만나는 ", color: Color.gray700),
        OnboardingTitlePart(text: "독서모임", color: Color.gray800)
      ],
      description: "관계에 지치지 않게,\n한 권의 책으로만 연결되는 대화"
    )
  )
}
