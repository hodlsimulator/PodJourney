//
//  OnboardingViewModel.swift
//  PodJourney
//
//  Created by . . on 11/03/2025.
//

import SwiftUI

@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var podcasts: [Podcast] = []
    @Published var isLoading = false

    func searchForPodcasts(query: String) {
        Task {
            do {
                isLoading = true

                guard !query.isEmpty else {
                    // If empty query, just clear everything
                    podcasts = []
                    isLoading = false
                    return
                }

                // 1) Always fetch from iTunes first (primary data & thumbnails)
                let iTunesResults = try await iTunesAPIService.shared.fetchPodcasts(for: query)
                print("[iTunes] Found \(iTunesResults.count) results for '\(query)'")

                // 2) Then check Algolia to see which items are considered matches/synonyms
                let algoliaResults = try await AlgoliaSearchService.shared.search(query: query)
                print("[Algolia] Found \(algoliaResults.count) matches for '\(query)'")

                // 3) Convert Algolia's 'objectID' to a Set of collectionIds
                let algIDs = Set(algoliaResults.map { $0.objectID })

                // 4) Reorder iTunes results: those found in Algolia go first
                var matched: [Podcast] = []
                var unmatched: [Podcast] = []

                for podcast in iTunesResults {
                    let idAsString = String(podcast.collectionId)
                    if algIDs.contains(idAsString) {
                        matched.append(podcast)
                    } else {
                        unmatched.append(podcast)
                    }
                }

                // 5) Final list => Algolia matches on top, then the rest
                podcasts = matched + unmatched

                print("[Merge] Moved \(matched.count) Algolia matches to top, \(unmatched.count) remain unmatched.")
                isLoading = false
            } catch {
                print("[Error] Search failure:", error)
                isLoading = false
            }
        }
    }
}
