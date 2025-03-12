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

    // We'll store our pending search task here, so we can cancel if the user keeps typing
    @State private var debounceTask: DispatchWorkItem?
    // You can tweak this interval (in seconds)
    private let debounceInterval = 1.0

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Add your favourite podcasts!")
                .font(.title)

            TextField("Search for podcasts", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused($isTextFieldFocused)
                .onChange(of: searchText, initial: false) { newValue, _ in
                    print("Current typed text:", newValue)
                    // Cancel any pending search
                    debounceTask?.cancel()

                    // Create a new work item that calls our search
                    let task = DispatchWorkItem {
                        viewModel.searchForPodcasts(query: newValue)
                    }
                    // Store and schedule after 0.3s
                    debounceTask = task
                    DispatchQueue.main.asyncAfter(deadline: .now() + debounceInterval, execute: task)
                }

            if viewModel.isLoading {
                ProgressView("Searching…")
            }

            List(viewModel.podcasts) { podcast in
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
