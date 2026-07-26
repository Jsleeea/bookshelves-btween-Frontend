//
//  OnboardingBackButton.swift
//  BookBetween
//
//  Created by 최윤석 on 7/26/26.
//

import SwiftUI

struct OnboardingBackButton: View {
  let action: () -> Void

  var body: some View {
    Button(action: self.action) {
      Image(systemName: "chevron.left")
        .frame(width: 12.41261, height: 24)
        .foregroundStyle(Color.gray500)
    }
  }
}

#Preview {
  OnboardingBackButton {
  }
}
