//
//  PodcastModel.swift
//  PodJourney
//
//  Created by . . on 11/03/2025.
//

import Foundation

// Matches iTunes Search results
struct PodcastResponse: Decodable {
    let results: [Podcast]
}

// Basic podcast info (expand as needed)
struct Podcast: Decodable, Identifiable {
    let collectionId: Int
    let collectionName: String
    let artistName: String
    let artworkUrl600: String?

    // Conform to Identifiable
    var id: Int {
        collectionId
    }
}
