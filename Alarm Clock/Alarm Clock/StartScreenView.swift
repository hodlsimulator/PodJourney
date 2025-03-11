//
//  StartScreenView.swift
//  Alarm Clock
//
//  Created by . . on 08/04/2024.
//

import Foundation
import SwiftUI

struct StartScreenView: View {
    var onStart: () -> Void
    
    var body: some View {
        VStack {
            Text("Ready to Play?")
                .font(.largeTitle)
            Button("Start", action: onStart)
                .buttonStyle(.borderedProminent)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.8))
        .foregroundColor(.white)
    }
}
