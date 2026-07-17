//
//  OnboardingThirdPageView.swift
//  BookBetween
//
//  Created by 최윤석 on 7/4/26.
//

import SwiftUI

// MARK: - 세 번째 온보딩 화면

struct OnboardingThirdPageView: View {
  let page: OnboardingPage

  // MARK: - 화면 구성

  var body: some View {
    ZStack {
      self.greenBackgroundGradient

      self.leftLeafImage

      self.rightLeafImage

      self.contentView
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .clipped()
    .background {
      Color.beige100
        .ignoresSafeArea()
    }
  }

  // MARK: - 콘텐츠

  private var contentView: some View {
    VStack(spacing: 0) {
      Spacer()
        .frame(height: 150)

      OnboardingTitleSection(page: self.page)
        .padding(.bottom, 28)

      self.previewImage

      Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  // MARK: - 온보딩 이미지

  private var previewImage: some View {
    Image("onboarding3")
      .resizable()
      .scaledToFit()
      .frame(width: 380, height: 243)
  }

  // MARK: - 왼쪽 나뭇잎 이미지

  private var leftLeafImage: some View {
    Image("onboarding3LeafLeft")
      .resizable()
      .scaledToFit()
      .frame(width: 115.71, height: 129.46)
      .position(x: 44.845, y: 158.84)
  }

  // MARK: - 오른쪽 나뭇잎 이미지

  private var rightLeafImage: some View {
    Image("onboarding3LeafRight")
      .resizable()
      .scaledToFit()
      .frame(width: 115.71, height: 129.46)
      .position(x: 348.855, y: 240.73)
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
      .frame(width: 518, height: 518)
      .position(x: 201, y: 500)
  }
}

#Preview {
  OnboardingThirdPageView(
    page: OnboardingViewModel().pages[2]
  )
}
