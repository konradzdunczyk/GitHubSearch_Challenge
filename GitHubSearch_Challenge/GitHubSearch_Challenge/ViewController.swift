//
//  ViewController.swift
//  GitHubSearch_Challenge
//
//  Created by Zduńczyk Konrad on 13/10/2021.
//

import UIKit

class ViewController: UIViewController {
    let useCase = DefaultSearchRepoUseCase(gitHubRepository: DefaultGitHubRepository(pageSize: 30))

    override func viewDidLoad() {
        super.viewDidLoad()

        useCase.execute(requestValue: .init(query: "Alamofire", page: 1)) { result in
            switch result {
            case .success(let resp):
                print(resp)
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
}

