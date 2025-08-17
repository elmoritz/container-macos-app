
//
//  SpriteKitView.swift
//  MyMacOSAppFeature
//
//  Created by Moritz Ellerbrock on 11.08.25.
//


import SwiftUI
import SpriteKit

struct SpriteKitView: NSViewRepresentable {
    @ObservedObject var state: WorldState
    let cols: Int
    let rows: Int
    let tile: CGFloat

    func makeNSView(context: Context) -> SKView {
        let view = SKView()
        let scene = MapScene(size: .zero,
                             cols: cols,
                             rows: rows,
                             tileSize: .init(width: tile, height: tile),
                             state: state)
        view.presentScene(scene)
        return view
    }

    func updateNSView(_ nsView: SKView, context: Context) {
        // SpriteKit handles its own drawing; no-op
    }
}

struct DebugView: View {
    @ObservedObject var state: WorldState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Debug Panel").font(.title3).bold()
            Toggle("Show Base", isOn: $state.showsBase)
            Toggle("Show Features", isOn: $state.showsFeatures)
            Toggle("Show Props", isOn: $state.showsProps)
            Slider(value: $state.scale, in: 0.2...4, step: 0.2)
            Divider()
            if let h = state.hover {
                LabeledContent("Column") { Text("\(h.col)") }
                LabeledContent("Row") { Text("\(h.row)") }
                LabeledContent("Layer") { Text(h.layerName) }
                LabeledContent("Tile") { Text(h.tileGroupName ?? "—") }
            } else {
                Text("Hover a tile…").foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .frame(minWidth: 240)
    }
}

