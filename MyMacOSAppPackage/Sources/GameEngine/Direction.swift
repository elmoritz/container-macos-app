//
//  Direction.swift
//  MyMacOSAppFeature
//
//  Created by Moritz Ellerbrock on 27.07.25.
//


enum Direction: CaseIterable {
    case up, right, down, left

    var offset: (dx: Int, dy: Int) {
        switch self {
        case .up: return (0, -1)
        case .right: return (1, 0)
        case .down: return (0, 1)
        case .left: return (-1, 0)
        }
    }

    static func tileBitmaskInt(for position: Position, in tiles: Dictionary<Position, Tile>, connectable: (Tile) -> Bool) -> UInt8 {
        var bitmask: UInt8 = 0
        for (i, direction) in Direction.allCases.enumerated() {
            let neighborPos = Position(x: position.x + direction.offset.dx, y: position.y + direction.offset.dy)
            if let neighbor = tiles[neighborPos], connectable(neighbor) {
                bitmask |= (1 << (3 - i))
            }
        }
        return bitmask
    }
}
