//
//  APIModels.swift
//  Fablescope
//
//  Created by Timur Guliamov on 24.02.2024.
//

struct Tag: Hashable, Identifiable, Codable {
  let id: Int
  let name: String
  let description: String
}

struct TagID: Hashable, Identifiable, Codable {
  let id: Int
}

struct TagsCategory: Hashable, Identifiable, Codable {
  let id: String
  let name: String
  let description: String
  let tags: [Tag]
}

struct TagsResponse: Hashable, Codable {
  let categories: [TagsCategory]
}

struct TagIDs: Hashable, Codable {
  let tags: [TagID]
}

struct StoryResponse: Hashable, Codable {
  let text: String
}
