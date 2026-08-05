//
//  View+SwipeBack.swift
//  BookBetween
//

import SwiftUI
import UIKit

extension View {
    func enableSwipeBack() -> some View {
        background(SwipeBackEnabler())
    }
}

private struct SwipeBackEnabler: UIViewControllerRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIViewController(context: Context) -> UIViewController {
        SwipeBackHostViewController(coordinator: context.coordinator)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        private weak var navigationController: UINavigationController?
        private weak var previousDelegate: (any UIGestureRecognizerDelegate)?

        func attach(to navigationController: UINavigationController?) {
            guard let navigationController,
                  let gesture = navigationController.interactivePopGestureRecognizer,
                  gesture.delegate !== self else {
                return
            }

            self.navigationController = navigationController
            previousDelegate = gesture.delegate
            gesture.delegate = self
            gesture.isEnabled = true
        }

        func detach() {
            guard let gesture = navigationController?.interactivePopGestureRecognizer,
                  gesture.delegate === self else {
                return
            }

            gesture.delegate = previousDelegate
        }

        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            // 루트 화면에서 스와이프하면 네비게이션 상태가 깨지므로 막는다.
            (navigationController?.viewControllers.count ?? 0) > 1
        }
    }
}

private final class SwipeBackHostViewController: UIViewController {
    private let coordinator: SwipeBackEnabler.Coordinator

    init(coordinator: SwipeBackEnabler.Coordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        coordinator.attach(to: navigationController)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        coordinator.detach()
    }
}
