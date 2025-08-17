//
//  WorldState.swift
//  MyMacOSAppFeature
//
//  Created by Moritz Ellerbrock on 11.08.25.
//


import SwiftUI
import Combine

final class WorldState: ObservableObject {
    struct HoverInfo: Identifiable {
        let id = UUID()
        let col: Int
        let row: Int
        let layerName: String
        let tileGroupName: String?
    }

    @Published var hover: HoverInfo?
    @Published var showsBase = true
    @Published var showsFeatures = true
    @Published var showsProps = true
    @Published var scale: CGFloat = 1.0
    var seed: Int32 = 1234567890
}
