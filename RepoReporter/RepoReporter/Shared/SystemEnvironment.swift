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

@dynamicMemberLookup
struct SystemEnvironment<Environment> {
  // repositoryReducer는 RepositoryEnvironment의 DispatchQueue와 JSONDecoder를 사용한다.
  // userReducer 또한 DispatchQueue와 JSONDecoder를 사용한다.
  // 이런 dependencies를 매번 복사하여 관리하는 것보다 공유하도록 SystemEnvironment를 사용할 수 있다.
  // SystemEnvironment를 사용하여, RepositoryEnvironment와 같은 하위 dependencies를 래핑할 수도 있다.
  
  var environment: Environment

  subscript<Dependency>(
    dynamicMember keyPath: WritableKeyPath<Environment, Dependency>
  ) -> Dependency {
    get { self.environment[keyPath: keyPath] }
    set { self.environment[keyPath: keyPath] = newValue }
  }

  var mainQueue: () -> AnySchedulerOf<DispatchQueue>
  // 메인 쓰레드
  var decoder: () -> JSONDecoder
  // 디코더

  private static func decoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
  }

  static func live(environment: Environment) -> Self {
    // 실제 앱 환경에서 사용할 SystemEnvironment 인스턴스
    Self(environment: environment, mainQueue: { .main }, decoder: decoder)
  }

  static func dev(environment: Environment) -> Self {
    // 다양한 environment를 생성할 수 있다. SwiftUI preview를 위한 더미 환경을 생성한다.
    // 개발 더미 환경에서 사용할 SystemEnvironment 인스턴스
    Self(environment: environment, mainQueue: { .main }, decoder: decoder)
  }
}


