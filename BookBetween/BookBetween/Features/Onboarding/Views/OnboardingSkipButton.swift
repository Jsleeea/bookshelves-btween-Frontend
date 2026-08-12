//
//  OnboardingSkipButton.swift
//  BookBetween
//
//  Created by 최윤석 on 7/26/26.
//

import SwiftUI

// MARK: - 건너뛰기 버튼

struct OnboardingSkipButton: View {
  let action: () -> Void

  // MARK: - 화면 구성

  var body: some View {
    Button(action: self.action) {
      Text("건너뛰기")
        .body1SemiBoldStyle
        .foregroundStyle(Color.gray800)
    }
  }
}

#Preview {
  OnboardingSkipButton {
  }
}
