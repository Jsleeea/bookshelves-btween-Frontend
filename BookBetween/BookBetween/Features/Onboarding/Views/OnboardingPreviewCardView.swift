//
//  OnboardingPreviewCardView.swift
//  BookBetween
//
//  Created by Codex on 7/4/26.
//

import SwiftUI

struct OnboardingPreviewCardView: View {
  var body: some View {
    RoundedRectangle(cornerRadius: 12)
      .fill(Color.white)
      .frame(width: 300, height: 125)
  }
}

#Preview {
  OnboardingPreviewCardView()
}
