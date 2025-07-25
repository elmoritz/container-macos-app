import SwiftUI
import GameEngine

public struct ContentView: View {
    //    let board: Board = Factory.generateFlatBoard(width: 10, height: 10)
    let board2 = Factory.generateSeededBoard(width: 128, height: 128, seed: 12345)
    @State private var hoveredTile: Tile? = nil

    public init() {
    }

    public var body: some View {
        HStack {
            ViewportBoardView(fullBoard: board2,
                              boardWidth: board2.dimensions.width,
                              boardHeight: board2.dimensions.height,
                              hoveredTile: $hoveredTile)
            debugView
        }
    }

    var debugView: some View {
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
            Spacer()
        }
        .padding()
        .frame(width: 360)
        .background(Color.black.opacity(0.05))
        .cornerRadius(8)
    }
}
