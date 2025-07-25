import SwiftUI
import GameEngine

public struct ContentView: View {
    //    let board: Board = Factory.generateFlatBoard(width: 10, height: 10)
    let board2 = Factory.generateSeededBoard(width: 128, height: 128, seed: 12345)
    
    
    public init() {}
    
    public var body: some View {
        ViewportBoardView(fullBoard: board2,
                          boardWidth: board2.dimensions.width,
                          boardHeight: board2.dimensions.height)
    }
}
