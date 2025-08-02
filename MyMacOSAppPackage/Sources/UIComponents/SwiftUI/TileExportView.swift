//
//  TileExportView.swift
//  MyMacOSAppFeature
//
//  Created by Moritz Ellerbrock on 28.07.25.
//

import GameEngine
import SwiftUI

struct TileExportView: View {
    let type: TileType
    var dimension: CGFloat = 128

    var body: some View {
        let dummyTile = Tile(type: type, position: .zero)
        TileView(tile: dummyTile, dimension: dimension, onHoverTile: nil)
    }
}
    
