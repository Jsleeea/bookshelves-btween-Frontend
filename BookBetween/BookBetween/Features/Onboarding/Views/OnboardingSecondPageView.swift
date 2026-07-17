//
//  OnboardingSecondPageView.swift
//  BookBetween
//
//  Created by 최윤석 on 7/4/26.
//

import SwiftUI

// MARK: - 두 번째 온보딩 화면

struct OnboardingSecondPageView: View {
  let page: OnboardingPage

  // MARK: - 화면 구성

  var body: some View {
    ZStack {
      Color.beige100
        .ignoresSafeArea()

      self.blueBackgroundGradient

      self.greenBackgroundGradient

      self.leftLeafImage

      self.rightLeafImage

      self.contentView
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  // MARK: - 콘텐츠

  private var contentView: some View {
    VStack(spacing: 0) {
      Spacer()
        .frame(height: 83)

      OnboardingTitleSection(page: self.page)
        .padding(.bottom, 73)

      self.previewImage

      Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  // MARK: - 온보딩 이미지

  private var previewImage: some View {
    Image("onboarding2")
      .resizable()
      .scaledToFit()
      .frame(width: 556, height: 310)
  }

  // MARK: - 왼쪽 나뭇잎 이미지

  private var leftLeafImage: some View {
    Image("onboarding2LeafLeft")
      .resizable()
      .scaledToFit()
      .frame(width: 183.28, height: 273.36)
      .position(x: 155, y: 610.68)
  }

  // MARK: - 오른쪽 나뭇잎 이미지

  private var rightLeafImage: some View {
    Image("onboarding2LeafRight")
      .resizable()
      .scaledToFit()
      .frame(width: 183.28, height: 273.36)
      .position(x: 404.63, y: 287.68)
  }

  // MARK: - 파란색 배경 그라데이션

  private var blueBackgroundGradient: some View {
    Circle()
      .fill(
        EllipticalGradient(
          stops: [
            Gradient.Stop(color: Color.blue100.opacity(0.3), location: 0.30),
            Gradient.Stop(color: Color.blue100.opacity(0), location: 1)
          ],
          center: UnitPoint(x: 0.5, y: 0.5)
        )
      )
      .frame(width: 562, height: 562)
      .position(x: 1, y: 241)
      .ignoresSafeArea()
  }

  // MARK: - 초록색 배경 그라데이션

  private var greenBackgroundGradient: some View {
    Circle()
      .fill(
        EllipticalGradient(
          stops: [
            Gradient.Stop(color: Color.green50.opacity(0.8), location: 0.30),
            Gradient.Stop(color: Color.green50.opacity(0), location: 1)
          ],
          center: UnitPoint(x: 0.5, y: 0.5)
        )
      )
      .frame(width: 562, height: 562)
      .position(x: 479, y: 586)
      .ignoresSafeArea()
  }
}

#Preview {
  OnboardingSecondPageView(
    page: OnboardingViewModel().pages[1]
  )
}
