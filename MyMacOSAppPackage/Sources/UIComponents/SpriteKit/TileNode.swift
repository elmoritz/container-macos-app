//
//  TileNode.swift
//  MyMacOSAppFeature
//
//  Created by Moritz Ellerbrock on 30.07.25.
//

import SpriteKit
import GameEngine
import Foundation
import SwiftUI

final class TileNode: SKNode {
    let tile: Tile
    let size: CGFloat

    init(tile: Tile, size: CGFloat = 32) {
        self.tile = tile
        self.size = size
        super.init()

        render()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func render() {
        let style = tile.type.visualStyle(for: .gray)

        let shape: SKShapeNode

        switch style.shape {
        case .square:
            shape = SKShapeNode(rectOf: CGSize(width: size, height: size))
        case .straight:
            shape = SKShapeNode(rectOf: CGSize(width: size, height: size / 3))
        case .corner:
            shape = SKShapeNode(path: CGPath(ellipseIn: CGRect(x: -size/2, y: -size/2, width: size, height: size), transform: nil))
        default:
            shape = SKShapeNode(rectOf: CGSize(width: size, height: size))
        }

        shape.fillColor = style.baseColor.uiColor()
        shape.strokeColor = .clear
        shape.zRotation = CGFloat(style.rotation) * .pi / 180

        addChild(shape)
    }
}

extension Color {
    func uiColor() -> NSColor {
        let resolved = self.resolve(in: .init())
        return NSColor(
            calibratedRed: CGFloat(resolved.linearRed),
            green: CGFloat(resolved.linearGreen),
            blue: CGFloat(resolved.linearBlue),
            alpha: CGFloat(1.0 - resolved.opacity)
        )
    }
}
