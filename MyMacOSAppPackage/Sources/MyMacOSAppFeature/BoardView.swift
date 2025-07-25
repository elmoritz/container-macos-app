//
//  BoardView.swift
//  MyMacOSAppFeature
//
//  Created by Moritz Ellerbrock on 25.07.25.
//

import SwiftUI
import GameEngine

struct BoardView: View {
    let board: Board
    let width: Int
    let height: Int
    let xOffset: Int
    let yOffset: Int
    let space: CGFloat = 1
    @Binding var hoveredTile: Tile?

    var body: some View {
        VStack(spacing: space) {
            ForEach(0..<height, id: \.self) { row in
                HStack(spacing: space) {
                    ForEach(0..<width, id: \.self) { col in
                        let pos = Position(x: col + xOffset, y: row + yOffset)
                        if let tile = board[pos] {
                            TileView(tile: tile) { hovered in
                                hoveredTile = hovered
                            }
                        } else {
                            Color.clear.frame(width: 32, height: 32)
                        }
                    }
                }
            }
        }
    }
}
