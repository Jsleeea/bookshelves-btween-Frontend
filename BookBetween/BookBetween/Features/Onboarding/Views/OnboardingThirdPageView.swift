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
    GeometryReader { geometry in
      ZStack {
        self.greenBackgroundGradient(in: geometry)

        self.leftLeafImage(in: geometry)

        self.rightLeafImage(in: geometry)

        self.contentView(in: geometry)
      }
      .clipped()
      .background {
        Color.beige100
          .ignoresSafeArea()
      }
    }
  }

  // MARK: - 콘텐츠

  private func contentView(in geometry: GeometryProxy) -> some View {
    VStack(spacing: 0) {
      Spacer()
        .frame(height: geometry.size.height * 0.17)

      OnboardingTitleSection(page: self.page)
        .padding(.bottom, 28)

      self.previewImage(in: geometry)

      Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  // MARK: - 온보딩 이미지

  private func previewImage(in geometry: GeometryProxy) -> some View {
    Image("onboarding3")
      .resizable()
      .scaledToFit()
      .frame(width: min(380, geometry.size.width - 32), height: 243)
  }

  // MARK: - 왼쪽 나뭇잎 이미지

  private func leftLeafImage(in geometry: GeometryProxy) -> some View {
    Image("onboarding3LeafLeft")
      .resizable()
      .scaledToFit()
      .frame(width: 129, height: 143)
      .position(x: 129 / 2, y: geometry.size.height * 0.18)
  }

  // MARK: - 오른쪽 나뭇잎 이미지

  private func rightLeafImage(in geometry: GeometryProxy) -> some View {
    Image("onboarding3LeafRight")
      .resizable()
      .scaledToFit()
      .frame(width: 120, height: 142)
      .position(x: geometry.size.width - (120 / 2), y: geometry.size.height * 0.29)
  }

  // MARK: - 초록색 배경 그라데이션

  private func greenBackgroundGradient(in geometry: GeometryProxy) -> some View {
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
      .frame(width: geometry.size.width * 1.29, height: geometry.size.width * 1.29)
      .position(x: geometry.size.width / 2, y: geometry.size.height * 0.57)
  }
}

#Preview {
  OnboardingThirdPageView(
    page: OnboardingViewModel().pages[2]
  )
}
