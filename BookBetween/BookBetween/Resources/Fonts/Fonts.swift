//
//  Fonts.swift
//  BookBetween
//
//  Created by 이준성 on 6/25/26.
//

import Foundation
import SwiftUI

extension Font{
    enum Pretend{
        
        case regular
        case semiBold
        
        var value: String {
            switch self {
            case .semiBold:  return "Pretendard-SemiBold"
            case .regular:   return "Pretendard-Regular"
            }
        }
    }
    
    static func pretend(type: Pretend, size: CGFloat) -> Font {
        return .custom(type.value, size: size)
    }
    
    // Head 시리즈
    static let head1 = Font.pretend(type: .semiBold, size: 24)
    static let head2 = Font.pretend(type: .semiBold, size: 22)
    static let head3 = Font.pretend(type: .semiBold, size: 18)
    static let head4 = Font.pretend(type: .semiBold, size: 18)
        
    // Body 시리즈
    static let body1SemiBold = Font.pretend(type: .semiBold, size: 16)
    static let body1Regular = Font.pretend(type: .regular, size: 16)
    static let body2SemiBold = Font.pretend(type: .semiBold, size: 14)
    static let body2Regular = Font.pretend(type: .regular, size: 14)
    
    // Caption 시리즈
    static let caption1SemiBold = Font.pretend(type: .semiBold, size: 12)
    static let caption1Regular = Font.pretend(type: .regular, size: 12)
    static let caption2SemiBold = Font.pretend(type: .semiBold, size: 10)
    static let caption2Regular  = Font.pretend(type: .regular, size: 10)
}
