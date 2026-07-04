//
//  OnboardingBottomButton.swift
//  BookBetween
//
//  Created by Codex on 7/4/26.
//

import SwiftUI

struct OnboardingBottomButton: View {
  let title: String
  let action: () -> Void

  var body: some View {
    Button(action: self.action) {
      Text(self.title)
        .body1SemiBoldStyle
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 58)
        .background(Color.green800)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
  }
}

#Preview {
  OnboardingBottomButton(title: "다음") {
  }
}
