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
    GeometryReader { geometry in
      ZStack {
        Color.beige100
          .ignoresSafeArea()

        self.blueBackgroundGradient(in: geometry)

        self.greenBackgroundGradient(in: geometry)

        self.leftLeafImage(in: geometry)

        self.rightLeafImage(in: geometry)

        self.contentView(in: geometry)
      }
    }
  }

  // MARK: - 콘텐츠

  private func contentView(in geometry: GeometryProxy) -> some View {
    VStack(spacing: 0) {
      Spacer()
        .frame(height: geometry.size.height * 0.095)

      OnboardingTitleSection(page: self.page)
        .padding(.bottom, 73)

      self.previewImage(in: geometry)

      Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  // MARK: - 온보딩 이미지

  private func previewImage(in geometry: GeometryProxy) -> some View {
    Image("onboarding2")
      .resizable()
      .scaledToFit()
      .frame(width: geometry.size.width)
  }

  // MARK: - 왼쪽 나뭇잎 이미지

  private func leftLeafImage(in geometry: GeometryProxy) -> some View {
    Image("onboarding2LeafLeft")
      .resizable()
      .scaledToFit()
      .frame(width: 162, height: 316)
      .position(x: geometry.size.width * 0.17, y: geometry.size.height * 0.76)
  }

  // MARK: - 오른쪽 나뭇잎 이미지

  private func rightLeafImage(in geometry: GeometryProxy) -> some View {
    Image("onboarding2LeafRight")
      .resizable()
      .scaledToFit()
      .frame(width: 129, height: 296)
      .position(x: geometry.size.width - (129 / 2), y: geometry.size.height * 0.34)
  }

  // MARK: - 파란색 배경 그라데이션

  private func blueBackgroundGradient(in geometry: GeometryProxy) -> some View {
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
      .frame(width: geometry.size.width * 1.4, height: geometry.size.width * 1.4)
      .position(x: 0, y: geometry.size.height * 0.28)
      .ignoresSafeArea()
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
      .frame(width: geometry.size.width * 1.4, height: geometry.size.width * 1.4)
      .position(x: geometry.size.width * 1.19, y: geometry.size.height * 0.67)
      .ignoresSafeArea()
  }
}

#Preview {
  OnboardingSecondPageView(
    page: OnboardingViewModel().pages[1]
  )
}
