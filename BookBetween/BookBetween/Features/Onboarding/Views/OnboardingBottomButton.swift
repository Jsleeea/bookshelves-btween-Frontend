//
//  OnboardingBottomButton.swift
//  BookBetween
//
//  Created by 최윤석 on 7/4/26.
//

import SwiftUI

// MARK: - 다음 페이지 버튼

struct OnboardingBottomButton: View {
  let title: String
  let action: () -> Void

  // MARK: - 화면 구성

  var body: some View {
    Button(action: self.action) {
      Text(self.title)
        .body1SemiBoldStyle
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 53)
        .background(Color.green800)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
  }
}

#Preview {
  OnboardingBottomButton(title: "다음") {
  }
}
