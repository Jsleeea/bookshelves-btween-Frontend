//
//  Color+Extensions.swift
//  BookBetween
//
//  Created by 이준성 on 7/2/26.
//

import Foundation
import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        
        Scanner(string: hex).scanHexInt64(&int)
        
        let r: UInt64
        let g: UInt64
        let b: UInt64
        let a: UInt64
        
        switch hex.count {
        case 3:
            // RGB, 12-bit
            r = ((int >> 8) & 0xF) * 17
            g = ((int >> 4) & 0xF) * 17
            b = (int & 0xF) * 17
            a = 255
            
        case 6:
            // RGB, 24-bit
            r = (int >> 16) & 0xFF
            g = (int >> 8) & 0xFF
            b = int & 0xFF
            a = 255
            
        case 8:
            // ARGB, 32-bit
            a = (int >> 24) & 0xFF
            r = (int >> 16) & 0xFF
            g = (int >> 8) & 0xFF
            b = int & 0xFF
            
        default:
            // 잘못된 값이 들어오면 기본 검정색
            r = 0
            g = 0
            b = 0
            a = 255
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
