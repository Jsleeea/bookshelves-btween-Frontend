//
//  SearchIdleView.swift
//  BookBetween
//

import SwiftUI

struct SearchIdleView: View {
    enum Mode {
        case idle
        case emptyResult
    }

    let height: CGFloat
    var mode: Mode = .idle
    var customTitle: String? = nil
    var actionTitle: String? = nil
    var onAction: (() -> Void)? = nil

    private var titleText: String {
        if let customTitle { return customTitle }
        switch mode {
        case .idle:
            return "원하는 책을 찾아보세요"
        case .emptyResult:
            return "검색된 도서가 없습니다"
        }
    }

    private var subtitleText: String? {
        guard customTitle == nil else { return nil }
        switch mode {
        case .idle:
            return "책 제목, 저자, 키워드로\n쉽고 빠르게 검색할 수 있어요"
        case .emptyResult:
            return nil
        }
    }

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width

            ZStack(alignment: .top) {
                RadialGradient(
                    colors: [
                        Color(hex: "DCEBE1").opacity(0.58),
                        Color.white.opacity(0)
                    ],
                    center: .center,
                    startRadius: 12,
                    endRadius: 270
                )
                .frame(width: 270 * 2, height: 270 * 2)
                .position(x: width / 2, y: height * 0.36)
                .allowsHitTesting(false)

                Image("leaf_left")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 108)
                    .position(x: 30, y: height * 0.07)
                    .allowsHitTesting(false)

                Image("leaf_right")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 108)
                    .position(x: width - 30, y: height * 0.17)
                    .allowsHitTesting(false)

                VStack(spacing: 0) {
                    Image("search_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 152, height: 134)
                        .allowsHitTesting(false)

                    VStack(spacing: 24) {
                        Text(titleText)
                            .pointText4Style
                            .foregroundStyle(Color.green900)

                        if let subtitleText {
                            Text(subtitleText)
                                .body2RegularStyle
                                .foregroundStyle(Color.gray600)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top, 32)
                    .allowsHitTesting(false)

                    if let actionTitle, let onAction {
                        Button(action: onAction) {
                            Text(actionTitle)
                                .body2RegularStyle
                                .foregroundStyle(Color.gray600)
                                .underline()
                        }
                        .padding(.top, 20)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, height * 0.36 - 134 / 2)
            }
        }
        .frame(height: height)
    }
}

#Preview("Idle") {
    SearchIdleView(height: 520, mode: .idle)
}

#Preview("Empty Result") {
    SearchIdleView(height: 520, mode: .emptyResult)
}
