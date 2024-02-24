//
//  MainButton.swift
//  Fablescope
//
//  Created by Timur Guliamov on 24.02.2024.
//

import SwiftUI

struct MainButton: View {
  let text: LocalizedStringKey
  let onTap: () -> Void

  @Environment(\.theme)
  private var theme: Theme

  init(_ text: LocalizedStringKey, onTap: @escaping () -> Void) {
    self.text = text
    self.onTap = onTap
  }

  var body: some View {
    Button {
      self.onTap()
    } label: {
      ZStack {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
          .foregroundStyle(self.theme.colors.background.accent)

        Text(self.text)
          .font(.title3)
          .bold()
          .fontDesign(.rounded)
          .foregroundStyle(self.theme.colors.text.lightSecondary)
      }
      .frame(height: 64)
    }
  }
}

#Preview {
  VStack {
    MainButton("Hello") {}
    MainButton("World") {}
  }
  .padding()
}
