//
//  ExportTilesButton.swift
//  MyMacOSAppFeature
//
//  Created by Moritz Ellerbrock on 28.07.25.
//

import SwiftUI
import GameEngine

struct ExportTilesButton: View {
    var body: some View {
        Button("Export Tiles") {
            let folder = URL(fileURLWithPath: "/Users/moritz/Desktop/TileExports")
            exportAllTileTypes(to: folder)
        }
    }

    func exportAllTileTypes(to folder: URL) {
        for tileType in TileType.allCases {
            let fileURL = folder.appendingPathComponent("\(tileType.rawValue).pdf")
            exportTileAsPDF(tileType: tileType, to: fileURL)
        }
    }

    func exportTileAsPDF(tileType: TileType, to url: URL, size: CGFloat = 128) {
//        let view = TileExportView(type: tileType, dimension: size)
//        let renderer = ImageRenderer(content: view)
//        renderer.scale = 1.0
//        if let data = renderer.cgImage?.dataProvider?.data {
//            try? data.write(to: url)
//        }
    }
}

#Preview {
    VStack {
        TileExportView(type: .roadCrossroad)
        ExportTilesButton()
    }
        .frame(width: 128, height: 128)
        .padding()
}
