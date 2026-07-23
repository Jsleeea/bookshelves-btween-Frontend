//
//  HomeViewModel.swift
//  BookBetween
//
//  Created by 이준성 on 7/2/26.
//

import Foundation
import Observation

@Observable
@MainActor
final class HomeViewModel {
    private(set) var home: Home?
    private(set) var isLoading = false
    var errorMessage: String?

    private let service: any HomeServiceProtocol

    init(service: any HomeServiceProtocol) {
        self.service = service
    }

    func fetchHome() async {
        // 이미 통신 중이면 중복 요청하지 않습니다.
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            // 응답을 비동기로 기다린 뒤 성공 결과로 화면 상태를 갱신합니다.
            home = try await service.fetchHome()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
