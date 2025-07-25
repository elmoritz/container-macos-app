//
//  ZoomableBoardContainer.swift
//  MyMacOSAppFeature
//
//  Created by Moritz Ellerbrock on 25.07.25.
//

import SwiftUI
import GameEngine

struct ZoomableBoardContainer: View {
    @State private var zoom: CGFloat = 1.0
    let board: Board 

    var body: some View {
        VStack {
            ScrollView([.horizontal, .vertical]) {
                BoardView(board: board, width: board.dimensions.width, height: board.dimensions.height)
                    .scaleEffect(zoom)
                    .padding()
            }

            HStack {
                Text("Zoom")
                Slider(value: $zoom, in: 0.5...2.0, step: 0.1)
                Text(String(format: "%.1fx", zoom))
            }
            .padding()
        }
        .background(Color.black)
    }
}
