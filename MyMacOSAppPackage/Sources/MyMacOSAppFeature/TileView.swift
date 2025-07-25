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
    let dimension: CGFloat = 32
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
            }
        case .corner:
            Path { path in
                path.move(to: .zero)
                path.addLine(to: CGPoint(x: dimension, y: 0))
                path.addLine(to: CGPoint(x: dimension, y: dimension))
                path.addArc(center: CGPoint(x: 0, y: dimension),
                            radius: dimension/1.5,
                            startAngle: .degrees(0),
                            endAngle: .degrees(270),
                            clockwise: true)
            }
        case .tJunction:
            ZStack {
                Rectangle().frame(width: dimension / 3, height: dimension)
                Rectangle().frame(width: dimension, height: dimension / 3)
            }
        case .cross:
            ZStack {
                Rectangle().frame(width: dimension / 3, height: dimension)
                Rectangle().frame(width: dimension, height: dimension / 3)
            }
        case .end:
            VStack(spacing: 0) {
                Rectangle()
                    .frame(height: dimension * 0.6)
                    .opacity(0.0)
                Rectangle().frame(width: dimension * 0.4, height: dimension * 0.4)
            }
        }
    }
}
