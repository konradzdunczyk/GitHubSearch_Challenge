//
//  DefaultRepoSerachViewModelTests.swift
//  GitHubSearch_ChallengeTests
//
//  Created by Zduńczyk Konrad on 20/10/2021.
//

import Foundation
import Nimble
import Quick


@testable import GitHubSearch_Challenge
import XCTest

class DefaultRepoSerachViewModelTests: QuickSpec {
    override func spec() {
        var sut: DefaultRepoSerachViewModel!
        var useCaseMock: SearchRepoUseCaseMock!
        var cancellableMock: CancellableMock!

        let testPage1 = RepoSearchPage(query: "Test query", page: 1,
                                       allPages: 2, totalCount: 1000,
                                       repos: [.init(id: 1, name: "Repo 1",
                                                     ownerName: "Owner 1",
                                                     htmlURL: "www.google.pl",
                                                     licenseName: nil)])
        let testPage2 = RepoSearchPage(query: "Test query", page: 2,
                                       allPages: 2, totalCount: 1000,
                                       repos: [.init(id: 2, name: "Repo 2",
                                                     ownerName: "Owner 2",
                                                     htmlURL: "www.google.pl",
                                                     licenseName: nil)])
        var testRepo: Repo {
            testPage1.repos.first!
        }

        beforeEach {
            useCaseMock = .init()
            cancellableMock = .init()
            sut = DefaultRepoSerachViewModel(useCase: useCaseMock)
        }

        afterEach {
            useCaseMock = nil
            sut = nil
        }

        describe("search") {
            beforeEach {
                useCaseMock.given(.execute(requestValue: .any, completion: .any, willReturn: cancellableMock))
                useCaseMock.perform(.execute(requestValue: .any, completion: .any, perform: { reqValue, completion in
                    completion(.success(testPage1))
                }))

                sut.search(query: "xx", completionHandler: { _ in })

                useCaseMock.resetMock(.invocation)
            }

            context("with only whitespaces query") {
                let query = "    "

                it("useCaseMock.execute is not call") {
                    useCaseMock.verify(.execute(requestValue: .any, completion: .any), count: 0)
                    sut.search(query: query) { _ in }
                    useCaseMock.verify(.execute(requestValue: .any, completion: .any), count: 0)
                }

                it("isFetching remain false") {
                    useCaseMock.perform(.execute(requestValue: .any, completion: .any, perform: { _, _ in }))
                    expect(sut.isFetching).to(beFalse())
                    sut.search(query: query) { _ in }
                    expect(sut.isFetching).to(beFalse())
                }

                it("latest task is cancelled") {
                    cancellableMock.verify(.cancel(), count: 0)
                    sut.search(query: query) { _ in }
                    cancellableMock.verify(.cancel(), count: 1)
                }

                it("isNextPageAvailable is false") {
                    sut.search(query: query) { _ in }
                    expect(sut.isNextPageAvailable).to(beFalse())
                }

                it("complete with success with empty array and no next page available") {
                    var resultItems: [Item]?
                    var resultIsNextPageAvailable: Bool?

                    sut.search(query: query) { result in
                        switch result {
                        case .success((let items, let isNextPageAvailable)):
                            resultItems = items
                            resultIsNextPageAvailable = isNextPageAvailable
                        case .failure:
                            break
                        }
                    }

                    expect(resultItems).toEventually(beEmpty())
                    expect(resultIsNextPageAvailable).toEventually(beFalse())
                }
            }

            context("with correct query") {
                let query = "Alamofire  "

                it("isFetching change to true and back to false after task complete with success") {
                    var called = false

                    useCaseMock.perform(.execute(requestValue: .any, completion: .any, perform: { reqValue, completion in
                        expect(sut.isFetching).to(beTrue())
                        completion(.success(testPage1))
                        expect(sut.isFetching).to(beFalse())

                        called = true
                    }))

                    expect(sut.isFetching).to(beFalse())
                    sut.search(query: query) { _ in }

                    expect(called).toEventually(beTrue())
                }

                it("isFetching change to true and back to false after task complete with failure") {
                    var called = false

                    useCaseMock.perform(.execute(requestValue: .any, completion: .any, perform: { reqValue, completion in
                        expect(sut.isFetching).to(beTrue())
                        completion(.failure(.wrongUrl))
                        expect(sut.isFetching).to(beFalse())

                        called = true
                    }))

                    expect(sut.isFetching).to(beFalse())
                    sut.search(query: query) { _ in }

                    expect(called).toEventually(beTrue())
                }

                it("latest task is cancelled") {
                    cancellableMock.verify(.cancel(), count: 0)
                    sut.search(query: query) { _ in }
                    cancellableMock.verify(.cancel(), count: 1)
                }

                context("useCaseMock.execute complete with success") {
                    context("with last page") {
                        beforeEach {
                            useCaseMock.perform(.execute(requestValue: .any, completion: .any, perform: { _, completion in
                                completion(.success(testPage2))
                            }))
                        }

                        it("isNextPageAvailable is false") {
                            sut.search(query: query) { _ in }
                            expect(sut.isNextPageAvailable).to(beFalse())
                        }

                        it("complete with items from page and isNextPageAvailable false") {
                            var resultItems: [Item]?
                            var resultIsNextPageAvailable: Bool?

                            sut.search(query: query) { result in
                                switch result {
                                case .success((let items, let isNextPageAvailable)):
                                    resultItems = items
                                    resultIsNextPageAvailable = isNextPageAvailable
                                case .failure:
                                    break
                                }
                            }

                            let expectedItems = testPage2.repos.map({ Item.repo($0) })

                            expect(resultItems).toEventually(equal(expectedItems))
                            expect(resultIsNextPageAvailable).toEventually(beFalse())
                        }
                    }

                    context("with not last page") {
                        beforeEach {
                            useCaseMock.perform(.execute(requestValue: .any, completion: .any, perform: { _, completion in
                                completion(.success(testPage1))
                            }))
                        }

                        it("isNextPageAvailable is true") {
                            sut.search(query: query) { _ in }
                            expect(sut.isNextPageAvailable).to(beTrue())
                        }

                        it("complete with items from page and isNextPageAvailable true") {
                            var resultItems: [Item]?
                            var resultIsNextPageAvailable: Bool?

                            sut.search(query: query) { result in
                                switch result {
                                case .success((let items, let isNextPageAvailable)):
                                    resultItems = items
                                    resultIsNextPageAvailable = isNextPageAvailable
                                case .failure:
                                    break
                                }
                            }

                            let expectedItems = testPage1.repos.map({ Item.repo($0) })

                            expect(resultItems).toEventually(equal(expectedItems))
                            expect(resultIsNextPageAvailable).toEventually(beTrue())
                        }
                    }
                }

                context("useCaseMock.execute complete with error") {
                    beforeEach {
                        useCaseMock.perform(.execute(requestValue: .any, completion: .any, perform: { _, completion in
                            completion(.failure(.wrongUrl))
                        }))
                    }

                    it("completion handler is called with repoError") {
                        var resultValue: RepoSerachViewModelError?

                        sut.search(query: query, completionHandler: { result in
                            switch result {
                            case .success:
                                break
                            case .failure(let error):
                                resultValue = error
                            }
                        })

                        expect(resultValue).toEventually(equal(.repoError(.wrongUrl)))
                    }
                }
            }
        }

        describe("nextPage") {
            context("called without search") {
                it("useCaseMock.execute is not call") {
                    useCaseMock.verify(.execute(requestValue: .any, completion: .any), count: 0)
                    sut.nextPage { _ in }
                    useCaseMock.verify(.execute(requestValue: .any, completion: .any), count: 0)
                }

                it("complete with nextPageUnavailable error") {
                    var resultValue: RepoSerachViewModelError?

                    sut.nextPage(completionHandler: { result in
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            resultValue = error
                        }
                    })

                    expect(resultValue).toEventually(equal(.nextPageUnavailable))
                }
            }

            context("called with search previusly") {
                context("fetched page is last and not fetching") {
                    beforeEach {
                        useCaseMock.perform(.execute(requestValue: .any, completion: .any, perform: { reqValue, completion in
                            completion(.success(testPage2))
                        }))

                        sut.search(query: "xx", completionHandler: { _ in })

                        useCaseMock.resetMock(.invocation)
                    }

                    it("useCaseMock.execute is not call") {
                        useCaseMock.verify(.execute(requestValue: .any, completion: .any), count: 0)
                        sut.nextPage { _ in }
                        useCaseMock.verify(.execute(requestValue: .any, completion: .any), count: 0)
                    }

                    it("complete with nextPageUnavailable error") {
                        var resultValue: RepoSerachViewModelError?

                        sut.nextPage(completionHandler: { result in
                            switch result {
                            case .success:
                                break
                            case .failure(let error):
                                resultValue = error
                            }
                        })

                        expect(resultValue).toEventually(equal(.nextPageUnavailable))
                    }
                }

                context("latest page is not last and fetching") {
                    beforeEach {
                        useCaseMock.perform(.execute(requestValue: .any, completion: .any, perform: { _, completion in
                            completion(.success(testPage1))
                        }))

                        sut.search(query: "xx", completionHandler: { _ in })

                        useCaseMock.perform(.execute(requestValue: .any, completion: .any, perform: { _, completion in

                        }))

                        sut.nextPage(completionHandler: { _ in })

                        useCaseMock.resetMock(.invocation)
                    }

                    it("useCaseMock.execute is not call") {
                        useCaseMock.verify(.execute(requestValue: .any, completion: .any), count: 0)
                        sut.nextPage { _ in }
                        useCaseMock.verify(.execute(requestValue: .any, completion: .any), count: 0)
                    }

                    it("complete with fetchingInProgress error") {
                        var resultValue: RepoSerachViewModelError?

                        sut.nextPage(completionHandler: { result in
                            switch result {
                            case .success:
                                break
                            case .failure(let error):
                                resultValue = error
                            }
                        })

                        expect(resultValue).toEventually(equal(.fetchingInProgress))
                    }
                }

                context("latest page is not last and not fetching") {
                    beforeEach {
                        useCaseMock.perform(.execute(requestValue: .any, completion: .any, perform: { reqValue, completion in
                            completion(.success(testPage1))
                        }))

                        sut.search(query: "xx", completionHandler: { _ in })

                        useCaseMock.perform(.execute(requestValue: .any, completion: .any, perform: { _, completion in
                            completion(.success(testPage2))
                        }))

                        useCaseMock.resetMock(.invocation)
                    }

                    it("useCaseMock.execute is call with query from latest page and page increased by 1") {
                        useCaseMock.verify(.execute(requestValue: .any, completion: .any), count: 0)
                        sut.nextPage { _ in }
                        useCaseMock.verify(.execute(requestValue: .value(.init(query: testPage1.query, page: testPage1.page + 1)), completion: .any), count: 1)
                    }

                    it("complet with items from testPage1 and pageTest2") {
                        var resultItems: [Item]?
                        var resultIsNextPageAvailable: Bool?

                        sut.nextPage { result in
                            switch result {
                            case .success((let items, let isNextPageAvailable)):
                                resultItems = items
                                resultIsNextPageAvailable = isNextPageAvailable
                            case .failure:
                                break
                            }
                        }

                        let expectedItems = testPage1.repos.map({ Item.repo($0) }) + testPage2.repos.map({ Item.repo($0) })

                        expect(resultItems).toEventually(equal(expectedItems))
                        expect(resultIsNextPageAvailable).toEventually(beFalse())
                    }
                }
            }
        }

        describe("repoSelected") {
            context("passed repo has correct url") {
                it("handleUrlOpen is call with url") {
                    var resultUrl: URL?

                    sut.handleUrlOpen = { url in
                        resultUrl = url
                    }

                    sut.repoSelected(testRepo)

                    expect(resultUrl?.absoluteString).toEventually(equal(testRepo.htmlURL))
                }
            }
        }
    }
}
