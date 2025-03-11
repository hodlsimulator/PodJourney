//
//  iTunesAPIService.swift
//  PodJourney
//
//  Created by . . on 11/03/2025.
//

import Foundation

// An actor so multiple calls won't conflict
actor iTunesAPIService {
    static let shared = iTunesAPIService()

    func fetchPodcasts(for query: String) async throws -> [Podcast] {
        // Encode query to handle spaces etc.
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://itunes.apple.com/search?media=podcast&term=\(encoded)") else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(PodcastResponse.self, from: data)
        return response.results
    }
}
