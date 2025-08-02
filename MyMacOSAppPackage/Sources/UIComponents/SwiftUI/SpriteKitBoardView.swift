//
//  SpriteKitBoardView.swift
//  MyMacOSAppFeature
//
//  Created by Moritz Ellerbrock on 30.07.25.
//


import SwiftUI
import SpriteKit
import GameEngine

public struct SpriteKitBoardView: View {
    let board: Board

    public init(board: Board) {
        self.board = board
    }

    public var scene: SKScene {
        let scene = BoardScene(board: board, size: CGSize(width: 1024, height: 768))

        return scene
    }

    public var body: some View {
        SpriteView(scene: scene)
    }
}
