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

import Foundation
import ComposableArchitecture

func repositoryEffect(decoder: JSONDecoder) -> Effect<[RepositoryModel], APIError> {
  // Github API를 호출하여 데이터 및 오류를 매핑하고 eraseToEffect를 사용하여 Effect로 변환한다.
  guard let url = URL(string: "https://api.github.com/users/raywenderlich/repos?sort=updated&per_page=10") else {
    fatalError("Error on creating url")
  }
  return URLSession.shared.dataTaskPublisher(for: url)
    .mapError { _ in APIError.downloadError }
    .map { data, _ in data }
    .decode(type: [RepositoryModel].self, decoder: decoder)
    .mapError { _ in APIError.decodingError }
    .eraseToEffect()
}

func dummyRepositoryEffect(decoder: JSONDecoder) -> Effect<[RepositoryModel], APIError> {
  // 개발 중, SwiftUI preview에 사용할 수 있는 더미 데이터
  let dummyRepositories = [
    RepositoryModel(
      name: "Repo 1",
      description: "This is the first repo. It has a long descriptive text which spans many lines.",
      stars: 5,
      forks: 5,
      language: "Swift"),
    RepositoryModel(
      name: "Repo 2",
      description: "This is another repo.",
      stars: 0,
      forks: 5,
      language: "Python"),
    RepositoryModel(
      name: "Repo 3",
      description: "This is the last repo.",
      stars: 5,
      forks: 0,
      language: "Rust")
  ]
  return Effect(value: dummyRepositories)
}

// Reducer는 Action을 기반으로 현재 State를 변환한다. 주로 API 호출등을 수행한다.
// TCA가 비동기 호출에 사용하는 매커니즘이 Effect이다.
// Effect를 helper methods가 있는 Combine publisher 래퍼라 생각하면 된다.
