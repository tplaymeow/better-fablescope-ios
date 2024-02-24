//
//  Start.swift
//  Fablescope
//
//  Created by Timur Guliamov on 23.02.2024.
//

import Foundation
import Observation
import SwiftUI
import SwiftUINavigation

@MainActor
@Observable
final class StartModel: HashableObject {
  @CasePathable
  enum Destination {
    case form(FormModel)
  }

  var destination: Destination?

  func start() {
    self.destination = .form(FormModel(apiClient: .shared))
  }
}

struct StartScreen: View {
  @State
  var model: StartModel

  @Environment(\.theme)
  private var theme: Theme

  var body: some View {
    ZStack {
      self.theme.colors.background.secondary
        .ignoresSafeArea()

      VStack {
        Spacer()

        Image(.startBackground)
          .resizable()
          .scaledToFit()
      }
      .ignoresSafeArea()

      VStack(alignment: .leading) {
        Spacer()
          .frame(height: 60)

        Text("start.title_first_part")
          .font(.title)
          .fontDesign(.rounded)
          .foregroundStyle(self.theme.colors.text.primary)

        Text("start.title_second_part")
          .font(.largeTitle)
          .bold()
          .fontDesign(.rounded)
          .foregroundStyle(self.theme.colors.text.accent)

        Spacer()

        MainButton("start.button_title") {
          self.model.start()
        }
      }
      .padding()
    }
    .navigationDestination(item: self.$model.destination.form) {
      FormScreen(model: $0)
    }
  }
}

#Preview {
  StartScreen(model: StartModel())
}
