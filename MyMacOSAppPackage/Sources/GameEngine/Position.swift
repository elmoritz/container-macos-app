//
//  Position.swift
//  MyMacOSAppFeature
//
//  Created by Moritz Ellerbrock on 25.07.25.
//


import Foundation
import SwiftUI

public struct Position: Hashable, Codable {
    public let x: Int
    public let y: Int

    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    public func set(x newXValue: Int) -> Self {
        .init(x: newXValue, y: self.y)
    }

    public func set(y newYValue: Int) -> Self {
        .init(x: self.x, y: newYValue)
    }
}

public struct Tile: Codable {
    public let type: TileType
    public let position: Position
    public var overlays: [TileType] = []
    public var environmentTag: String? = nil

    public init(type: TileType, position: Position, overlays: [TileType] = [], environmentTag: String? = nil) {
        self.type = type
        self.position = position
        self.overlays = overlays
        self.environmentTag = environmentTag
    }
}

public enum TileShape {
    case square
    case straight
    case corner
    case tJunction
    case cross
    case end
}

public struct TileVisualStyle {
    public let baseColor: Color
    public let shape: TileShape
    public let rotation: Int // degrees
    public let overlayColors: [Color]?
}

public enum TileType: String, Codable, CaseIterable {
    case flat
    case slopeUp, slopeDown, slopeLeft, slopeRight
    case edgeCliff
    case void

    case roadStraightHorizontal, roadStraightVertical
    case roadCornerTL, roadCornerTR, roadCornerBL, roadCornerBR
    case roadTJunctionUp, roadTJunctionDown, roadTJunctionLeft, roadTJunctionRight
    case roadCrossroad
    case roadDeadEndUp, roadDeadEndDown, roadDeadEndLeft, roadDeadEndRight

    case wallStraightVertical, wallStraightHorizontal
    case wallCornerTL, wallCornerTR, wallCornerBL, wallCornerBR
    case wallTJunctionUp, wallTJunctionDown, wallTJunctionLeft, wallTJunctionRight
    case wallDeadEndUp, wallDeadEndDown, wallDeadEndLeft, wallDeadEndRight
    case wallCrossroad
    case pillar, gate, blocked

    case waterShallow, waterDeep
    case waterShoreTop, waterShoreBottom, waterShoreLeft, waterShoreRight
    case bridgeHorizontal, bridgeVertical
    case waterfall

    case overlayGrass, overlayCracks, overlayStains, overlayPattern, overlayShadow

    case spawn, exit, chest, trap, switchTile, checkpoint

    static var roadBitmaskToTileType: [UInt8: TileType] {
        [
            0b0000: .flat,
            0b0001: .roadDeadEndLeft,
            0b0010: .roadDeadEndDown,
            0b0011: .roadCornerBL,
            0b0100: .roadDeadEndRight,
            0b0101: .roadStraightHorizontal,
            0b0110: .roadCornerBR,
            0b0111: .roadTJunctionDown,
            0b1000: .roadDeadEndUp,
            0b1001: .roadCornerTL,
            0b1010: .roadStraightVertical,
            0b1011: .roadTJunctionLeft,
            0b1100: .roadCornerTR,
            0b1101: .roadTJunctionUp,
            0b1110: .roadTJunctionRight,
            0b1111: .roadCrossroad
        ]
    }

    static var wallBitmaskToTileType: [UInt8: TileType] {
        [
            0b0000: .pillar,
            0b0001: .wallDeadEndLeft,
            0b0010: .wallDeadEndDown,
            0b0011: .wallCornerBL,
            0b0100: .wallDeadEndRight,
            0b0101: .wallStraightHorizontal,
            0b0110: .wallCornerBR,
            0b0111: .wallTJunctionDown,
            0b1000: .wallDeadEndUp,
            0b1001: .wallCornerTL,
            0b1010: .wallStraightVertical,
            0b1011: .wallTJunctionLeft,
            0b1100: .wallCornerTR,
            0b1101: .wallTJunctionUp,
            0b1110: .wallTJunctionRight,
            0b1111: .wallCrossroad
        ]
    }

    static var waterBitmaskToTileType: [UInt8: TileType] {
        [
            0b0000: .waterShallow,
            0b0001: .waterShoreLeft,
            0b0010: .waterShoreBottom,
            0b0011: .waterShoreBottom,
            0b0100: .waterShoreRight,
            0b0101: .waterShoreRight,
            0b0110: .waterShoreBottom,
            0b0111: .waterShoreBottom,
            0b1000: .waterShoreTop,
            0b1001: .waterShoreLeft,
            0b1010: .waterShoreTop,
            0b1011: .waterShoreTop,
            0b1100: .waterShoreTop,
            0b1101: .waterShoreTop,
            0b1110: .waterShoreTop,
            0b1111: .waterShallow
        ]
    }

    static var bridgeBitmaskToTileType: [UInt8: TileType] {
        [
        0b0000: .bridgeHorizontal, // fallback
        0b0101: .bridgeHorizontal,
        0b1010: .bridgeVertical,
        0b1111: .bridgeHorizontal // fallback
    ]
    }

    public func visualStyle(for baseColor: Color, overlayColors: [Color]? = nil) -> TileVisualStyle {
        switch self {
        case .roadStraightHorizontal, .wallStraightHorizontal, .bridgeHorizontal:
            return TileVisualStyle(baseColor: baseColor, shape: .straight, rotation: 0, overlayColors: overlayColors)
        case .roadStraightVertical, .wallStraightVertical, .bridgeVertical:
            return TileVisualStyle(baseColor: baseColor, shape: .straight, rotation: 90, overlayColors: overlayColors)
        case .roadCornerTL, .wallCornerTL:
            return TileVisualStyle(baseColor: baseColor, shape: .corner, rotation: 0, overlayColors: overlayColors)
        case .roadCornerTR, .wallCornerTR:
            return TileVisualStyle(baseColor: baseColor, shape: .corner, rotation: 90, overlayColors: overlayColors)
        case .roadCornerBR, .wallCornerBR:
            return TileVisualStyle(baseColor: baseColor, shape: .corner, rotation: 180, overlayColors: overlayColors)
        case .roadCornerBL, .wallCornerBL:
            return TileVisualStyle(baseColor: baseColor, shape: .corner, rotation: 270, overlayColors: overlayColors)
        case .roadTJunctionUp, .wallTJunctionUp:
            return TileVisualStyle(baseColor: baseColor, shape: .tJunction, rotation: 0, overlayColors: overlayColors)
        case .roadTJunctionRight, .wallTJunctionRight:
            return TileVisualStyle(baseColor: baseColor, shape: .tJunction, rotation: 90, overlayColors: overlayColors)
        case .roadTJunctionDown, .wallTJunctionDown:
            return TileVisualStyle(baseColor: baseColor, shape: .tJunction, rotation: 180, overlayColors: overlayColors)
        case .roadTJunctionLeft, .wallTJunctionLeft:
            return TileVisualStyle(baseColor: baseColor, shape: .tJunction, rotation: 270, overlayColors: overlayColors)
        case .roadCrossroad, .wallCrossroad:
            return TileVisualStyle(baseColor: baseColor, shape: .cross, rotation: 0, overlayColors: overlayColors)
        case .roadDeadEndUp, .wallDeadEndUp:
            return TileVisualStyle(baseColor: baseColor, shape: .end, rotation: 0, overlayColors: overlayColors)
        case .roadDeadEndRight, .wallDeadEndRight:
            return TileVisualStyle(baseColor: baseColor, shape: .end, rotation: 90, overlayColors: overlayColors)
        case .roadDeadEndDown, .wallDeadEndDown:
            return TileVisualStyle(baseColor: baseColor, shape: .end, rotation: 180, overlayColors: overlayColors)
        case .roadDeadEndLeft, .wallDeadEndLeft:
            return TileVisualStyle(baseColor: baseColor, shape: .end, rotation: 270, overlayColors: overlayColors)
        case .flat:
                return TileVisualStyle(baseColor: .brown, shape: .square, rotation: 0, overlayColors: overlayColors)
        case .void:
                return TileVisualStyle(baseColor: .black, shape: .square, rotation: 0, overlayColors: overlayColors)
            case .waterShallow:
                return TileVisualStyle(
                    baseColor: .blue.opacity(0.5),
                    shape: .square,
                    rotation: 0,
                    overlayColors: overlayColors
                )

            case .waterDeep:
                return TileVisualStyle(
                    baseColor: .blue,
                    shape: .square,
                    rotation: 0,
                    overlayColors: overlayColors
                )
        default:
            return TileVisualStyle(baseColor: baseColor, shape: .square, rotation: 0, overlayColors: overlayColors)
        }
    }
}

public typealias Board = Dictionary<Position, Tile>

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

    public var dimensions: (width: Int, height: Int) {
        return (
            width: Swift.max(keys.map(\.x).max() ?? 0, 0),
            height: Swift.max(keys.map(\.y).max() ?? 0, 0)
        )
    }
}

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

    static func tileBitmaskInt(for position: Position, in tiles: Board, connectable: (Tile) -> Bool) -> UInt8 {
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

public enum Factory {
    public static func generateFlatBoard(width: Int, height: Int) -> Board {
        var board: Board = [:]
        for y in 0..<height {
            for x in 0..<width {
                let pos = Position(x: x, y: y)
                board[pos] = Tile(type: .flat, position: pos)
            }
        }
        return board
    }

    public static func generateSeededBoard(width: Int, height: Int, seed: UInt64) -> Board {
        var rng = SeededGenerator(seed: seed)
        var board: Board = [:]

        // First pass: classify general terrain zones (flat, road, wall, water)
        for y in 0..<height {
            for x in 0..<width {
                let pos = Position(x: x, y: y)

                let rand = rng.next() % 100
                let typeCategory: TileType
                switch rand {
                case 0..<10: typeCategory = .waterShallow
                case 10..<20: typeCategory = .wallStraightVertical
                case 20..<30: typeCategory = .roadStraightHorizontal
                default: typeCategory = .flat
                }

                board[pos] = Tile(type: typeCategory, position: pos)
            }
        }

        // Second pass: apply correct bitmask-resolved tile type
        for (pos, tile) in board {
            let newType: TileType

            switch tile.type {
            case .roadStraightHorizontal, .roadStraightVertical:
                newType = board.resolveRoadType(for: pos) { $0.type.rawValue.starts(with: "road") }
            case .wallStraightVertical, .wallStraightHorizontal:
                newType = board.resolveWallType(for: pos) { $0.type.rawValue.starts(with: "wall") }
            case .waterShallow:
                newType = board.resolveWaterType(for: pos) { $0.type == .waterShallow }
            case .bridgeHorizontal, .bridgeVertical:
                newType = board.resolveBridgeType(for: pos) { $0.type == .bridgeHorizontal || $0.type == .bridgeVertical }
            default:
                newType = tile.type
            }

            board[pos] = Tile(type: newType, position: pos)
        }

        return board
    }


}
