//
//  Todo.swift
//  Todos
//
//  Created by admin on 2023/09/09.
//

import ComposableArchitecture
import SwiftUI

struct Todo: Reducer {
  // State: 할 일 항목과 관련된 상태를 나타내는 구조체
  struct State: Equatable, Identifiable {
    @BindingState var description = "" // 설명
    let id: UUID // 고유 ID
    @BindingState var isComplete = false // 완료 상태
  }

  // Action: 구조체에서 발생할 수 있는 액션 유형
  enum Action: BindableAction, Equatable, Sendable {
    case binding(BindingAction<State>) // 할 일 항목의 상태를 변경
  }

  // Reducer: 상태를 변경하는 로직. 각 액션에 따라 상태를 어떻게 변경할지를 정의
  var body: some Reducer<State, Action> {
    // BindingReducer는 BindableAction을 활용하여 state의 변경을 바인딩하기 위한 특별한 reducer이다.]
    // BindingReducer()는 SwiftUI와 함께 사용될 때 상태의 바인딩된 부분을 자동으로 처리한다.
    // @Binding과 같은 SwiftUI의 바인딩 메커니즘을 사용하여 뷰와 상태를 연결할 때, 상태의 해당 부분이 변경될 때마다 자동으로 처리될 수 있도록 BindingReducer가 설계되었다.
    BindingReducer()
  }
}

// Reducer는 두 가지 방법의로 정의할 수 있다.

// 1. func reduce(into state: inout State, action: Action) -> Effect<Action> 메서드
//  reducer 로직을 정의하는 "기본적인" 방법으로 주어진 액션에 따라 상태를 변경하는 로직을 작성한다.
//  state는 inout 매개 변수이므로 함수 내에서 직접 수정할 수 있으며 side effect를 나타내는 Effect<Action>를 반환한다(side effect가 없다면 .none 을 반환).

// 2. var body: Body { get } 프로퍼티
//  여러 reducer들의 로직을 조합하여 하나로 합칠 때 사용한다.
//  해당 body 프로퍼티는 @ReducerBuilder로 구현되며 @ReducerBuilder는 SwiftUI의 @ViewBuilder와 비슷한 개념이다.

// reduce 메서드와 body 프로퍼티가 모두 구현되어 있다면, reduce가 우선적으로 호출되며 body는 무시된다.
// 따라서 두 가지를 동시에 사용하는 것은 권장되지 않는다.

struct TodoView: View {
  let store: StoreOf<Todo>

  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      HStack {
        Button {
          viewStore.$isComplete.wrappedValue.toggle()
        } label: {
          Image(systemName: viewStore.isComplete ? "checkmark.square" : "square")
        }
        .buttonStyle(.plain)

        TextField("Untitled Todo", text: viewStore.$description)
      }
      .foregroundColor(viewStore.isComplete ? .gray : nil)
    }
  }
}
