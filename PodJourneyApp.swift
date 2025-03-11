//
//  PodJourneyApp.swift
//  PodJourney
//
//  Created by . . on 10/03/2025.
//

import SwiftUI

@main
struct PodJourneyApp: App {
    let persistenceController = PersistenceController.shared
    
    // Tracks if user has completed onboarding
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    
    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            } else {
                OnboardingView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
        }
    }
}
