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

import Combine
import ComposableArchitecture

struct RepositoryState: Equatable {
  // 데이터
  var repositories: [RepositoryModel] = []
  var favoriteRepositories: [RepositoryModel] = []
}

enum RepositoryAction: Equatable {
  // 유저의 액션
  case onAppear // 탭 바 눌러 뷰가 나타났을 때
  case dataLoaded(Result<[RepositoryModel], APIError>) // API 호출 완료
  case favoriteButtonTapped(RepositoryModel) // 즐겨찾기 버튼 탭
}

struct RepositoryEnvironment {
  // Reducer는 State와 Action 외에도 environment에 접근할 수 있다.
  // environment에는 effects 형태의 모든 dependencies가 있다.
  var repositoryRequest: (JSONDecoder) -> Effect<[RepositoryModel], APIError>
  // GitHub API 호출
}

let repositoryReducer = Reducer<
  RepositoryState,
  RepositoryAction,
  SystemEnvironment<RepositoryEnvironment>
  // 단순히 RepositoryEnvironment를 사용하는 것이 아닌 SystemEnvironment의 shared dependencies를 사용할 수 있다.
> { state, action, environment in
  // Recuder는 state, action, environment를 받는다.
  switch action {
  // 주어진 action에 따라 반환하는 effect가 분기된다.
  case .onAppear:
    return environment.repositoryRequest(environment.decoder())
      .receive(on: environment.mainQueue())
      .catchToEffect()
      .map(RepositoryAction.dataLoaded)
    // Effect의 output을 필요한 Action에 매핑해야 한다.
  case .dataLoaded(let result):
    switch result {
    case .success(let repositories):
      state.repositories = repositories
      // API 호출이 성공하면, state를 업데이트 한다.
    case .failure(let error):
      break
    }
    return .none
    // 더 이상 Effect를 실행할 필요가 없는 경우, Effect.none을 반환한다.
  case .favoriteButtonTapped(let repository):
    // 즐겨찾기 버튼을 탭하면, 상태를 업데이트 한다.
    if state.favoriteRepositories.contains(repository) {
      state.favoriteRepositories.removeAll { $0 == repository }
    } else {
      state.favoriteRepositories.append(repository)
    }
    return .none
    // 더 이상 Effect를 실행할 필요가 없는 경우, Effect.none을 반환한다.
  }
}

// Reducer의 시그니처는 다음과 같다. (inout State, Action, Environment) -> Effect<Action, Never>
// State는 주어진 Action에 따라 Reducer가 수정하기 때문에 inout 매개변수이다.
// Reducer는 environment를 사용하여 포함된 dependencies에 접근한다.
// return type으로 Reducer가 다음에 처리되는 Effect를 생성한다.





// State: Often, a collection of properties represents the state of an app or a feature spread over many classes. TCA places all relevant properties together in a single type.
// Actions: An enumeration including cases for all events that can occur in your app, e.g., when a user taps a button, when a timer fires or an API request returns.
// Environment: A type wrapping all dependencies of your app or feature. For example, these can be API clients with asynchronous methods.
// Reducer: A function that uses a given action to transform the current state to the next state.
// Store: A place your UI observes for changes and where you send actions. Based on these actions, it runs reducers.

// (View) -> sends action -> (Store) -> runs -> (Reducer) -> transforms -> (State) -> triggers update -> (View)
// view는 reducer나 state와 직접 상호작용하지 않는다.
