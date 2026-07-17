//
//  OnboardingView.swift
//  BookBetween
//
//  Created by 최윤석 on 7/4/26.
//

import SwiftUI

struct OnboardingView: View {
  @StateObject private var viewModel = OnboardingViewModel()

  var body: some View {
    GeometryReader { geometry in
      ZStack {
        self.currentPageView
          .frame(width: geometry.size.width, height: geometry.size.height)

        VStack(spacing: 0) {
          OnboardingTopBar(
            backButtonAction: {
              self.viewModel.backButtonDidTap()
            },
            skipButtonAction: {
              self.viewModel.skipButtonDidTap()
            }
          )
          .padding(.horizontal, 21)
          .padding(.top, 16)

          Spacer()

          OnboardingPageIndicator(
            currentPage: self.viewModel.currentPageIndex,
            totalPage: self.viewModel.pages.count
          )
          .padding(.bottom, 32.9)

          OnboardingBottomButton(title: self.viewModel.bottomButtonTitle) {
            self.viewModel.nextButtonDidTap()
          }
          .padding(.horizontal, 29)
        }
        .frame(width: geometry.size.width, height: geometry.size.height)
        .padding(.bottom, 32)
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
