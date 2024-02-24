//
//  FormModel.swift
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
final class FormModel: HashableObject {
  enum State {
    struct Tag: Hashable, Identifiable {
      let id: Int
      let name: String
      let description: String
      let selected: Bool
    }

    struct Category: Hashable, Identifiable {
      let id: String
      let name: String
      let description: String
      let tags: [Tag]
    }

    struct Content {
      let categories: [Category]
    }

    case loading
    case error
    case loaded(Content)
  }

  @CasePathable
  enum Destination {
    case read(ReadModel)
  }

  var destination: Destination?
  var state: State = .loading

  @ObservationIgnored
  private var loadContentTask: Task<Void, Never>?
  private let apiClient: APIClient
  private var appearedOnce: Bool = false

  init(apiClient: APIClient) {
    self.apiClient = apiClient
  }

  func onAppear() {
    guard !self.appearedOnce else { return }
    self.appearedOnce = false
    self.loadContent()
  }

  func selectTag(with id: Int) {
    switch self.state {
    case let .loaded(content):
      self.state = .loaded(
        State.Content(
          categories: content.categories.map {
            State.Category(
              id: $0.id, name: $0.name, description: $0.description,
              tags: $0.tags.map {
                if $0.id == id {
                  State.Tag(
                    id: $0.id, name: $0.name,
                    description: $0.description, selected: !$0.selected
                  )
                } else {
                  $0
                }
              }
            )
          }
        )
      )
    case .loading, .error:
      break
    }
  }

  func done() {
    switch self.state {
    case let .loaded(content):
      self.destination = .read(
        ReadModel(
          tagIDs: TagIDs(
            tags: content.categories.flatMap {
              $0.tags.filter { $0.selected }.map { TagID(id: $0.id) }
            }
          ),
          apiClient: .shared
        )
      )
    case .loading, .error:
      break
    }
  }

  func retry() {
    self.loadContent()
  }

  private func loadContent() {
    self.state = .loading
    self.loadContentTask?.cancel()
    self.loadContentTask = Task {
      do {
        let tags = try await self.apiClient.getTags()
        self.state = .loaded(
          State.Content(
            categories: tags.categories.map {
              State.Category(
                id: $0.id, name: $0.name, description: $0.description,
                tags: $0.tags.map {
                  State.Tag(id: $0.id, name: $0.name, description: $0.description, selected: false)
                }
              )
            }
          )
        )
      } catch {
        self.state = .error
      }
    }
  }
}

struct FormScreen: View {
  @State
  var model: FormModel

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

      case let .loaded(content):
        ScrollView {
          ZStack {
            VStack {
              Image(.formBackground1)
                .resizable()
                .scaledToFit()
                .offset(y: -100)  // Hack to ignore edges in scroll

              Spacer()

              Image(.formBackground2)
                .resizable()
                .scaledToFit()
                .offset(y: 50)  // Hack to ignore edges in scroll
            }

            VStack {
              HStack {
                VStack(alignment: .leading) {
                  Text("form.title")
                    .font(.largeTitle)
                    .bold()
                    .fontDesign(.rounded)
                    .foregroundStyle(self.theme.colors.text.primary)

                  Text("form.subtitle")
                    .fontDesign(.rounded)
                    .foregroundStyle(self.theme.colors.text.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
              }
              .padding()

              ForEach(content.categories) { category in
                VStack(alignment: .leading) {
                  Text(category.name)
                    .font(.title)
                    .bold()
                    .fontDesign(.rounded)
                    .foregroundStyle(self.theme.colors.text.accent)

                  Text(category.description)
                    .fontDesign(.rounded)
                    .foregroundStyle(self.theme.colors.text.secondary)

                  LazyVGrid(columns: [
                    GridItem(.flexible(minimum: 80, maximum: .infinity)),
                    GridItem(.flexible(minimum: 80, maximum: .infinity)),
                    GridItem(.flexible(minimum: 80, maximum: .infinity)),
                  ]) {
                    ForEach(category.tags) { tag in
                      Button {
                        self.model.selectTag(with: tag.id)
                      } label: {
                        TagView(tag: tag)
                      }
                      .buttonStyle(ScaledButtonStyle())
                      .contextMenu {
                        Text(tag.description)
                      }
                    }
                  }
                }
                .padding()
              }

              MainButton("form.done_button_title") {
                self.model.done()
              }
              .padding(.top)
              .padding(.horizontal)

              Text("form.done_button_caption")
                .font(.caption)
                .fontDesign(.rounded)
                .foregroundStyle(self.theme.colors.text.secondary)
                .padding(.horizontal)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            }
          }
        }
        .scrollBounceBehavior(.basedOnSize)
      }
    }
    .navigationDestination(item: self.$model.destination.read) {
      ReadScreen(model: $0)
    }
    .onAppear {
      self.model.onAppear()
    }
  }
}

struct TagView: View {
  let tag: FormModel.State.Tag

  @Environment(\.theme)
  private var theme: Theme

  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 16, style: .continuous)
        .foregroundStyle(
          self.tag.selected
            ? self.theme.colors.background.primary
            : self.theme.colors.background.accent
        )

      RoundedRectangle(cornerRadius: 16, style: .continuous)
        .stroke(lineWidth: self.tag.selected ? 3 : 0)
        .foregroundStyle(self.theme.colors.background.accent)

      Text(self.tag.name)
        .bold()
        .fontDesign(.rounded)
        .foregroundStyle(
          self.tag.selected
            ? self.theme.colors.text.secondary
            : self.theme.colors.text.lightSecondary
        )
        .multilineTextAlignment(.center)
        .padding(8)
    }
    .animation(.easeInOut, value: self.tag.selected)
    .frame(height: 100)
  }
}

#Preview {
  FormScreen(
    model: {
      let result = FormModel(apiClient: .shared)
      return result
    }()
  )
}
