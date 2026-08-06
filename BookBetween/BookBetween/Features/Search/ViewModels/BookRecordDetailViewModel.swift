//
//  BookRecordDetailViewModel.swift
//  BookBetween
//
//  Created by 이준성 on 7/11/26.
//

import Foundation
import Observation

@Observable
@MainActor
final class BookRecordDetailViewModel {
    private(set) var record: UserBookRecord
    let isSaveable: Bool
    var isEditing: Bool = false
    var progress: Int
    var rating: Double
    var memo: String {
            didSet {
                if memo.count > Self.maxMemoLength {
                    memo = String(memo.prefix(Self.maxMemoLength))
                }
            }
        }
    private(set) var isLoading = false
    private(set) var isSaving = false
    var errorMessage: String?

    static let maxMemoLength = 200

    private let service: any BookServiceProtocol
    private let loadsRemoteDetail: Bool
    private var hasLoadedDetail = false

    init(
        record: UserBookRecord,
        isSaveable: Bool = true,
        service: any BookServiceProtocol,
        loadsRemoteDetail: Bool = false
    ) {
        self.record = record
        self.isSaveable = isSaveable
        self.service = service
        self.loadsRemoteDetail = loadsRemoteDetail
        self.progress = record.progress
        self.rating = record.rating ?? 0
        self.memo = record.memo ?? ""
        self.isLoading = loadsRemoteDetail
    }

    var book: Book {
        record.book
    }

    var hasReview: Bool {
        !memo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var reviewPlaceholderText: String {
        hasReview ? memo : "이 책에 대한 짧은 감상을 남겨주세요."
    }

    func startEditing() {
        guard isSaveable, !isLoading, !isSaving else { return }
        isEditing = true
    }

    func updateRating(_ value: Double) {
        guard isEditing else { return }
        rating = min(max(value, 0), 5)
    }

    func loadBookDetail() async {
        guard loadsRemoteDetail, !hasLoadedDetail else {
            isLoading = false
            return
        }

        guard let isbn = normalizedISBN else {
            isLoading = false
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let detail = try await service.fetchBookDetail(isbn: isbn)
            record = detail.record
            syncDraftWithRecord()
            hasLoadedDetail = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @discardableResult
    func saveRecord() async -> UserBookRecord? {
        guard
            isEditing,
            !isSaving,
            let isbn = normalizedISBN
        else { return nil }

        let trimmedMemo = memo.trimmingCharacters(in: .whitespacesAndNewlines)
        let savedRating = rating > 0 ? rating : nil
        let savedMemo = trimmedMemo.isEmpty ? nil : trimmedMemo

        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        do {
            try await service.upsertMemberBook(
                isbn: isbn,
                progress: progress,
                rating: savedRating,
                memo: savedMemo
            )

            record.progress = progress
            record.rating = savedRating
            record.memo = savedMemo
            memo = savedMemo ?? ""
            isEditing = false
            return record
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    private var normalizedISBN: String? {
        guard isSaveable else { return nil }

        let isbn = record.book.isbn?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let isbn, !isbn.isEmpty else {
            return nil
        }

        return isbn
    }

    private func syncDraftWithRecord() {
        progress = record.progress
        rating = record.rating ?? 0
        memo = record.memo ?? ""
    }
}
