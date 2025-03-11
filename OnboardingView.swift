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
    
    @StateObject private var viewModel = OnboardingViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Add your favourite podcasts!")
                .font(.title)

            TextField("Search for podcasts", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused($isTextFieldFocused)
                .onChange(of: searchText, initial: false) { newValue, oldValue in
                    viewModel.searchForPodcasts(query: newValue)
                }

            if viewModel.isLoading {
                ProgressView("Searching…")
            }

            List(viewModel.podcasts) { podcast in
                // Instead of a VStack, just reference your custom row
                PodcastRowView(podcast: podcast)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .contentShape(Rectangle())
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
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
