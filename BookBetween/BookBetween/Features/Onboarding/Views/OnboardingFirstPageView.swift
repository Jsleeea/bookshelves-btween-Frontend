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
    GeometryReader { geometry in
      ZStack {
        Color.beige100
          .ignoresSafeArea()

        self.backgroundGradient(in: geometry)

        VStack(spacing: 0) {
          Spacer()
            .frame(height: geometry.size.height * 0.11)

          OnboardingTitleSection(page: self.page)
            .padding(.bottom, 43)

          Image("onboarding1")
            .resizable()
            .scaledToFit()
            .frame(width: min(297, geometry.size.width - 32), height: 363)

          Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
    }
  }

  // MARK: - 배경 그라데이션

  private func backgroundGradient(in geometry: GeometryProxy) -> some View {
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
      .frame(width: geometry.size.width * 1.34, height: geometry.size.width * 1.34)
      .position(x: 0, y: geometry.size.height * 0.31)
      .ignoresSafeArea()
  }
}

#Preview {
  OnboardingFirstPageView(
    page: OnboardingViewModel().pages[0]
  )
}
