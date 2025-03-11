//
//  MemoryGameView.swift
//  Alarm Clock
//
//  Created by . . on 06/04/2024.
//

import SwiftUI

struct MemoryGameView: View {
    @ObservedObject var viewModel: MemoryGameViewModel
    @State private var showStartScreen = true
    
    // Define the grid layout with fixed-size tiles
    private let tileWidth: CGFloat = 60
    private let tileHeight: CGFloat = 60
    private let spacing: CGFloat = 10 // Spacing between tiles
    // Adjust the bottom padding to be slightly less if needed
    private let padding: CGFloat = 10 // Padding around the grid
    private var gridHeight: CGFloat {
        let rows = CGFloat((viewModel.tiles.count + columns.count - 1) / columns.count)
        return rows * tileHeight + (rows - 1) * spacing + padding // padding only applied to top here
    }
    
    private var columns: [GridItem] {
        Array(repeating: .init(.fixed(tileWidth), spacing: spacing), count: 5)
    }
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: columns, spacing: spacing) {
                            ForEach(viewModel.tiles, id: \.id) { tile in
                                TileView(viewModel: viewModel, tileId: tile.id)
                                    .frame(width: tileWidth, height: tileHeight)
                            }
                        }
                        // Apply padding to top, leading, and trailing edges only
                        .padding([.top, .leading, .trailing], padding)
                    }
                    .frame(minWidth: (tileWidth + spacing) * CGFloat(columns.count) + padding,
                           minHeight: gridHeight)
                    Spacer()
                }
                // Apply a smaller padding to the bottom, if necessary, to match other sides
                Spacer().frame(height: padding / 0.5)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            if showStartScreen {
                StartScreenView(onStart: {
                    withAnimation {
                        showStartScreen = false
                    }
                    viewModel.setupGame()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        viewModel.revealCorrectTilesTemporarily()
                    }
                })
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.5))
                .foregroundColor(.white)
            }
        }
    }
}

struct TileView: View {
    @ObservedObject var viewModel: MemoryGameViewModel
    let tileId: UUID

    private var tile: MemoryTile? {
        viewModel.tiles.first { $0.id == tileId }
    }

    var body: some View {
        Group {
            if let tile = tile {
                Rectangle()
                    .fill(tile.isRevealed ? (tile.isCorrect ? viewModel.currentRoundColor : Color.red) : Color(red: 0.4, green: 0.4, blue: 0.4))
                    .frame(width: 60, height: 60)
                    // Apply a more subtle flip effect
                    .rotation3DEffect(.degrees(tile.isRevealed ? 180 : 0), axis: (x: 0, y: 1, z: 0), perspective: 0.5)
                    .onTapGesture {
                        withAnimation(Animation.easeInOut(duration: 0.5)) {
                            viewModel.toggleTile(tileId)
                        }
                    }
            } else {
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 60, height: 60)
            }
        }
    }
}

struct FlipEffect: GeometryEffect {
    var isFlipped: Bool
    var angle: Double
    var axis: (x: CGFloat, y: CGFloat, z: CGFloat)

    var animatableData: Double {
        get { angle }
        set { angle = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        // Calculate the midpoint of the rotation to toggle the visibility
        let halfway = isFlipped ? -90.0 : 90.0
        let invisibilityPoint = angle < halfway || angle > halfway
        let perspective = 1.0 / -max(size.width, size.height)
        var transform3d = CATransform3DIdentity
        transform3d.m34 = perspective
        transform3d = CATransform3DRotate(transform3d, CGFloat(Angle(degrees: invisibilityPoint ? angle + 180 : angle).radians), axis.x, axis.y, axis.z)
        return ProjectionTransform(transform3d)
    }
}
