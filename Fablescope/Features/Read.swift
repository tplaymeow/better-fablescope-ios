//
//  Read.swift
//  Fablescope
//
//  Created by Timur Guliamov on 23.02.2024.
//

import Foundation
import OSLog
import Observation
import SwiftUI
import SwiftUINavigation

@MainActor
@Observable
final class ReadModel: HashableObject {
  enum State {
    case loading
    case error
    case loaded(StoryResponse)
  }

  var state: State = .loading

  private let apiClient: APIClient
  private let tagIDs: TagIDs
  @ObservationIgnored
  private var loadContentTask: Task<Void, Never>?
  private var appearedOnce: Bool = false

  init(tagIDs: TagIDs, apiClient: APIClient) {
    self.tagIDs = tagIDs
    self.apiClient = apiClient
  }

  func onAppear() {
    guard !self.appearedOnce else { return }
    self.appearedOnce = false
    self.loadContent()
  }

  func retry() {
    self.loadContent()
  }

  private func loadContent() {
    self.state = .loading
    self.loadContentTask?.cancel()
    self.loadContentTask = Task {
      do {
        self.state = .loaded(
          try await self.apiClient.getStory(with: self.tagIDs)
        )
      } catch {
        self.state = .error
      }
    }
  }
}

struct ReadScreen: View {
  @State
  var model: ReadModel

  @Environment(\.theme)
  private var theme: Theme

  var body: some View {
    ZStack {
      self.theme.colors.background.secondary
        .ignoresSafeArea()

      switch self.model.state {
      case .loading:
        ProgressView()

      case .error:
        ErrorView {
          self.model.retry()
        }

      case let .loaded(story):
        ScrollView {
          VStack {
            Image(.formBackground1)
              .resizable()
              .scaledToFit()
              .offset(y: -100)

            Spacer()
          }

          Text(story.text)
            .font(.title3)
            .fontDesign(.rounded)
            .foregroundStyle(self.theme.colors.text.primary)
            .padding()
        }
      }
    }
    .onAppear {
      self.model.onAppear()
    }
  }
}

#Preview {
  ReadScreen(
    model: {
      let res = ReadModel(
        tagIDs: .init(tags: [.init(id: 1), .init(id: 2)]),
        apiClient: .shared
      )
      res.state = .loaded(.init(text: "Fefefe fefe fe fe fefe"))
      return res
    }()
  )
}
