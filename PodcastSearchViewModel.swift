//
//  PodcastSearchViewModel.swift
//  PodJourney
//
//  Created by . . on 11/03/2025.
//

import SwiftUI

@MainActor
class PodcastSearchViewModel: ObservableObject {
    @Published var searchResults: [AlgoliaPodcast] = []
    @Published var isLoading = false

    func searchPodcasts(_ query: String) {
        isLoading = true
        Task {
            do {
                let results = try await AlgoliaSearchService.shared.search(query: query)
                self.searchResults = results
            } catch {
                print("Search error:", error)
            }
            isLoading = false
        }
    }
}

