//
//  CustomTabBar.swift
//  BookBetween
//
//  Created by 이준성 on 6/25/26.
//

import SwiftUI

struct HideTabBarPreferenceKey: PreferenceKey {
    static var defaultValue: Bool = false
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value || nextValue()
    }
}

extension View {
    func hideTabBar() -> some View {
        preference(key: HideTabBarPreferenceKey.self, value: true)
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: TabCase

    var body: some View {
        HStack(spacing: 0) {
            ForEach(TabCase.allCases, id: \.self) { tab in
                Spacer()

                Button {
                    selectedTab = tab
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: tab.iconName)
                            .font(.system(size: 19))
                            .foregroundStyle(selectedTab == tab ? .green800 : .gray400)

                        Text(tab.title)
                            .body2RegularStyle
                            .foregroundStyle(selectedTab == tab ? .green800 : .gray400)
                    }
                    .padding(.vertical, 10)
                }
                Spacer()
            }
        }
        .padding(.top, 5)
        .background {
            UnevenRoundedRectangle(topLeadingRadius: 12, topTrailingRadius: 12)
                .stroke(Color.gray200, lineWidth: 1)
                .fill(Color.white)
                .ignoresSafeArea(edges: .bottom)
        }
    }
}

#Preview {
    CustomTabBar(selectedTab: .constant(.home))
}
