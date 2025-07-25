//
//  ViewportBoardView.swift
//  MyMacOSAppFeature
//
//  Created by Moritz Ellerbrock on 25.07.25.
//


import SwiftUI
import GameEngine

struct ViewportBoardView: View {
    let fullBoard: Board
    let boardWidth: Int
    let boardHeight: Int

    @State private var zoom: CGFloat = 2.0
    @State private var center = Position(x: 64, y: 64)
    @Binding var hoveredTile: Tile?
    private let tileSize: CGFloat = 32
    private let viewportPixelSize = CGSize(width: 960, height: 640)

    var body: some View {
        VStack {
            ScrollView([.horizontal, .vertical]) {
                boardViewport
                    .scaleEffect(zoom)
                    .frame(width: viewportPixelSize.width, height: viewportPixelSize.height)
                    .clipped()
                    .background(Color.black)
            }

            zoomAndPanControls
        }
    }

    private var boardViewport: some View {
        let tilesWide = Int(viewportPixelSize.width / (tileSize * zoom))
        let tilesHigh = Int(viewportPixelSize.height / (tileSize * zoom))
        let minX = max(center.x - tilesWide / 2, 0)
        let maxX = min(center.x + tilesWide / 2, boardWidth - 1)
        let minY = max(center.y - tilesHigh / 2, 0)
        let maxY = min(center.y + tilesHigh / 2, boardHeight - 1)

        let visibleBoard: Board = fullBoard.filter { pos, _ in
            pos.x >= minX && pos.x <= maxX && pos.y >= minY && pos.y <= maxY
        }

        return BoardView(board: visibleBoard,
                         width: maxX - minX + 1,
                         height: maxY - minY + 1,
                         xOffset: minX,
                         yOffset: minY,
                         hoveredTile: $hoveredTile)
    }

    private var zoomAndPanControls: some View {
        VStack {
            Slider(value: $zoom, in: 0.5...4.0, step: 0.1)
                .padding(.horizontal)
            Text("Zoom: \(String(format: "%.1fx", zoom))")

            HStack {
                Button("←") { center = center.set(x: max(center.x - 1, 0))  }
                Button("↑") { center = center.set(y: max(center.y - 1, 0)) }
                Button("↓") { center = center.set(y: min(center.y + 1, boardHeight - 1)) }
                Button("→") { center = center.set(x: min(center.x + 1, boardWidth - 1)) }
            }
        }
        .padding()
    }
}
