//
//  OnboardingView.swift
//  PodJourney
//
//  Created by . . on 10/03/2025.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @State private var searchText: String = ""
    @FocusState private var isTextFieldFocused: Bool

    // NEW: Add an @StateObject or @ObservedObject for your view model.
    @StateObject private var viewModel = OnboardingViewModel() // NEW

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Add your favourite podcasts!")
                .font(.title)

            TextField("Search for podcasts", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused($isTextFieldFocused)
                .onChange(of: searchText, initial: false) { newValue, oldValue in
                    // newValue: the updated string
                    // oldValue: the previous string
                    viewModel.searchForPodcasts(query: newValue)
                }

            // NEW: Display loading indicator
            if viewModel.isLoading {
                ProgressView("Searching…")
            }

            // NEW: Show results in a List
            List(viewModel.podcasts) { podcast in
                VStack(alignment: .leading) {
                    Text(podcast.collectionName)
                        .font(.headline)
                    Text(podcast.artistName)
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .contentShape(Rectangle())
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // Slight delay ensures text field can accept focus
                isTextFieldFocused = true
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}
