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

    var body: some View {
        VStack {
            // One Spacer up top
            Spacer()

            Text("Add your favourite podcasts!")
                .font(.title)
                .padding()

            TextField("Search for podcasts", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            // two Spacers at the bottom
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            hideKeyboard()
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}
