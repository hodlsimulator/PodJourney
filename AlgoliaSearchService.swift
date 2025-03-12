//
//  AlgoliaSearchService.swift
//  PodJourney
//
//  Created by . . on 11/03/2025.
//

import Foundation

/// The model you store in Algolia. Could mirror iTunes' fields, but
/// let's keep it minimal to avoid large offline storage.
struct AlgoliaPodcast: Codable, Identifiable {
    // We'll use iTunes' collectionId as the objectID so it's unique.
    let objectID: String
    let title: String
    let artist: String
    let artworkUrl: String?

    // For SwiftUI
    var id: String { objectID }
}

class AlgoliaSearchService {
    static let shared = AlgoliaSearchService()

    // Replace with your real credentials
    private let appID = "WJGZY1QN6A"
    private let apiKey = "2944d5c19394408ff7cc5058f07bcf44"
    private let indexName = "podcasts_index"

    /// Search Algolia for `query` via direct POST to:
    ///   https://<APP_ID>-dsn.algolia.net/1/indexes/<INDEX_NAME>/query
    func search(query: String) async throws -> [AlgoliaPodcast] {
        guard !query.isEmpty else { return [] }

        let urlString = "https://\(appID)-dsn.algolia.net/1/indexes/\(indexName)/query"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "X-Algolia-API-Key")
        request.setValue(appID, forHTTPHeaderField: "X-Algolia-Application-Id")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [ "query": query ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)

        guard
            let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let hitsArray = root["hits"] as? [[String: Any]]
        else {
            return []
        }

        let hitsData = try JSONSerialization.data(withJSONObject: hitsArray)
        return try JSONDecoder().decode([AlgoliaPodcast].self, from: hitsData)
    }

    /// "Upsert" (add or update) these podcasts into Algolia so future searches skip iTunes.
    /// We'll do a batch operation with 'saveObjects' to push them to the index.
    func uploadPodcasts(_ podcasts: [Podcast]) async throws {
        // Convert iTunes podcasts to Algolia-friendly structure
        let objects = podcasts.map { p in
            AlgoliaPodcast(
                objectID: String(p.collectionId),  // Convert Int -> String
                title: p.collectionName,
                artist: p.artistName,
                artworkUrl: p.artworkUrl60
            )
        }

        // Build JSON body for a batch 'saveObjects' request
        // https://www.algolia.com/doc/api-reference/api-methods/save-objects/
        var requestArray: [[String: Any]] = []
        for obj in objects {
            let dict: [String: Any] = [
                "objectID": obj.objectID,
                "title": obj.title,
                "artist": obj.artist,
                "artworkUrl": obj.artworkUrl ?? ""
            ]
            requestArray.append(dict)
        }

        let batchBody: [String: Any] = [
            "requests": [
                [
                    "action": "updateObject",
                    "body": requestArray
                ]
            ]
        ]

        let urlString = "https://\(appID)-dsn.algolia.net/1/indexes/\(indexName)/batch"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "X-Algolia-API-Key")
        request.setValue(appID, forHTTPHeaderField: "X-Algolia-Application-Id")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpBody = try JSONSerialization.data(withJSONObject: batchBody)

        // Perform the batch update
        _ = try await URLSession.shared.data(for: request)
        // We don’t parse the returned taskID for this example, but you can wait for indexing if you want
    }
}

