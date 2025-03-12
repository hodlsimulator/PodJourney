//
//  OnboardingView.swift
//  PodJourney
//
//  Created by ... on 10/03/2025.
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
        GeometryReader { geo in
            // Landscape if width > height
            let isLandscape = geo.size.width > geo.size.height

            if isLandscape {
                // Landscape: text/title on the left, results on the right
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Add your favourite podcasts!")
                            .font(.title)

                        ZStack(alignment: .trailing) {
                            TextField("Search for podcasts", text: $searchText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .focused($isTextFieldFocused)
                                .onChange(of: searchText) { oldValue, newValue in
                                    print("Typed text changed from '\(oldValue)' to '\(newValue)'")

                                    // Cancel any pending search
                                    debounceTask?.cancel()

                                    // Debounced search
                                    let task = DispatchWorkItem {
                                        viewModel.searchForPodcasts(query: newValue)
                                    }
                                    debounceTask = task
                                    DispatchQueue.main.asyncAfter(deadline: .now() + debounceInterval,
                                                                  execute: task)
                                }

                            if !searchText.isEmpty {
                                Button {
                                    searchText = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                        .padding(8) // Larger tap area
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .frame(maxWidth: 300) // Keep it from stretching too wide

                        if viewModel.isLoading {
                            ProgressView("Searching…")
                        }
                    }
                    .padding()
                    .frame(maxWidth: 350, alignment: .topLeading)

                    // Results on the right
                    List(viewModel.podcasts) { podcast in
                        PodcastRowView(podcast: podcast)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isTextFieldFocused = true
                    }
                }
                .onTapGesture {
                    hideKeyboard()
                }

            } else {
                // Portrait: existing "stacked" layout
                VStack(alignment: .leading, spacing: 16) {
                    Text("Add your favourite podcasts!")
                        .font(.title)

                    HStack {
                        Spacer()
                        ZStack(alignment: .trailing) {
                            TextField("Search for podcasts", text: $searchText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .focused($isTextFieldFocused)
                                .onChange(of: searchText) { oldValue, newValue in
                                    print("Typed text changed from '\(oldValue)' to '\(newValue)'")

                                    debounceTask?.cancel()
                                    let task = DispatchWorkItem {
                                        viewModel.searchForPodcasts(query: newValue)
                                    }
                                    debounceTask = task
                                    DispatchQueue.main.asyncAfter(deadline: .now() + debounceInterval,
                                                                  execute: task)
                                }

                            if !searchText.isEmpty {
                                Button {
                                    searchText = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                        .padding(8)
                                }
                                .buttonStyle(.plain)
                            }
                        }
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
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}
