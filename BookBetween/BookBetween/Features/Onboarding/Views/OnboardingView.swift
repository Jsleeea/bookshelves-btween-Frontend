//
//  OnboardingView.swift
//  BookBetween
//
//  Created by Codex on 7/4/26.
//

import SwiftUI

struct OnboardingView: View {
  @StateObject private var viewModel = OnboardingViewModel()

  var body: some View {
    ZStack {
      OnboardingBackgroundView()

      VStack {
        Spacer()

        OnboardingPreviewCardView()

        Spacer()

        OnboardingPageIndicator(
          currentPage: self.viewModel.currentPageIndex,
          totalPage: 3
        )

        OnboardingBottomButton(title: "다음") {
        }
      }
      .padding(.horizontal, 24)
      .padding(.bottom, 32)
    }
  }
}

#Preview {
  OnboardingView()
}
