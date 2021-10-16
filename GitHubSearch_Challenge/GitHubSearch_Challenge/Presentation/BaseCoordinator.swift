//
//  BaseCoordinator.swift
//  GitHubSearch_Challenge
//
//  Created by Zduńczyk Konrad on 16/10/2021.
//

import UIKit

class BaseCoordinator: NSObject {
    typealias RootViewController = UIViewController

    private(set) weak var rootViewController: RootViewController?
    private var isStarted: Bool = false

    final func startCoordinator(_ rootViewController: RootViewController?) {
        guard !isStarted else {
            assertionFailure("\(String(describing: type(of: self))) is alredy started")
            return
        }

        if let viewController = rootViewController {
            updateRootViewController(viewController)
        }

        isStarted = true
    }

    final func finishCoordinator() {
        guard isStarted else {
            assertionFailure("\(String(describing: type(of: self))) is not started")
            return
        }

        isStarted = false
    }

    final func setRootViewController(_ rootViewController: RootViewController) {
        updateRootViewController(rootViewController)
    }

    private func updateRootViewController(_ rootViewController: RootViewController) {
        self.rootViewController = rootViewController
    }
}
