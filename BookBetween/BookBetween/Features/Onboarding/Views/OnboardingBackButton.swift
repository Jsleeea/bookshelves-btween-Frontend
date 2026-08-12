//
//  OnboardingBackButton.swift
//  BookBetween
//
//  Created by 최윤석 on 7/26/26.
//

import SwiftUI

// MARK: - 이전 페이지 버튼

struct OnboardingBackButton: View {
  let action: () -> Void

  // MARK: - 화면 구성

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
