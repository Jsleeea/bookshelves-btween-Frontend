//
//  OnboardingViewModel.swift
//  BookBetween
//
//  Created by Codex on 7/4/26.
//

import Combine
import Foundation

final class OnboardingViewModel: ObservableObject {
  @Published var currentPageIndex: Int = 0
}
