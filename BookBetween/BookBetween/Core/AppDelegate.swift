//
//  AppDelegate.swift
//  BookBetween
//
//  Created by 이준성 on 8/8/26.
//

import UIKit
import UserNotifications
import FirebaseCore
import FirebaseMessaging

final class AppDelegate: NSObject, UIApplicationDelegate {

    var notificationService: NotificationServiceProtocol?

    private let fcmTokenStore: FCMTokenStoreProtocol = FCMTokenStore()
    private let authTokenStore: AuthTokenStoreProtocol = AuthTokenStore()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {

        FirebaseApp.configure()

        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self

        requestNotificationPermission()

        return true
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { granted, error in

            if let error {
                print("❌ 알림 권한 요청 실패:", error)
                return
            }

            print("🔔 알림 권한:", granted)

            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }


    // MARK: - APNs 등록 성공

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        print("✅ APNs 등록 성공")

        // Firebase Messaging에 APNs Token 전달
        Messaging.messaging().apnsToken = deviceToken
    }


    // MARK: - APNs 등록 실패

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("❌ APNs 등록 실패:", error)
    }
}


// MARK: - Foreground Notification

extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
            @escaping (UNNotificationPresentationOptions) -> Void
    ) {

        // 포그라운드 상태에서는 알림 배너를 표시하지 않는다.
        // (앱이 백그라운드일 때는 이 메서드가 호출되지 않고 시스템이 알림을 그대로 표시한다.)
        completionHandler([])
    }
}


// MARK: - Firebase Messaging

extension AppDelegate: MessagingDelegate {

    func messaging(
        _ messaging: Messaging,
        didReceiveRegistrationToken fcmToken: String?
    ) {

        guard let fcmToken else {
            return
        }

        #if DEBUG
        print("🔥 FCM 토큰 수신")
        #endif

        // 로그인 전에 토큰이 발급될 수 있어 항상 로컬에 먼저 저장한다.
        fcmTokenStore.save(fcmToken)

        // 이미 로그인된 상태(토큰 로테이션 등)라면 즉시 서버에 반영한다.
        // 로그인 전이라면 로그인 성공 시점(AppRootView)에서 전송한다.
        guard let accessToken = try? authTokenStore.accessToken(),
              !accessToken.isEmpty else {
            return
        }

        Task {
            do {
                try await notificationService?.registerFCMToken(fcmToken)
                print("✅ FCM 토큰 등록 성공")
            } catch {
                print("❌ FCM 토큰 등록 실패:", error)
            }
        }
    }
}
