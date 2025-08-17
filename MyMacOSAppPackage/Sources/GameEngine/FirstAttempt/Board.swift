//
//  Board.swift
//  MyMacOSAppFeature
//
//  Created by Moritz Ellerbrock on 27.07.25.
//


public struct Board {
    private var fullBoard: Dictionary<Position, Tile>

    public init(fullBoard: Dictionary<Position, Tile>) {
        self.fullBoard = fullBoard
    }

    public var map: Dictionary<Position, Tile> {
        fullBoard
    }
    
    public var dimensions: (width: Int, height: Int) {
        fullBoard.dimensions
    }

    public func extractGrid(numberOfNeighbors: Int, selectedTilePosition position: Position) -> Dictionary<Position, Tile> {
        fullBoard.extractGrid(numberOfNeighbors: numberOfNeighbors, selectedTilePosition: position)
    }

    public func tile(at position: Position) -> Tile? {
        fullBoard[position]
    }

    public subscript(position: Position) -> Tile? {
        fullBoard[position]
    }
}

extension Dictionary where Key == Position, Value == Tile {
    func resolveRoadType(for position: Position, connectable: (Tile) -> Bool) -> TileType {
        let bitmask = Direction.tileBitmaskInt(for: position, in: self, connectable: connectable)
        return TileType.roadBitmaskToTileType[bitmask] ?? .flat
    }

    func resolveWallType(for position: Position, connectable: (Tile) -> Bool) -> TileType {
        let bitmask = Direction.tileBitmaskInt(for: position, in: self, connectable: connectable)
        return TileType.wallBitmaskToTileType[bitmask] ?? .wallStraightVertical
    }

    func resolveWaterType(for position: Position, connectable: (Tile) -> Bool) -> TileType {
        let bitmask = Direction.tileBitmaskInt(for: position, in: self, connectable: connectable)
        return TileType.waterBitmaskToTileType[bitmask] ?? .waterShallow
    }

    func resolveBridgeType(for position: Position, connectable: (Tile) -> Bool) -> TileType {
        let bitmask = Direction.tileBitmaskInt(for: position, in: self, connectable: connectable)
        return TileType.bridgeBitmaskToTileType[bitmask] ?? .bridgeHorizontal
    }

    var dimensions: (width: Int, height: Int) {
        return (
            width: Swift.max(keys.map(\.x).max() ?? 0, 0),
            height: Swift.max(keys.map(\.y).max() ?? 0, 0)
        )
    }

    func extractGrid(numberOfNeighbors: Int, selectedTilePosition position: Position) -> Self {
        let center = position
        let minX = center.x - numberOfNeighbors
        let maxX = center.x + numberOfNeighbors
        let minY = center.y - numberOfNeighbors
        let maxY = center.y + numberOfNeighbors

        var result: Dictionary<Position, Tile> = [:]

        for x in minX...maxX {
            for y in minY...maxY {
                let pos = Position(x: x, y: y)
                if let tile = self[pos] {
                    // Normalize positions so that the selected tile is always at the center of the new board
                    let normalized = Position(x: x - minX, y: y - minY)
                    result[normalized] = tile
                }
            }
        }

        return result
    }
}
