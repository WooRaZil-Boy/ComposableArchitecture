//
//  CounterApp.swift
//  Counter
//
//  Created by admin on 2023/09/09.
//

import SwiftUI
import ComposableArchitecture

@main
struct MyApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView(
        store: Store(initialState: Feature.State()) {
          Feature()
        }
      )
    }
  }
}
