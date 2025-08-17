//
//  RGBA.swift
//  MyMacOSAppFeature
//
//  Created by Moritz Ellerbrock on 17.08.25.
//


import SwiftUI
import SpriteKit
import GameplayKit

// MARK: - Codable RGBA (0...1)
struct RGBA: Codable, Equatable {
    var r: Double
    var g: Double
    var b: Double
    var a: Double

    static let black = RGBA(r: 0, g: 0, b: 0, a: 1)
    static let white = RGBA(r: 1, g: 1, b: 1, a: 1)
}

extension Color {
    init(_ rgba: RGBA) {
        self = Color(.sRGB, red: rgba.r, green: rgba.g, blue: rgba.b, opacity: rgba.a)
    }
    func toRGBA() -> RGBA {
        // Resolve to sRGB
        #if os(macOS)
        let ns = NSColor(self)
            .usingColorSpace(.sRGB) ?? NSColor(srgbRed: 1, green: 1, blue: 1, alpha: 1)
        return RGBA(r: Double(ns.redComponent),
                    g: Double(ns.greenComponent),
                    b: Double(ns.blueComponent),
                    a: Double(ns.alphaComponent))
        #else
        // iOS/tvOS/watchOS path if you ever port it
        var r: CGFloat = 1, g: CGFloat = 1, b: CGFloat = 1, a: CGFloat = 1
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
        return RGBA(r: Double(r), g: Double(g), b: Double(b), a: Double(a))
        #endif
    }
}
