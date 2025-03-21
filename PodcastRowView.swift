//
//  PodcastRowView.swift
//  PodJourney
//
//  Created by . . on 11/03/2025.
//

import SwiftUI
import NukeUI

struct PodcastRowView: View {
    let podcast: Podcast

    var body: some View {
        HStack {
            if let thumbnailUrl = podcast.artworkUrl60,
               let url = URL(string: thumbnailUrl) {
                LazyImage(url: url) { state in
                    if let image = state.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else if state.error != nil {
                        Image(systemName: "photo")
                            .resizable()
                    } else {
                        ProgressView()
                    }
                }
                .frame(width: 50, height: 50)
                .cornerRadius(6)
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .frame(width: 50, height: 50)
            }

            VStack(alignment: .leading) {
                Text(podcast.collectionName)
                    .font(.headline)
                Text(podcast.artistName)
                    .font(.subheadline)
            }
        }
    }
}
