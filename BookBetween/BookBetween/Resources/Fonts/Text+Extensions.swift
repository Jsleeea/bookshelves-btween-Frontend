//
//  Text+Extensions.swift
//  BookBetween
//
//  Created by 이준성 on 6/25/26.
//

import SwiftUI

extension Text {
    private func applyAppStyle(
        _ font: Font,
        size: CGFloat,
        lineHeightPercent: CGFloat,
        letterSpacingPercent: CGFloat
    ) -> some View {
        // 자간 계산: 글자 크기 * (자간 퍼센트 / 100)
        let trackingValue = size * (letterSpacingPercent / 100.0)
        
        // 행간 계산: (글자 크기 * 행간 퍼센트 / 100) - 글자 크기
        let targetLineHeight = size * (lineHeightPercent / 100.0)
        let spacingValue = targetLineHeight - size
        
        return self
            .font(font)
            .tracking(trackingValue)
            .lineSpacing(spacingValue)
    }
    
    // Head 시리즈 (Line Height: 130%)
    var head1Style: some View { applyAppStyle(.head1, size: 24, lineHeightPercent: 130, letterSpacingPercent: -0.3) }
    var head2Style: some View { applyAppStyle(.head2, size: 22, lineHeightPercent: 130, letterSpacingPercent: -0.3) }
    var head3Style: some View { applyAppStyle(.head3, size: 18, lineHeightPercent: 130, letterSpacingPercent: -0.2) }
    var head4Style: some View { applyAppStyle(.head4, size: 18, lineHeightPercent: 130, letterSpacingPercent: -0.2) }
    
    // Body 시리즈
    var body1SemiBoldStyle: some View { applyAppStyle(.body1SemiBold, size: 16, lineHeightPercent: 155, letterSpacingPercent: 0) }
    var body1RegularStyle: some View { applyAppStyle(.body1Regular, size: 16, lineHeightPercent: 155, letterSpacingPercent: 0) }
    var body2SemiBoldStyle: some View { applyAppStyle(.body2SemiBold, size: 14, lineHeightPercent: 150, letterSpacingPercent: 0) }
    var body2RegularStyle: some View { applyAppStyle(.body2Regular, size: 14, lineHeightPercent: 150, letterSpacingPercent: 0) }
    
    // Caption 시리즈
    var caption1SemiBoldStyle: some View { applyAppStyle(.caption1SemiBold, size: 12, lineHeightPercent: 145, letterSpacingPercent: 0) }
    var caption1RegularStyle: some View { applyAppStyle(.caption1Regular, size: 12, lineHeightPercent: 145, letterSpacingPercent: 0) }
    var caption2SemiBoldStyle: some View { applyAppStyle(.caption2SemiBold, size: 10, lineHeightPercent: 145, letterSpacingPercent: 0) }
    var caption2RegularStyle: some View { applyAppStyle(.caption2Regular, size: 10, lineHeightPercent: 145, letterSpacingPercent: 0) }

    // Point Text 시리즈 (RIDIBatang / Line Height: 130%)
    var pointText1Style: some View { applyAppStyle(.custom("RIDIBatang", size: 24), size: 24, lineHeightPercent: 130, letterSpacingPercent: -0.3) }
    var pointText2Style: some View { applyAppStyle(.custom("RIDIBatang", size: 22), size: 22, lineHeightPercent: 130, letterSpacingPercent: -0.3) }
    var pointText3Style: some View { applyAppStyle(.custom("RIDIBatang", size: 20), size: 20, lineHeightPercent: 130, letterSpacingPercent: -0.3) }
    var pointText4Style: some View { applyAppStyle(.custom("RIDIBatang", size: 18), size: 18, lineHeightPercent: 130, letterSpacingPercent: -0.3) }
    var pointText5Style: some View { applyAppStyle(.custom("RIDIBatang", size: 16), size: 16, lineHeightPercent: 130, letterSpacingPercent: -0.2) }
}

/* 사용 예시
 
 VStack(alignment: .leading, spacing: 4) {
    Text("계정 설정")
        .head1Style
        .foregroundStyle(.blue100)

    Text("나중에 수정할 수 있어요")
        .body2RegularStyle
        .foregroundColor(.gray200)

    Text("리비바탕")
        .pointText1Style
        .foregroundColor(.gray200)
 }
 
 */
