//
//  OnboardingView.swift
//  BookBetween
//
//  Created by 최윤석 on 7/4/26.
//

import SwiftUI

struct OnboardingView: View {
  @StateObject private var viewModel = OnboardingViewModel()

  let onComplete: () -> Void

  init(onComplete: @escaping () -> Void = {}) {
    self.onComplete = onComplete
  }

  var body: some View {
    GeometryReader { geometry in
      ZStack {
        self.currentPageView
          .frame(width: geometry.size.width, height: geometry.size.height)

        VStack(spacing: 0) {
          if self.viewModel.currentPageIndex > 0 {
            OnboardingBackButton {
              self.viewModel.backButtonDidTap()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 21)
            .padding(.top, 16)
          }

          Spacer()

          OnboardingPageIndicator(
            currentPage: self.viewModel.currentPageIndex,
            totalPage: self.viewModel.pages.count
          )
          .padding(.bottom, 32.9)

          OnboardingBottomButton(title: self.viewModel.bottomButtonTitle) {
            if self.viewModel.isLastPage {
              self.onComplete()
            } else {
              self.viewModel.nextButtonDidTap()
            }
          }
          .padding(.horizontal, 29)
          .padding(.bottom, 24)

          if !self.viewModel.isLastPage {
            OnboardingSkipButton {
              self.onComplete()
            }
          } else {
            OnboardingSkipButton {}
              .hidden()
              .allowsHitTesting(false)
          }
        }
        .frame(width: geometry.size.width, height: geometry.size.height)
        .padding(.bottom, 27)
      }
      .frame(width: geometry.size.width, height: geometry.size.height)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  @ViewBuilder
  private var currentPageView: some View {
    switch self.viewModel.currentPageIndex {
    case 0:
      OnboardingFirstPageView(page: self.viewModel.currentPage)

    case 1:
      OnboardingSecondPageView(page: self.viewModel.currentPage)

    default:
      OnboardingThirdPageView(page: self.viewModel.currentPage)
    }
  }

}

#Preview {
  OnboardingView()
}
