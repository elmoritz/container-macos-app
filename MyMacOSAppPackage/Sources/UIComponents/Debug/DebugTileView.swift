//
//  SwiftUIView.swift
//  MyMacOSAppFeature
//
//  Created by Moritz Ellerbrock on 26.07.25.
//

import SwiftUI
import GameEngine

public struct DebugTileView: View {
    @Binding var hoveredTile: Tile?
    let board: Board

    public init(hoveredTile: Binding<Tile?>, board: Board) {
        self.board = board
        _hoveredTile = $hoveredTile
    }

    var surroundingBoard: Board? {
        guard let hoveredTile else {
            return nil
        }

        return Board(fullBoard: board.extractGrid(numberOfNeighbors: 1, selectedTile: hoveredTile))
    }

    public var body: some View {
        VStack(alignment: .leading) {
            Text("Hovered Tile")
                .bold()
            if let tile = hoveredTile {
                Group {
                    Text("Type: \(tile.type.rawValue)")
                    Text("Position: (\(tile.position.x), \(tile.position.y))")
                    if !tile.overlays.isEmpty {
                        Text("Overlays: \(tile.overlays.map(\.rawValue).joined(separator: ", "))")
                    }
                    if let tag = tile.environmentTag {
                        Text("EnvTag: \(tag)")
                    }
                }
                .font(.system(size: 12))
                .padding(.bottom, 4)
            } else {
                Text("—").foregroundColor(.gray)
            }
            Spacer(minLength: 16)
            neighbors()
            Spacer()
        }
        .padding()
        .frame(width: 360)
        .background(Color.black.opacity(0.05))
        .cornerRadius(8)
    }

    @ViewBuilder
    func neighbors() -> some View {
        if let surroundingBoard {
            BoardView(board: surroundingBoard,
                      width: 3,
                      height: 3,
                      xOffset: 0,
                      yOffset: 0,
                      space: 1,
                      hoveredTile: .constant(debugBoard.tile(at: Position(x: 1, y: 1))))
            .scaleEffect(3)
            .frame(width: 3 * 3 * 32, height: 3 * 3 * 32)
        } else {
            EmptyView()
        }
    }
}

#Preview {
    DebugTileView(
        hoveredTile: .constant(debugBoard.tile(at: Position(x: 1, y: 1))),
        board: debugBoard
    )
}

#if DEBUG
nonisolated(unsafe) let debugBoard: Board =
Board(fullBoard: [
    Position(x: 0, y: 0):.init(type: .roadCornerBR, position: .zero),
    Position(x: 1, y: 0):.init(type: .roadStraightHorizontal, position: .zero),
    Position(x: 2, y: 0):.init(type: .roadCornerBL, position: .zero),
    Position(x: 0, y: 1):.init(type: .roadStraightVertical, position: .zero),
    Position(x: 1, y: 1):.init(type: .roadCrossroad, position: .zero),
    Position(x: 2, y: 1):.init(type: .roadStraightVertical, position: .zero),
    Position(x: 0, y: 2):.init(type: .roadCornerTR, position: .zero),
    Position(x: 1, y: 2):.init(type: .roadStraightHorizontal, position: .zero),
    Position(x: 2, y: 2):.init(type: .wallCornerTL, position: .zero),
])
#endif
