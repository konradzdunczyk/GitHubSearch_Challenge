//
//  DefaultSearchRepoUseCaseTests.swift
//  GitHubSearch_ChallengeTests
//
//  Created by Zduńczyk Konrad on 20/10/2021.
//

import Foundation
import Nimble
import Quick


@testable import GitHubSearch_Challenge

class DefaultSearchRepoUseCaseTests: QuickSpec {
    override func spec() {
        var sut: DefaultSearchRepoUseCase!
        var repoMock: GitHubRepositoryMock!

        let testReqValue = SearchRepoUseCaseRequestValue(query: "Test query",
                                                         page: 42)
        let testPage = RepoSearchPage(query: "Test query", page: 42,
                                      allPages: 1, totalCount: 1000, repos: [])
        let testCancellable = CancellableMock()

        beforeEach {
            repoMock = .init()
            repoMock.given(.fetchRepositoriesList(query: .any, page: .any, completion: .any, willReturn: testCancellable))
            sut = DefaultSearchRepoUseCase(gitHubRepository: repoMock)
        }

        afterEach {
            repoMock = nil
            sut = nil
        }

        describe("execute") {
            context("run with test request value") {
                beforeEach {
                    repoMock.perform(.fetchRepositoriesList(query: .any, page: .any, completion: .any,
                                                            perform: { query, page, completionHandler in }))
                }

                it("params are pass to repoMock") {
                    repoMock.verify(.fetchRepositoriesList(query: .any, page: .any, completion: .any), count: 0)
                    _ = sut.execute(requestValue: testReqValue, completion: { _ in })
                    repoMock.verify(.fetchRepositoriesList(query: .value(testReqValue.query), page: .value(testReqValue.page), completion: .any), count: 1)
                }
            }

            context("repoMock complete with repo search page") {
                beforeEach {
                    repoMock.perform(.fetchRepositoriesList(query: .any, page: .any, completion: .any,
                                                            perform: { query, page, completionHandler in
                        completionHandler(.success(testPage))
                    }))
                }

                it("repo search page is pass to completion handler") {
                    var resultValue: RepoSearchPage?

                    _ = sut.execute(requestValue: testReqValue, completion: { result in
                        switch result {
                        case .success(let page):
                            resultValue = page
                        case .failure(_):
                            break
                        }
                    })

                    expect(resultValue).toEventually(equal(testPage))
                }
            }

            context("repoMock retrun cancellable") {
                it("cancellable is returned") {
                    let result = sut.execute(requestValue: testReqValue, completion: { _ in })
                    expect(result).to(be(testCancellable))
                }
            }
        }
    }
}
