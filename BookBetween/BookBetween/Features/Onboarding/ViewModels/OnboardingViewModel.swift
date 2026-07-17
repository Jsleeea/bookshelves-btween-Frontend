//
//  OnboardingViewModel.swift
//  BookBetween
//
//  Created by 최윤석 on 7/4/26.
//

import Combine
import Foundation
import SwiftUI

final class OnboardingViewModel: ObservableObject {
  @Published var currentPageIndex: Int = 0

  let pages: [OnboardingPage] = [
    OnboardingPage(
      id: 0,
      titleParts: [
        OnboardingTitlePart(text: "익명으로 ", color: Color.green800),
        OnboardingTitlePart(text: "만나는 ", color: Color.gray700),
        OnboardingTitlePart(text: "독서모임", color: Color.gray800)
      ],
      description: "관계에 지치지 않게,\n한 권의 책으로만 연결되는 대화"
    ),
    OnboardingPage(
      id: 1,
      titleParts: [
        OnboardingTitlePart(text: "AI와 함께하는 ", color: Color.gray800),
        OnboardingTitlePart(text: "깊이있는 독서", color: Color.green700)
      ],
      description: "질문, 요약, 인사이트까지\n읽고 생각하는 시간을 함께해요."
    ),
    OnboardingPage(
      id: 2,
      titleParts: [
        OnboardingTitlePart(text: "나만의 서재", color: Color.gray800)
      ],
      description: "읽은 책들을 기록하고,\n언제든 다시 꺼내볼 수 있게"
    )
  ]

  var currentPage: OnboardingPage {
    self.pages[self.currentPageIndex]
  }

  var isLastPage: Bool {
    self.currentPageIndex == self.pages.count - 1
  }

  var bottomButtonTitle: String {
    self.isLastPage ? "시작하기" : "다음"
  }

  func backButtonDidTap() {
    guard self.currentPageIndex > 0 else {
      return
    }

    self.currentPageIndex -= 1
  }

  func nextButtonDidTap() {
    guard !self.isLastPage else {
      return
    }

    self.currentPageIndex += 1
  }

  func skipButtonDidTap() {
    self.currentPageIndex = self.pages.count - 1
  }
}
