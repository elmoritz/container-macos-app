//
//  Position.swift
//  MyMacOSAppFeature
//
//  Created by Moritz Ellerbrock on 25.07.25.
//


import Foundation
import SwiftUI


public enum Factory {
    public static func generateFlatBoard(width: Int, height: Int) -> Board {
        var board: Dictionary<Position, Tile> = [:]
        for y in 0..<height {
            for x in 0..<width {
                let pos = Position(x: x, y: y)
                board[pos] = Tile(type: .flat)
            }
        }
        return Board(fullBoard: board)
    }

    public static func generateSeededBoard(width: Int, height: Int, seed: UInt64) -> Board {
        var rng = SeededGenerator(seed: seed)
        var board: Dictionary<Position, Tile> = [:]

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

                board[pos] = Tile(type: typeCategory)
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

            board[pos] = Tile(type: newType)
        }

        return Board(fullBoard: board)
    }

    public static func generateImprovedSeededBoard(width: Int, height: Int, seed: UInt64) -> Board {
        var rng = SeededGenerator(seed: seed)
        var board: Dictionary<Position, Tile> = [:]

        let mapArea = width * height
        let regionCount = max(2, min(5, mapArea / 4096)) // 2–5 regions

        let overlayByRegion: [Int: TileType] = [
            0: .overlayPattern,
            1: .overlayStains,
            2: .overlayCracks,
            3: .overlayShadow,
            4: .overlayGrass
        ]

        // Step 1: Region centers
        let regionCenters: [Position] = (0..<regionCount).map { _ in
            Position(x: Int(rng.next() % UInt64(width)), y: Int(rng.next() % UInt64(height)))
        }

        // Step 2: Assign region
        var regionMap: [Position: Int] = [:]
        for y in 0..<height {
            for x in 0..<width {
                let pos = Position(x: x, y: y)
                let closest = regionCenters.enumerated().min(by: {
                    distance(pos, $0.element) < distance(pos, $1.element)
                })!.offset
                regionMap[pos] = closest
            }
        }

        // Step 3: Region tile types
        let regionThemes: [[TileType]] = (0..<regionCount).map { _ in
            switch rng.next() % 4 {
            case 0: return [.flat, .overlayGrass]
            case 1: return [.waterShallow]
            case 2: return [.roadStraightHorizontal, .roadStraightVertical]
            default: return [.flat] // fallback
            }
        }

        // Step 4: Fill with region tiles and overlay color
        for y in 0..<height {
            for x in 0..<width {
                let pos = Position(x: x, y: y)
                let region = regionMap[pos]!
                let theme = regionThemes[region]
                let type = theme[Int(rng.next() % UInt64(theme.count))]
                let overlay = overlayByRegion[region]
                board[pos] = Tile(type: type, overlays: overlay.map { [$0] } ?? [])
            }
        }

        // Step 5: Add walls along region boundaries
        var wallPositions: Set<Position> = []
        for y in 1..<height-1 {
            for x in 1..<width-1 {
                let pos = Position(x: x, y: y)
                guard let currentRegion = regionMap[pos] else { continue }
                let neighbors = Direction.allCases.map {
                    Position(x: pos.x + $0.offset.dx, y: pos.y + $0.offset.dy)
                }

                if neighbors.contains(where: { regionMap[$0] != currentRegion }) {
                    wallPositions.insert(pos)
                    for neighbor in neighbors {
                        if regionMap[neighbor] != currentRegion {
                            wallPositions.insert(neighbor)
                        }
                    }
                }
            }
        }

        // Place wallCrossroad at collected wall positions
        for pos in wallPositions {
            board[pos] = Tile(type: .wallCrossroad)
        }

        // Step 6: Resolve tile type shapes
        for (pos, tile) in board {
            let newType: TileType
            switch tile.type {
            case .roadStraightHorizontal, .roadStraightVertical:
                newType = board.resolveRoadType(for: pos) { $0.type.rawValue.starts(with: "road") }
            case .wallCrossroad, .wallStraightHorizontal, .wallStraightVertical:
                newType = board.resolveWallType(for: pos) { $0.type.rawValue.starts(with: "wall") }
            case .waterShallow:
                newType = board.resolveWaterType(for: pos) { $0.type == .waterShallow }
            default:
                newType = tile.type
            }

            board[pos] = Tile(type: newType)
        }

        return Board(fullBoard: board)
    }

    public static func generateNoiseSeededBoard(width: Int, height: Int, seed: UInt64) -> Board {
        let noise = SimpleNoise(seed: seed)
        var board: Dictionary<Position, Tile> = [:]

        // Step 1: Use noise to classify general terrain
        for y in 0..<height {
            for x in 0..<width {
                let pos = Position(x: x, y: y)
                let value = noise.value(atX: x, y: y)

                let typeCategory: TileType
                switch value {
                case ..<0.3:
                    typeCategory = .waterShallow
                case ..<0.45:
                    typeCategory = .wallStraightVertical
                case ..<0.6:
                    typeCategory = .roadStraightHorizontal
                default:
                    typeCategory = .flat
                }

                board[pos] = Tile(type: typeCategory)
            }
        }

        // Step 2: Auto-tile using bitmask rules
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

            board[pos] = Tile(type: newType)
        }

        return Board(fullBoard: board)
    }

    private static func distance(_ a: Position, _ b: Position) -> Int {
        abs(a.x - b.x) + abs(a.y - b.y)
    }
}


