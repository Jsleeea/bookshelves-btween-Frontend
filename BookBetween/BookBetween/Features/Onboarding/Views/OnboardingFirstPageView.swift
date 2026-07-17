//
//  OnboardingFirstPageView.swift
//  BookBetween
//
//  Created by 최윤석 on 7/4/26.
//

import SwiftUI

// MARK: - 첫 번째 온보딩 화면

struct OnboardingFirstPageView: View {
  let page: OnboardingPage

  // MARK: - 화면 구성

  var body: some View {
    ZStack {
      Color.beige100
        .ignoresSafeArea()

      self.backgroundGradient

      VStack(spacing: 0) {
        Spacer()
          .frame(height: 98)

        OnboardingTitleSection(page: self.page)
          .padding(.bottom, 43)

        Image("onboarding1")
          .resizable()
          .scaledToFit()
          .frame(width: 297, height: 363)

        Spacer()
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  // MARK: - 배경 그라데이션

  private var backgroundGradient: some View {
    Circle()
      .fill(
        EllipticalGradient(
          stops: [
            Gradient.Stop(color: Color.green50.opacity(0.3), location: 0.30),
            Gradient.Stop(color: Color.green50.opacity(0), location: 1)
          ],
          center: UnitPoint(x: 0.5, y: 0.5)
        )
      )
      .frame(width: 540, height: 540)
      .position(x: 0, y: 270)
      .ignoresSafeArea()
  }
}

#Preview {
  OnboardingFirstPageView(
    page: OnboardingViewModel().pages[0]
  )
}
