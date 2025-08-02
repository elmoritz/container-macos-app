//
//  BoardScene.swift
//  MyMacOSAppFeature
//
//  Created by Moritz Ellerbrock on 30.07.25.
//


import SpriteKit
import GameEngine

final class BoardScene: SKScene {
    let board: Board
    let tileSize: CGFloat = 32

    // Camera
    let cameraNode = SKCameraNode()
    private var isDragging = false
    private var lastMousePosition: CGPoint?

    init(board: Board, size: CGSize) {
        self.board = board
        super.init(size: size)
        self.anchorPoint = CGPoint(x: 0, y: 0)

        renderBoard()

        // Camera setup
        camera = cameraNode
        addChild(cameraNode)
        cameraNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        cameraNode.setScale(1.0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func renderBoard() {
        for (position, tile) in board.map {
            let tileNode = TileNode(tile: tile, size: tileSize)
            tileNode.position = CGPoint(x: CGFloat(position.x) * tileSize,
                                        y: CGFloat(position.y) * tileSize)
            addChild(tileNode)
        }
    }

    // MARK: - Mouse Controls for Pan

    override func mouseDown(with event: NSEvent) {
        isDragging = true
        lastMousePosition = event.location(in: self)
    }

    override func mouseDragged(with event: NSEvent) {
        guard isDragging, let lastPosition = lastMousePosition else { return }

        let currentPosition = event.location(in: self)
        let delta = CGPoint(x: currentPosition.x - lastPosition.x,
                            y: currentPosition.y - lastPosition.y)

        cameraNode.position.x -= delta.x
        cameraNode.position.y -= delta.y

        lastMousePosition = currentPosition
    }

    override func mouseUp(with event: NSEvent) {
        isDragging = false
        lastMousePosition = nil
    }

    // MARK: - Scroll Wheel for Zoom

    override func scrollWheel(with event: NSEvent) {
        let zoomSpeed: CGFloat = 0.1
        let newScale = clamp(cameraNode.xScale - (event.deltaY * zoomSpeed / 10),
                             min: 0.5,
                             max: 4.0)
        cameraNode.setScale(newScale)
    }

    private func clamp(_ value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        Swift.max(min, Swift.min(max, value))
    }
}
