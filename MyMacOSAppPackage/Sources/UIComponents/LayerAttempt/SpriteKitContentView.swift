//
//  SpriteKitContentView.swift
//  MyMacOSAppFeature
//
//  Created by Moritz Ellerbrock on 17.08.25.
//

import SwiftUI

public struct SpriteKitContentView: View {
    @StateObject var state = WorldState()

    public init() {}

    public var body: some View {
        HStack(spacing: 0) {
            SpriteKitView(state: state, cols: 1024, rows: 512, tile: 32)
                .background(.black)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            Divider()
                .background(.secondary)
            DebugView(state: state)
                .frame(width: 280)
        }
    }
}
