//
//  TodosApp.swift
//  Todos
//
//  Created by admin on 2023/09/09.
//

import ComposableArchitecture
import SwiftUI

@main
struct TodosApp: App {
  var body: some Scene {
    WindowGroup {
      AppView(
        store: Store(initialState: Todos.State()) {
          Todos()._printChanges()
        }
      )
    }
  }
}
