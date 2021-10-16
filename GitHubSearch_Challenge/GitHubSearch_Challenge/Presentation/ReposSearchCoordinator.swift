//
//  ReposSearchCoordinator.swift
//  GitHubSearch_Challenge
//
//  Created by Zduńczyk Konrad on 16/10/2021.
//

import UIKit
import SafariServices

class ReposSearchCoordinator: BaseCoordinator {
    private let _window: UIWindow
    private let _navigationController: UINavigationController = UINavigationController()

    init(window: UIWindow) {
        self._window = window

        super.init()
    }

    func start() {
        _window.rootViewController = _navigationController
        _window.makeKeyAndVisible()

        startCoordinator(nil)

        showRootView()
    }

    private func showRootView() {
        let useCase = DefaultSearchRepoUseCase(gitHubRepository: DefaultGitHubRepository(pageSize: 30))
        let vm = DefaultRepoSerachViewModel(useCase: useCase)
        vm.handleUrlOpen = { [weak self] url in
            let safariVC = SFSafariViewController(url: url)
            self?._navigationController.present(safariVC, animated: true, completion: nil)
        }

        let rootVc = RepoSerachViewController(viewModel: vm)
        _navigationController.pushViewController(rootVc, animated: false)

        setRootViewController(rootVc)
    }
}
