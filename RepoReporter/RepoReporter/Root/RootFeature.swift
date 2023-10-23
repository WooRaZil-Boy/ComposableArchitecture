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

struct RootState {
  // RootState는 각 state로 전체 앱의 상태를 나타낸다.
  var userState = UserState()
  var repositoryState = RepositoryState()
}

enum RootAction {
  case userAction(UserAction)
  case repositoryAction(RepositoryAction)
}

struct RootEnvironment { }

// swiftlint:disable trailing_closure
let rootReducer = Reducer<
  RootState,
  RootAction,
  SystemEnvironment<RootEnvironment>
>.combine(
  userReducer.pullback(
    state: \.userState,
    action: /RootAction.userAction,
    environment: { _ in .live(environment: UserEnvironment(userRequest: userEffect)) }
  ),
  repositoryReducer.pullback(
    // pullback이 RootState, RootAction, RootEnvironment에서 작동하도록 변환한다.
    state: \.repositoryState,
    // repositoryReducer는 local RepositoryState에서 작동한다. key path를 사용하여 global RootState에서 local state를 연결한다.
    action: /RootAction.repositoryAction,
    // case path를 사용한다. key path와 비슷하지만, enum의 case에서 동작한다.
    environment: { _ in .live(environment: RepositoryEnvironment(repositoryRequest: repositoryEffect)) }
    // Reducer가 사용할 environment repository를 생성한다.
  )
)
// swiftlint:enable trailing_closure

// RepositoryFeature와 비슷하지만, 전체 앱에 대한 Feature를 정의한다.
// RootView가 탭 바이기 때문에, 각 탭바에 대한 Feature를 정의한다.

// local의 State, Action, Environment를 global State, Action, Environment에서 작동하기 위한 TCA 방법은 두 가지가 있다.
// 1. combine : 여러 reducer를 결합하여 새로운 reducer를 생성한다. 주어진 각 reducer를 순서대로 실행한다.
// 2. pullback : reducer가 global의 State, Action, Environment에서 작동할 수 있도록 Transform 한다.
//  세 개의 methods를 사용해 pullback에 전달한다.
