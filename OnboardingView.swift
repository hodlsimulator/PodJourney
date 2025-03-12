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
    private let debounceInterval = 1.0

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Add your favourite podcasts!")
                .font(.title)

            // HStack + Spacer so the text field can be centered.
            HStack {
                Spacer()

                ZStack(alignment: .trailing) {
                    TextField("Search for podcasts", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($isTextFieldFocused)
                        .onChange(of: searchText) { oldValue, newValue in
                            print("Typed text changed from '\(oldValue)' to '\(newValue)'")

                            // Cancel any pending search
                            debounceTask?.cancel()

                            // Create a new work item for the search
                            let task = DispatchWorkItem {
                                viewModel.searchForPodcasts(query: newValue)
                            }
                            // Schedule the search after a delay
                            debounceTask = task
                            DispatchQueue.main.asyncAfter(deadline: .now() + debounceInterval, execute: task)
                        }

                    // Show a plain 'delete all' button if there's any text
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                                // Increase padding so it’s easier to tap
                                .padding(8)
                        }
                        // .plain style keeps the button background transparent
                        .buttonStyle(.plain)
                    }
                }
                // Narrower text field, so it doesn’t span the entire screen
                .frame(maxWidth: 300)

                Spacer()
            }

            if viewModel.isLoading {
                ProgressView("Searching…")
            }

            List(viewModel.podcasts) { podcast in
                PodcastRowView(podcast: podcast)
            }
        }
        .padding()
        // This expands the whole view in its container but keeps our text field limited.
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
