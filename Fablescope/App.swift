//
//  FablescopeApp.swift
//  Fablescope
//
//  Created by Timur Guliamov on 23.02.2024.
//

import SwiftUI

@main
struct FablescopeApp: App {
  var body: some Scene {
    WindowGroup {
      NavigationStack {
        StartScreen(model: StartModel())
      }
    }
  }
}
