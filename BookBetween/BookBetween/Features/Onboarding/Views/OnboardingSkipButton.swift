//
//  OnboardingSkipButton.swift
//  BookBetween
//
//  Created by 최윤석 on 7/26/26.
//

import SwiftUI

struct OnboardingSkipButton: View {
  let action: () -> Void

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
