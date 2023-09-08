//
//  ContentView.swift
//  Counter
//
//  Created by admin on 2023/09/09.
//

import SwiftUI
import ComposableArchitecture

struct Feature: Reducer {
  struct State: Equatable {
    var count = 0
    var numberFactAlert: String?
  }
  
  enum Action: Equatable {
    case factAlertDismissed
    case decrementButtonTapped
    case incrementButtonTapped
    case numberFactButtonTapped
    case numberFactResponse(String)
  }
  
  func reduce(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
    case .factAlertDismissed:
      state.numberFactAlert = nil
      return .none
      
    case .decrementButtonTapped:
      state.count -= 1
      return .none
      
    case .incrementButtonTapped:
      state.count += 1
      return .none
      
    case .numberFactButtonTapped:
      return .run { [count = state.count] send in
        let (data, _) = try await URLSession.shared.data(
          from: URL(string: "http://numbersapi.com/\(count)/trivia")!
        )
        await send(
          .numberFactResponse(String(decoding: data, as: UTF8.self))
        )
      }
      
    case let .numberFactResponse(fact):
      state.numberFactAlert = fact
      return .none
    }
  }
}

struct ContentView: View {
  let store: StoreOf<Feature>
  
  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      VStack {
        HStack {
          Button("−") { viewStore.send(.decrementButtonTapped) }
          Text("\(viewStore.count)")
          Button("+") { viewStore.send(.incrementButtonTapped) }
        }
        
        Button("Number fact") { viewStore.send(.numberFactButtonTapped) }
      }
      .alert(
        item: viewStore.binding(
          get: { $0.numberFactAlert.map(FactAlert.init(title:)) },
          send: .factAlertDismissed
        ),
        content: { Alert(title: Text($0.title)) }
      )
    }
  }
}

struct FactAlert: Identifiable {
  var title: String
  var id: String { self.title }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(
      store: Store(initialState: Feature.State()) {
        Feature()
      }
    )
  }
}
