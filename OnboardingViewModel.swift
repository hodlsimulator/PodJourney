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
    @Published var isLoading: Bool = false

    func searchForPodcasts(query: String) {
        Task {
            do {
                isLoading = true
                let results = try await iTunesAPIService.shared.fetchPodcasts(for: query)
                podcasts = results
                isLoading = false
            } catch {
                // You might want to show an error message instead
                print("Error fetching podcasts: \(error)")
                isLoading = false
            }
        }
    }
}
