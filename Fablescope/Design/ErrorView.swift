//
//  ErrorView.swift
//  Fablescope
//
//  Created by Timur Guliamov on 24.02.2024.
//

import SwiftUI

struct ErrorView: View {
  let onRetry: () -> Void

  @Environment(\.theme)
  private var theme: Theme

  var body: some View {
    ZStack {
      self.theme.colors.background.secondary
        .ignoresSafeArea()

      VStack {
        Spacer()

        Image(.errorBackground)
          .resizable()
          .scaledToFit()
      }
      .ignoresSafeArea()

      VStack {
        Spacer()

        Text("🛠️")
          .font(.largeTitle)

        Text("error_view.title")
          .multilineTextAlignment(.center)
          .font(.title)
          .bold()
          .fontDesign(.rounded)
          .foregroundStyle(self.theme.colors.text.primary)

        Text("error_view.subtitle")
          .multilineTextAlignment(.center)
          .fontDesign(.rounded)
          .foregroundStyle(self.theme.colors.text.secondary)

        Spacer()

        MainButton("error_view.button_title") {
          self.onRetry()
        }
      }
      .padding()
    }
  }
}

#Preview {
  ErrorView {}
}
