//
//  Todos.swift
//  Todos
//
//  Created by admin on 2023/09/09.
//

import ComposableArchitecture
@preconcurrency import SwiftUI

enum Filter: LocalizedStringKey, CaseIterable, Hashable {
  case all = "All"
  case active = "Active"
  case completed = "Completed"
}


struct Todos: Reducer {
  // State: 전체 할 일 목록과 관련된 상태를 나타내는 구조체
  struct State: Equatable {
    @BindingState var editMode: EditMode = .inactive // 편집 모드 상태
    @BindingState var filter: Filter = .all // 필터링 옵션
    var todos: IdentifiedArrayOf<Todo.State> = [] // 할 일 목록

    var filteredTodos: IdentifiedArrayOf<Todo.State> { // 필터링된 할 일 목록
      switch filter {
      case .active: return self.todos.filter { !$0.isComplete }
      case .all: return self.todos
      case .completed: return self.todos.filter(\.isComplete)
      }
    }
  }

  // Action: 구조체에서 발생할 수 있는 액션 유형
  enum Action: BindableAction, Equatable, Sendable {
    case addTodoButtonTapped
    case binding(BindingAction<State>)
    case clearCompletedButtonTapped
    case delete(IndexSet)
    case move(IndexSet, Int)
    case sortCompletedTodos
    case todo(id: Todo.State.ID, action: Todo.Action)
  }

  @Dependency(\.continuousClock) var clock
  @Dependency(\.uuid) var uuid
  private enum CancelID { case todoCompletion }

  // Reducer: 상태를 변경하는 로직. 각 액션에 따라 상태를 어떻게 변경할지를 정의
  var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .addTodoButtonTapped:
        state.todos.insert(Todo.State(id: self.uuid()), at: 0)
        return .none

      case .binding:
        return .none

      case .clearCompletedButtonTapped:
        state.todos.removeAll(where: \.isComplete)
        return .none

      case let .delete(indexSet):
        let filteredTodos = state.filteredTodos
        for index in indexSet {
          state.todos.remove(id: filteredTodos[index].id)
        }
        return .none

      case var .move(source, destination):
        if state.filter == .completed {
          source = IndexSet(
            source
              .map { state.filteredTodos[$0] }
              .compactMap { state.todos.index(id: $0.id) }
          )
          destination =
            (destination < state.filteredTodos.endIndex
              ? state.todos.index(id: state.filteredTodos[destination].id)
              : state.todos.endIndex)
            ?? destination
        }

        state.todos.move(fromOffsets: source, toOffset: destination)

        return .run { send in
          try await self.clock.sleep(for: .milliseconds(100))
          await send(.sortCompletedTodos)
        }

      case .sortCompletedTodos:
        state.todos.sort { $1.isComplete && !$0.isComplete }
        return .none

      case .todo(id: _, action: .binding(\.$isComplete)):
        return .run { send in
          try await self.clock.sleep(for: .seconds(1))
          await send(.sortCompletedTodos, animation: .default)
        }
        .cancellable(id: CancelID.todoCompletion, cancelInFlight: true)

      case .todo:
        return .none
      }
    }
    .forEach(\.todos, action: /Action.todo(id:action:)) {
      Todo()
    }
  }
}

struct AppView: View {
  let store: StoreOf<Todos>

  struct ViewState: Equatable {
    @BindingViewState var editMode: EditMode
    @BindingViewState var filter: Filter
    let isClearCompletedButtonDisabled: Bool

    init(store: BindingViewStore<Todos.State>) {
      self._editMode = store.$editMode
      self._filter = store.$filter
      self.isClearCompletedButtonDisabled = !store.todos.contains(where: \.isComplete)
    }
  }

  var body: some View {
    WithViewStore(self.store, observe: ViewState.init) { viewStore in
      NavigationStack {
        VStack(alignment: .leading) {
          Picker("Filter", selection: viewStore.$filter.animation()) {
            ForEach(Filter.allCases, id: \.self) { filter in
              Text(filter.rawValue).tag(filter)
            }
          }
          .pickerStyle(.segmented)
          .padding(.horizontal)

          List {
            ForEachStore(
              self.store.scope(state: \.filteredTodos, action: Todos.Action.todo(id:action:))
            ) {
              TodoView(store: $0)
            }
            .onDelete { viewStore.send(.delete($0)) }
            .onMove { viewStore.send(.move($0, $1)) }
          }
        }
        .navigationTitle("Todos")
        .navigationBarItems(
          trailing: HStack(spacing: 20) {
            EditButton()
            Button("Clear Completed") {
              viewStore.send(.clearCompletedButtonTapped, animation: .default)
            }
            .disabled(viewStore.isClearCompletedButtonDisabled)
            Button("Add Todo") { viewStore.send(.addTodoButtonTapped, animation: .default) }
          }
        )
        .environment(\.editMode, viewStore.$editMode)
      }
    }
  }
}

extension IdentifiedArray where ID == Todo.State.ID, Element == Todo.State {
  static let mock: Self = [
    Todo.State(
      description: "Check Mail",
      id: UUID(),
      isComplete: false
    ),
    Todo.State(
      description: "Buy Milk",
      id: UUID(),
      isComplete: false
    ),
    Todo.State(
      description: "Call Mom",
      id: UUID(),
      isComplete: true
    ),
  ]
}

struct AppView_Previews: PreviewProvider {
  static var previews: some View {
    AppView(
      store: Store(initialState: Todos.State(todos: .mock)) {
        Todos()
      }
    )
  }
}
