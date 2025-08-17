//
//  Tile.swift
//  MyMacOSAppFeature
//
//  Created by Moritz Ellerbrock on 27.07.25.
//


public struct Tile: Codable {
    public let type: TileType
//    public let position: Position
    public var overlays: [TileType] = []
    public var environmentTag: String? = nil

    public init(type: TileType, overlays: [TileType] = [], environmentTag: String? = nil) {
        self.type = type
//        self.position = position
        self.overlays = overlays
        self.environmentTag = environmentTag
    }

//    func set(position: Position) -> Self {
//        .init(type: self.type, position: position, overlays: self.overlays, environmentTag: self.environmentTag)
//    }
}
