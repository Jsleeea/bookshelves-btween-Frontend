//
//  CommonModalView.swift
//  BookBetween
//

import SwiftUI

enum CommonModalIconGradientStyle {
  case green
  case error
}

struct CommonModalView<Icon: View>: View {
  let title: String
  let confirmTitle: String
  let titleColor: Color
  let confirmColor: Color
  let iconGradientStyle: CommonModalIconGradientStyle
  let iconSize: CGFloat
  let modalHeight: CGFloat
  let icon: Icon
  var onConfirm: () -> Void = {}

  init(
    title: String,
    confirmTitle: String,
    titleColor: Color = .gray800,
    confirmColor: Color = .green600,
    iconGradientStyle: CommonModalIconGradientStyle = .green,
    iconSize: CGFloat = 56,
    modalHeight: CGFloat = 220,
    onConfirm: @escaping () -> Void = {},
    @ViewBuilder icon: () -> Icon
  ) {
    self.title = title
    self.confirmTitle = confirmTitle
    self.titleColor = titleColor
    self.confirmColor = confirmColor
    self.iconGradientStyle = iconGradientStyle
    self.iconSize = iconSize
    self.modalHeight = modalHeight
    self.onConfirm = onConfirm
    self.icon = icon()
  }

  var body: some View {
    VStack(spacing: 0) {
      self.iconSection

      self.buttonSection
        .padding(.top, 24)
    }
    .padding(.horizontal, 30)
    .padding(.vertical, 20)
    .frame(width: 300, height: self.modalHeight, alignment: .center)
    .background(Color.beige100)
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .shadow(
      color: Color(red: 0.17, green: 0.16, blue: 0.16).opacity(0.16),
      radius: 24,
      x: 0,
      y: 20
    )
    .overlay {
      RoundedRectangle(cornerRadius: 12)
        .inset(by: 0.5)
        .stroke(.white, lineWidth: 1)
    }
  }

  private var iconSection: some View {
    VStack(spacing: 20) {
      self.icon
        .padding(.top, (100 - self.iconSize) / 2)
        .background(alignment: .top) {
          self.iconGradient
            .frame(width: 100, height: 100)
            .clipShape(Circle())
        }

      Text(self.title)
        .head3Style
        .foregroundStyle(self.titleColor)
        .multilineTextAlignment(.center)
    }
  }

  private var iconGradient: EllipticalGradient {
    switch self.iconGradientStyle {
    case .green:
      EllipticalGradient(
        stops: [
          Gradient.Stop(
            color: Color(red: 0.8, green: 0.88, blue: 0.82).opacity(0.5),
            location: 0.51
          ),
          Gradient.Stop(color: .white.opacity(0), location: 1)
        ],
        center: UnitPoint(x: 0.5, y: 0.46)
      )

    case .error:
      EllipticalGradient(
        stops: [
          Gradient.Stop(color: Color.red500.opacity(0.3), location: 0),
          Gradient.Stop(color: .white.opacity(0), location: 1)
        ],
        center: UnitPoint(x: 0.5, y: 0.5)
      )
    }
  }

  private var buttonSection: some View {
    Button(action: self.onConfirm) {
      Text(self.confirmTitle)
        .body1SemiBoldStyle
        .foregroundStyle(Color.beige100)
        .frame(maxWidth: .infinity, minHeight: 40)
        .background(self.confirmColor)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
  }
}
