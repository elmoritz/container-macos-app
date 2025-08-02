//
//  TileType.swift
//  MyMacOSAppFeature
//
//  Created by Moritz Ellerbrock on 27.07.25.
//

import SwiftUI

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
            return TileVisualStyle(baseColor: baseColor, shape: .tJunction, rotation: 180, overlayColors: overlayColors)
        case .roadTJunctionRight, .wallTJunctionRight:
            return TileVisualStyle(baseColor: baseColor, shape: .tJunction, rotation: 270, overlayColors: overlayColors)
        case .roadTJunctionDown, .wallTJunctionDown:
            return TileVisualStyle(baseColor: baseColor, shape: .tJunction, rotation: 0, overlayColors: overlayColors)
        case .roadTJunctionLeft, .wallTJunctionLeft:
            return TileVisualStyle(baseColor: baseColor, shape: .tJunction, rotation: 90, overlayColors: overlayColors)
        case .roadCrossroad, .wallCrossroad:
            return TileVisualStyle(baseColor: baseColor, shape: .cross, rotation: 0, overlayColors: overlayColors)
        case .roadDeadEndUp, .wallDeadEndUp:
            return TileVisualStyle(baseColor: baseColor, shape: .end, rotation: 180, overlayColors: overlayColors)
        case .roadDeadEndRight, .wallDeadEndRight:
            return TileVisualStyle(baseColor: baseColor, shape: .end, rotation: 270, overlayColors: overlayColors)
        case .roadDeadEndDown, .wallDeadEndDown:
            return TileVisualStyle(baseColor: baseColor, shape: .end, rotation: 0, overlayColors: overlayColors)
        case .roadDeadEndLeft, .wallDeadEndLeft:
            return TileVisualStyle(baseColor: baseColor, shape: .end, rotation: 90, overlayColors: overlayColors)
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
