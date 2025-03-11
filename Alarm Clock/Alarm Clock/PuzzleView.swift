//
//  PuzzleView.swift
//  Alarm Clock
//
//  Created by . . on 06/04/2024.
//

import SwiftUI

struct PuzzleView: View {
    @Binding var isPresented: Bool
    private let gridLayout: [GridItem] = Array(repeating: .init(.flexible()), count: 5)
    @State private var tiles: [Tile] = (0..<25).map { _ in Tile() }

    var body: some View {
        VStack {
            Spacer()
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: gridLayout, spacing: 10) {
                    ForEach(tiles) { tile in
                        Rectangle()
                            .foregroundColor(tile.isRevealed ? .green : Color(red: 0.5, green: 0.5, blue: 0.5))
                            .aspectRatio(1, contentMode: .fit)
                            .border(Color.white, width: 1)
                            .onTapGesture {
                                    tileTapped(tile)
                            }
                    }
                }
                .padding(20)
                .background(Color.black.opacity(0.8))
                // Applying fixed size to prevent any resizing impression
                .fixedSize(horizontal: false, vertical: true)
            }
            .frame(width: 500, height: 500) // Explicit fixed size for the ScrollView container
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            setupGame()
        }
    }
    
    private func tileTapped(_ tile: Tile) {
            guard let index = tiles.firstIndex(where: { $0.id == tile.id }) else { return }
            withAnimation {
                tiles[index].isRevealed.toggle()
            }
        }
        
        private func setupGame() {
            // Shuffle the tiles or perform other setup tasks here.
            tiles.shuffle()
        }
    }

    struct Tile: Identifiable {
        let id = UUID()
        var isRevealed: Bool = false
    }

    // Preview for the PuzzleView
    struct PuzzleView_Previews: PreviewProvider {
        static var previews: some View {
            PuzzleView(isPresented: .constant(true))
        }
    }
