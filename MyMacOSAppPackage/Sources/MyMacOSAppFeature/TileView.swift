//
//  TileView.swift
//  MyMacOSAppFeature
//
//  Created by Moritz Ellerbrock on 25.07.25.
//

import SwiftUI
import GameEngine

struct TileView: View {
    let tile: Tile
    var dimension: CGFloat = 32
    let onHoverTile: ((Tile?) -> Void)? // ⬅️ New callback
    @State private var isHovered: Bool = false
    @State private var isSelected: Bool = false

    var body: some View {
        let style = tile.type.visualStyle(for: .gray)

        ZStack {
            baseShape(for: style.shape)
                .foregroundStyle(style.baseColor)
                .rotationEffect(.degrees(Double(style.rotation)))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(isSelected ? Color.blue : (isHovered ? Color.yellow : Color.clear), lineWidth: 2)
                )
        }
        .frame(width: dimension, height: dimension)
        .onTapGesture {
            isSelected.toggle()
        }
        .onHover { hovering in
            isHovered = hovering
            onHoverTile?(hovering ? tile : nil) // ⬅️ Inform parent
        }
    }

    @ViewBuilder
    private func baseShape(for shape: TileShape) -> some View {
        switch shape {
            case .square:
                Rectangle()
            case .straight:
                VStack {
                    Spacer()
                    Rectangle().frame(height: dimension / 3)
                    Spacer()
                }.compositingGroup()
            case .corner:
                ZStack {
                    VStack(spacing: 0) {
                        Rectangle().frame(width: dimension / 3, height: dimension / 2.9)
                        Rectangle().frame(width: dimension, height: dimension / 3 * 2).opacity(0.0)
                    }
                    corner
                    HStack(spacing: 0) {
                        Rectangle().frame(width: dimension / 2.9, height: dimension / 3)
                        Rectangle().frame(width: dimension / 3 * 2, height: dimension / 3).opacity(0.0)
                    }
                }.compositingGroup()
            case .tJunction:
                VStack(spacing: 0) {
                    Rectangle().frame(width: dimension, height: dimension / 3).opacity(0.0)
                    Rectangle().frame(width: dimension, height: dimension / 3)
                    Rectangle().frame(width: dimension / 3, height: dimension / 3)
                }.compositingGroup()
            case .cross:
                ZStack {
                    Rectangle().frame(width: dimension / 3, height: dimension)
                    Rectangle().frame(width: dimension, height: dimension / 3)
                }.compositingGroup()
            case .end:
                VStack(spacing: 0) {
                    Rectangle().frame(width: dimension, height: dimension / 2).opacity(0.0)
                    Rectangle().frame(width: dimension / 3, height: dimension / 2)
                }.compositingGroup()
        }
    }

    var corner: some View {
        Path { path in
            let point0 = Calculator.calculate(x: 1, y: 1, in: dimension)
            path.move(to: point0)
            path.addArc(center: point0,
                        radius: dimension / 3,
                        startAngle: .degrees(0),
                        endAngle: .degrees(90),
                        clockwise: false)
        }
    }
}

enum Calculator {
    struct Position {
        let x: Int
        let y: Int

        init(x: Int, y: Int) {
            self.x = min(max(0, x), 3)
            self.y = min(max(0, y), 3)
        }
    }

    static func calculate(x: Int, y: Int, in dimension: CGFloat) -> CGPoint {
        return calculate(.init(x: x, y: y), in: dimension)
    }

    static func calculate(_ position: Position, in dimension: CGFloat) -> CGPoint {
        switch (position.x, position.y) {
            case (0, 0): return .zero
            case (1, 0): return CGPoint(x: dimension / 3, y: 0)
            case (2, 0): return CGPoint(x: dimension / 3 * 2, y: 0)
            case (3, 0): return CGPoint(x: dimension, y: 0)

            case (0, 1): return CGPoint(x: dimension / 3, y: dimension / 3)
            case (1, 1): return CGPoint(x: dimension / 3, y: dimension / 3)
            case (2, 1): return CGPoint(x: dimension / 3 * 2, y: dimension / 3)
            case (3, 1): return CGPoint(x: dimension, y: dimension / 3)

            case (0, 2): return CGPoint(x: dimension / 3, y: dimension / 3 * 2)
            case (1, 2): return CGPoint(x: dimension / 3, y: dimension / 3 * 2)
            case (2, 2): return CGPoint(x: dimension / 3 * 2, y: dimension / 3 * 2)
            case (3, 2): return CGPoint(x: dimension, y: dimension / 3 * 2)

            case (0, 3): return CGPoint(x: dimension / 3, y: dimension)
            case (1, 3): return CGPoint(x: dimension / 3, y: dimension)
            case (2, 3): return CGPoint(x: dimension / 3 * 2, y: dimension)
            case (3, 3): return CGPoint(x: dimension, y: dimension)

            default: return .zero
        }
    }
}

#Preview {
    TileView(
        tile: .init(
            type: .roadCornerTL,
            position: .init(
                x: 0,
                y: 0
            )
        ),
        dimension: 128,
        onHoverTile: {
            _ in
        })
    .border(Color.yellow)
    .padding()
}
