//
//  TileVisualStyle.swift
//  MyMacOSAppFeature
//
//  Created by Moritz Ellerbrock on 27.07.25.
//

import SwiftUI

public struct TileVisualStyle {
    public let baseColor: Color
    public let shape: TileShape
    public let rotation: Int // degrees
    public let overlayColors: [Color]?
}
