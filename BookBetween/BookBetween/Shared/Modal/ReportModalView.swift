//
//  ReportModalView.swift
//  BookBetween
//

import SwiftUI

struct ReportModalView: View {
  var onConfirm: () -> Void = {}

  var body: some View {
    CommonModalView(
      title: "신고되었습니다",
      confirmTitle: "확인",
      confirmColor: .red700,
      iconGradientStyle: .error,
      modalHeight: 220,
      onConfirm: self.onConfirm
    ) {
      Image("icon_siren")
        .resizable()
        .scaledToFit()
        .frame(width: 56, height: 56)
    }
  }
}

#Preview {
  ReportModalView()
}
