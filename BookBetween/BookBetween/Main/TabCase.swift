//
//  TabCase.swift
//  BookBetween
//
//  Created by 이준성 on 6/25/26.
//

import Foundation

enum TabCase: Int, CaseIterable {
    case home, search, bookClub, myLibrary, profile

    var title: String {
        switch self {
        case .home:    return "홈"
        case .search:  return "검색"
        case .bookClub:   return "모임"
        case .myLibrary: return "내 서재"
        case .profile:      return "마이"
        }
    }

    func iconName(isSelected: Bool) -> String {
        switch (self, isSelected) {
        case (.home, false):       return "icon_tab_home_empty"
        case (.home, true):        return "icon_tab_home_fill"
        case (.search, false):     return "icon_tab_search_empty"
        case (.search, true):      return "icon_tab_search_fill"
        case (.bookClub, false):   return "icon_tab_group_empty"
        case (.bookClub, true):    return "icon_tab_group_fill"
        case (.myLibrary, false):  return "icon_tab_group_book_empty"
        case (.myLibrary, true):   return "icon_tab_group_book_fill"
        case (.profile, false):    return "icon_tab_profile_empty"
        case (.profile, true):     return "icon_tab_profile_fill"
        }
    }
}
