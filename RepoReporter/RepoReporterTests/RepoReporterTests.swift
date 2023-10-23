/// Copyright (c) 2021 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import ComposableArchitecture
import XCTest

@testable import RepoReporter

class RepoReporterTests: XCTestCase {
  let testScheduler = DispatchQueue.test
  var testRepositories: [RepositoryModel] {
    [
      RepositoryModel(
        name: "Repo 1",
        description: "This is the first repo.",
        stars: 5,
        forks: 5,
        language: "Swift")
    ]
  }

  func testRepositoryEffect(decoder: JSONDecoder) -> Effect<[RepositoryModel], APIError> {
    return Effect(value: testRepositories)
  }

  func testFavoriteButtonTapped() {
    // 새로운 Effect를 생성하지 않는 Action 테스트
    let store = TestStore(
      initialState: RepositoryState(),
      // 테스트할 State를 Reducer에 전달한다.
      reducer: repositoryReducer,
      environment: SystemEnvironment(
        environment: RepositoryEnvironment(repositoryRequest: testRepositoryEffect),
        mainQueue: { self.testScheduler.eraseToAnyScheduler() },
        decoder: { JSONDecoder() }
        // 테스트할 Effect와 scheduler를 가진 새로운 Environment를 생성한다.
      )
    )
    
    guard let testRepo = testRepositories.first else {
      fatalError("Error in test setup")
    }
    
    store.send(.favoriteButtonTapped(testRepo)) { state in
      // 테스트 store에 favoriteButtonTapped을 트리거한다.
      state.favoriteRepositories.append(testRepo)
      // store가 Reducer를 실행한 후의 State와 일치해야 하는 새 State를 정의한다.
      // 만약 테스트가 실패하게 된다면, TCA의 로그를 콘솔에서 확인해 볼 수 있다.
    }
  }

  func testOnAppear() {
    // 새로운 Effect를 생성하는 Action 테스트
    let store = TestStore(
      initialState: RepositoryState(),
      reducer: repositoryReducer,
      environment: SystemEnvironment(
        environment: RepositoryEnvironment(repositoryRequest: testRepositoryEffect),
        mainQueue: { self.testScheduler.eraseToAnyScheduler() },
        decoder: { JSONDecoder() }
      )
    )
    
    store.send(.onAppear) // 테스트 store에 onAppear을 트리거한다.
    testScheduler.advance() // 새로운 Effect가 생성되고, testScheduler가 이를 처리한다. scheduler에서 advance를 호출하여 Effect를 실행할 수 있도록 한다.
    store.receive(.dataLoaded(.success(testRepositories))) { state in
      state.repositories = self.testRepositories
      // store로 전송되는 다음 Action을 확인한다.
    }
  }
}

// 테스트해야 할 주요 구성 요소는 Reducer이다. Action이 주어질 때, 현재 State를 새로운 State로 변환하는 테스트를 작성한다.
