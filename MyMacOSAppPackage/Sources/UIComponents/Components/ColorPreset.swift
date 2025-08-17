//
//  ColorPreset.swift
//  MyMacOSAppFeature
//
//  Created by Moritz Ellerbrock on 17.08.25.
//


// MARK: - Two-color palette presets

enum ColorPreset: String, CaseIterable, Identifiable, Codable {
    case custom
    case grayscale
    case terrain
    case ocean
    case heatmap
    case lava
    case tundra
    case desert
    case forest
    case candy

    var id: String { rawValue }

    var displayName: String {
        switch self {
            case .custom:    return rawValue.localizedCapitalized
            case .grayscale: return rawValue.localizedCapitalized
            case .terrain:   return rawValue.localizedCapitalized
            case .ocean:     return rawValue.localizedCapitalized
            case .heatmap:   return rawValue.localizedCapitalized
            case .lava:      return rawValue.localizedCapitalized
            case .tundra:    return rawValue.localizedCapitalized
            case .desert:    return rawValue.localizedCapitalized
            case .forest:    return rawValue.localizedCapitalized
            case .candy:     return rawValue.localizedCapitalized
        }
    }

    /// Low/High color pair (as RGBA 0...1)
    var colors: (low: RGBA, high: RGBA) {
        switch self {
        case .custom:
            return (.black, .white)
        case .grayscale:
            return (.black, .white)
        case .terrain:
            // dark earth -> light grass
            return (RGBA(r: 0.12, g: 0.10, b: 0.08, a: 1),
                    RGBA(r: 0.72, g: 0.86, b: 0.48, a: 1))
        case .ocean:
            // deep blue -> aqua
            return (RGBA(r: 0.02, g: 0.10, b: 0.30, a: 1),
                    RGBA(r: 0.40, g: 0.90, b: 1.00, a: 1))
        case .heatmap:
            // dark purple -> yellow-white
            return (RGBA(r: 0.10, g: 0.00, b: 0.20, a: 1),
                    RGBA(r: 1.00, g: 0.95, b: 0.40, a: 1))
        case .lava:
            // charcoal -> hot orange
            return (RGBA(r: 0.06, g: 0.06, b: 0.06, a: 1),
                    RGBA(r: 1.00, g: 0.45, b: 0.10, a: 1))
        case .tundra:
            // blue-gray -> icy white
            return (RGBA(r: 0.12, g: 0.20, b: 0.28, a: 1),
                    RGBA(r: 0.90, g: 0.96, b: 1.00, a: 1))
        case .desert:
            // brown -> sand
            return (RGBA(r: 0.35, g: 0.24, b: 0.14, a: 1),
                    RGBA(r: 0.95, g: 0.84, b: 0.60, a: 1))
        case .forest:
            // deep green -> bright moss
            return (RGBA(r: 0.04, g: 0.18, b: 0.10, a: 1),
                    RGBA(r: 0.62, g: 0.90, b: 0.50, a: 1))
        case .candy:
            // violet -> pink
            return (RGBA(r: 0.40, g: 0.20, b: 0.70, a: 1),
                    RGBA(r: 1.00, g: 0.60, b: 0.85, a: 1))
        }
    }

    /// Helper for detecting if current colors match this preset (within a small tolerance).
    func matches(low: RGBA, high: RGBA, epsilon: Double = 0.002) -> Bool {
        func close(_ a: Double, _ b: Double) -> Bool { abs(a - b) <= epsilon }
        let p = colors
        return close(low.r, p.low.r) && close(low.g, p.low.g) && close(low.b, p.low.b) && close(low.a, p.low.a)
            && close(high.r, p.high.r) && close(high.g, p.high.g) && close(high.b, p.high.b) && close(high.a, p.high.a)
    }
}
