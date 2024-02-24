//
//  ScaledButtonStyle.swift
//  Fablescope
//
//  Created by Timur Guliamov on 24.02.2024.
//

import SwiftUI

struct ScaledButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaleEffect(configuration.isPressed ? 0.9 : 1)
      .animation(
        .easeOut(duration: 0.2),
        value: configuration.isPressed
      )
  }
}
