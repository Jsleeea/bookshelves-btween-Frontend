//
//  NotificationInboxViewModel.swift
//  BookBetween
//

import Foundation
import Observation

@Observable
@MainActor
final class NotificationInboxViewModel {
    private(set) var notifications: [NotificationItem] = []
    private(set) var isLoading = false
    private(set) var isLoadingNextPage = false
    var errorMessage: String?

    private let service: any NotificationServiceProtocol
    private let pageSize: Int
    private let automaticallyLoads: Bool
    private let pollingInterval: Duration
    private var currentPage = 0
    private var hasNext = false
    private var hasLoaded = false
    private var newestNotificationId = 0
    private var isCheckingForNewNotifications = false
    private var readingNotificationIds: Set<Int> = []

    var isEmpty: Bool {
        notifications.isEmpty
    }

    init(
        service: any NotificationServiceProtocol,
        pageSize: Int = 20,
        pollingInterval: Duration = .seconds(30)
    ) {
        self.service = service
        self.pageSize = pageSize
        self.pollingInterval = pollingInterval
        self.automaticallyLoads = true
    }

    init(notifications: [NotificationItem]) {
        self.notifications = notifications
        self.service = NotificationService.stubbed()
        self.pageSize = 20
        self.pollingInterval = .seconds(30)
        self.automaticallyLoads = false
    }

    func start() async {
        guard automaticallyLoads else { return }

        await loadNotifications()

        while !Task.isCancelled {
            do {
                try await Task.sleep(for: pollingInterval)
            } catch {
                return
            }

            await loadNewNotifications()
        }
    }

    func loadNotifications() async {
        guard !hasLoaded, !isLoading else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let result = try await service.fetchNotifications(
                page: 1,
                size: pageSize
            )
            notifications = result.notifications
            currentPage = result.page
            hasNext = result.hasNext
            newestNotificationId = result.notifications.map(\.id).max() ?? 0
            hasLoaded = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refreshNotifications() async {
        guard automaticallyLoads, !isLoading else { return }

        hasLoaded = false
        currentPage = 0
        hasNext = false
        await loadNotifications()
    }

    func loadNextPageIfNeeded(currentItem: NotificationItem) async {
        guard
            currentItem.id == notifications.last?.id,
            hasNext,
            !isLoading,
            !isLoadingNextPage
        else { return }

        isLoadingNextPage = true
        errorMessage = nil
        defer { isLoadingNextPage = false }

        do {
            let result = try await service.fetchNotifications(
                page: currentPage + 1,
                size: pageSize
            )
            appendUnique(result.notifications)
            currentPage = result.page
            hasNext = result.hasNext
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func markAsRead(_ notification: NotificationItem) async {
        guard
            !notification.isRead,
            !readingNotificationIds.contains(notification.id)
        else { return }

        readingNotificationIds.insert(notification.id)
        defer { readingNotificationIds.remove(notification.id) }

        do {
            let notificationId = try await service.markAsRead(
                notificationId: notification.id
            )

            guard let index = notifications.firstIndex(
                where: { $0.id == notificationId }
            ) else { return }

            notifications[index] = notifications[index].markingAsRead()
        } catch {
            // 읽음 처리는 화면 진입에 곁들여지는 부수 효과입니다.
            // 실패해도 사용자가 하려던 동작을 막지 않도록 알리지 않습니다.
            #if DEBUG
            print("[Notification] 읽음 처리 실패: \(error)")
            #endif
        }
    }

    private func loadNewNotifications() async {
        guard
            hasLoaded,
            !isLoading,
            !isLoadingNextPage,
            !isCheckingForNewNotifications
        else { return }

        isCheckingForNewNotifications = true
        defer { isCheckingForNewNotifications = false }

        do {
            var cursor = newestNotificationId
            var newNotifications: [NotificationItem] = []

            while !Task.isCancelled {
                let batch = try await service.fetchNewNotifications(
                    afterId: cursor,
                    size: pageSize
                )
                newNotifications.append(contentsOf: batch.notifications)

                guard batch.hasNext, batch.nextCursor > cursor else {
                    cursor = max(cursor, batch.nextCursor)
                    break
                }

                cursor = batch.nextCursor
            }

            newestNotificationId = cursor
            prependUnique(newNotifications)
        } catch {
            #if DEBUG
            print("[Notification] 새 알림 조회 실패: \(error)")
            #endif
        }
    }

    private func appendUnique(_ newNotifications: [NotificationItem]) {
        let existingIds = Set(notifications.map(\.id))
        notifications.append(
            contentsOf: newNotifications.filter {
                !existingIds.contains($0.id)
            }
        )
    }

    private func prependUnique(_ newNotifications: [NotificationItem]) {
        let existingIds = Set(notifications.map(\.id))
        let uniqueNotifications = newNotifications
            .filter { !existingIds.contains($0.id) }
            .sorted { $0.id > $1.id }

        notifications.insert(contentsOf: uniqueNotifications, at: 0)
    }

}
