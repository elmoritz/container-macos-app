import SwiftUI
import GameEngine
import UIComponents

public struct ContentView: View {
//    let board: Board = Factory.generateFlatBoard(width: 10, height: 10)
//    let board = Factory.generateSeededBoard(width: 512, height: 512, seed: 12345)
//    let board = Factory.generateImprovedSeededBoard(width: 512, height: 512, seed: 12345)
    let board = Factory.generateNoiseSeededBoard(width: 512, height: 512, seed: 12345)

    @State private var hoveredTilePosition: Position? = nil

    public init() {
    }

    public var body: some View {
        HStack {
            MainViewPort()
//            ViewportBoardView(fullBoard: board,
//                              hoveredTile: $hoveredTile)
//            debugView
        }
    }

    var debugView: some View {
        DebugTileView(hoveredTilePosition: $hoveredTilePosition, board: board)
    }
}
