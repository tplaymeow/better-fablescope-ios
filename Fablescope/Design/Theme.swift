//
//  Theme.swift
//  Fablescope
//
//  Created by Timur Guliamov on 24.02.2024.
//

import SwiftUI

struct Theme {
  struct Colors {
    struct Text {
      let primary: Color
      let secondary: Color
      let lightPrimary: Color
      let lightSecondary: Color
      let accent: Color
    }

    struct Background {
      let primary: Color
      let secondary: Color
      let accent: Color
    }

    let text: Text
    let background: Background
  }

  let colors: Colors
}

extension Theme {
  static let `default` = Self(
    colors: .init(
      text: .init(
        primary: .init(hex: 0x000000),
        secondary: .init(hex: 0x063446),
        lightPrimary: .init(hex: 0xffffff),
        lightSecondary: .init(hex: 0xd4ebf4),
        accent: .init(hex: 0x108FC0)
      ),
      background: .init(
        primary: .init(hex: 0xffffff),
        secondary: .init(hex: 0xe9f5f9),
        accent: .init(hex: 0x108FC0)
      )
    )
  )
}

extension Theme: EnvironmentKey {
  static var defaultValue = Theme.default
}

extension EnvironmentValues {
  var theme: Theme {
    get { self[Theme.self] }
    set { self[Theme.self] = newValue }
  }
}

extension Color {
  init(hex: UInt, alpha: Double = 1) {
    self.init(
      .sRGB,
      red: Double((hex >> 16) & 0xff) / 255,
      green: Double((hex >> 08) & 0xff) / 255,
      blue: Double((hex >> 00) & 0xff) / 255,
      opacity: alpha
    )
  }
}
