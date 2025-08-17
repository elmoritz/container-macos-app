//
//  NoiseKind.swift
//  MyMacOSAppFeature
//
//  Created by Moritz Ellerbrock on 17.08.25.
//


import SwiftUI
import SpriteKit
import GameplayKit
import Combine

// MARK: - Noise Types & Settings

enum NoiseKind: String, CaseIterable, Identifiable {
    case perlin, billow, ridged, voronoi, constant, cylinders, spheres, checkerboard
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .perlin:      return "Perlin"
        case .billow:      return "Billow"
        case .ridged:      return "Ridged"
        case .voronoi:     return "Voronoi"
        case .constant:    return "Constant"
        case .cylinders:   return "Cylinders"
        case .spheres:     return "Spheres"
        case .checkerboard:return "Checkerboard"
        }
    }
}

extension NoiseKind: Codable {}  // RawRepresentable over String makes this automatic

/// All tunables in one bag; different sources will show only the relevant ones.
struct NoiseSettings: Equatable, Codable {
    // Coherent base
    var frequency: Double = 1.5
    var octaveCount: Int  = 6
    var persistence: Double = 0.5
    var lacunarity: Double = 2.0
    var seed: Int32 = 0

    // Voronoi
    var displacement: Double = 1.0
    var distanceEnabled: Bool = false

    // Constant
    var value: Double = 0.0

    // Cylinders/Spheres
    var radialFrequency: Double = 1.0

    // Checkerboard
    var squareSize: Double = 1.0

    // Rendering
    var sampleCount: Int = 512       // resolution of noise map
    var seamless: Bool = false       // GKNoiseMap(seamless:)
    var zoom: Double = 1.0           // scale sprite
    var liveUpdate: Bool = true      // update on every change
    var invert: Bool = false         // optional visual tweak

    var lowColor: RGBA = .black   // “black” end
    var highColor: RGBA = .white  // “white” end
}

struct NoisePreset: Codable {
    var kind: NoiseKind
    var settings: NoiseSettings
    var paletteName: ColorPreset? = nil   // <— optional
    var exportedAt: Date = Date()
    var appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
}

// MARK: - Factory: GKNoiseSource from settings

func makeNoiseSource(kind: NoiseKind, s: NoiseSettings) -> GKNoiseSource {
    switch kind {
    case .perlin:
        return GKPerlinNoiseSource(
            frequency: s.frequency,
            octaveCount: s.octaveCount,
            persistence: s.persistence,
            lacunarity: s.lacunarity,
            seed: s.seed
        )
    case .billow:
        return GKBillowNoiseSource(
            frequency: s.frequency,
            octaveCount: s.octaveCount,
            persistence: s.persistence,
            lacunarity: s.lacunarity,
            seed: s.seed
        )
    case .ridged:
        return GKRidgedNoiseSource(
            frequency: s.frequency,
            octaveCount: s.octaveCount,
            lacunarity: s.lacunarity,
            seed: s.seed
        )
    case .voronoi:
        return GKVoronoiNoiseSource(
            frequency: s.frequency,
            displacement: s.displacement,
            distanceEnabled: s.distanceEnabled,
            seed: s.seed
        )
    case .constant:
        return GKConstantNoiseSource(value: s.value)
    case .cylinders:
        return GKCylindersNoiseSource(frequency: s.radialFrequency)
    case .spheres:
        return GKSpheresNoiseSource(frequency: s.radialFrequency)
    case .checkerboard:
        return GKCheckerboardNoiseSource(squareSize: s.squareSize)
    }
}

// MARK: - SpriteKit Scene

final class NoiseScene: SKScene {
    private let node = SKSpriteNode()
    private var currentTextureSize: CGSize = .zero

    override func didMove(to view: SKView) {
        backgroundColor = .black
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        addChild(node)
        node.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        node.position = .zero
        node.size = size
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        node.size = size
    }

    func render(kind: NoiseKind, settings s: NoiseSettings) {
        // Build noise
        let src = makeNoiseSource(kind: kind, s: s)
        let noise = GKNoise(src)

        // Map config (world size vs sample count)
        let samples = vector_int2(Int32(s.sampleCount), Int32(s.sampleCount))
        let map = GKNoiseMap(
            noise,
            size: vector_double2(1.0, 1.0),       // normalized space
            origin: vector_double2(0.0, 0.0),
            sampleCount: samples,
            seamless: s.seamless
        )

        // Convert to grayscale CGImage and then SKTexture
//        guard let cg = NoiseRenderer.makeGrayImage(from: map, inverted: s.invert) else { return }
        guard let cg = NoiseRenderer.makeGradientImage(from: map,
                                                              low: s.lowColor,
                                                              high: s.highColor,
                                                              inverted: s.invert) else { return }

        let tex = SKTexture(cgImage: cg)
        node.texture = tex
        node.size = size
        node.setScale(CGFloat(s.zoom))
    }
}

// MARK: - Noise Renderer (GKNoiseMap -> CGImage grayscale)

enum NoiseRenderer {
    static func makeGrayImage(from map: GKNoiseMap, inverted: Bool) -> CGImage? {
        let w = Int(map.sampleCount.x)
        let h = Int(map.sampleCount.y)
        var buffer = [UInt8](repeating: 0, count: w * h)

        // Fill pixel buffer (flip vertically for SpriteKit coords)
        for y in 0..<h {
            for x in 0..<w {
                let v = map.value(at: vector_int2(Int32(x), Int32(y))) // [-1, 1]
                let n = max(-1.0, min(1.0, Double(v)))
                var gray = UInt8((n * 0.5 + 0.5) * 255.0) // map to [0,255]
                if inverted { gray = 255 &- gray }
                buffer[(h - 1 - y) * w + x] = gray
            }
        }

        let cs = CGColorSpaceCreateDeviceGray()
        guard let ctx = CGContext(
            data: &buffer,
            width: w, height: h,
            bitsPerComponent: 8,
            bytesPerRow: w * MemoryLayout<UInt8>.size,
            space: cs,
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        ) else { return nil }

        return ctx.makeImage()
    }

    /// Maps noise ∈ [-1,1] to t ∈ [0,1], then lerps between low/high colors.
       static func makeGradientImage(from map: GKNoiseMap,
                                     low: RGBA,
                                     high: RGBA,
                                     inverted: Bool) -> CGImage? {
           let w = Int(map.sampleCount.x)
           let h = Int(map.sampleCount.y)
           // 4 bytes per pixel (RGBA8)
           var buffer = [UInt8](repeating: 0, count: w * h * 4)

           // Precompute deltas
           let dr = Float(high.r - low.r)
           let dg = Float(high.g - low.g)
           let db = Float(high.b - low.b)
           let da = Float(high.a - low.a)

           let lr = Float(low.r), lg = Float(low.g), lb = Float(low.b), la = Float(low.a)

           for y in 0..<h {
               for x in 0..<w {
                   let v = map.value(at: vector_int2(Int32(x), Int32(y))) // [-1,1]
                   var t = Float((Double(v) * 0.5) + 0.5)                 // [0,1]
                   if inverted { t = 1 - t }

                   let r = lr + dr * t
                   let g = lg + dg * t
                   let b = lb + db * t
                   let a = la + da * t

                   let row = (h - 1 - y) // flip vertically for SpriteKit
                   let idx = (row * w + x) * 4
                   buffer[idx + 0] = UInt8(clamping: Int(r * 255))
                   buffer[idx + 1] = UInt8(clamping: Int(g * 255))
                   buffer[idx + 2] = UInt8(clamping: Int(b * 255))
                   buffer[idx + 3] = UInt8(clamping: Int(a * 255))
               }
           }

           let cs = CGColorSpaceCreateDeviceRGB()
           guard let ctx = CGContext(
               data: &buffer,
               width: w, height: h,
               bitsPerComponent: 8,
               bytesPerRow: w * 4,
               space: cs,
               bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
           ) else { return nil }

           return ctx.makeImage()
       }
}

// MARK: - SwiftUI Control Helpers

struct LabeledSlider: View {
    let title: String
    @Binding var value: Double
    var range: ClosedRange<Double>
    var step: Double = 0.01
    var format: String = "%.2f"

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                Spacer()
                Text(String(format: format, value))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            Slider(value: $value, in: range, step: step)
        }
    }
}

struct LabeledStepper: View {
    let title: String
    @Binding var value: Int
    var range: ClosedRange<Int> = 1...12

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Stepper(value: $value, in: range) {
                Text("\(value)")
                    .monospacedDigit()
                    .frame(minWidth: 36, alignment: .trailing)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Main View

public struct NoiseDebugView: View {
    @State private var kind: NoiseKind = .perlin
    @State private var s = NoiseSettings()
    @State private var scene = NoiseScene(size: CGSize(width: 512, height: 512))
    @State private var selectedPalette: ColorPreset = .grayscale


    public init() {}

    public var body: some View {
        HStack(spacing: 0) {
            // Preview
            SpriteView(scene: scene)
                .frame(minWidth: 256, minHeight: 256)
                .aspectRatio(1.0, contentMode: .fill)
                .background(.black)
                .padding(32)
                .overlay(alignment: .topLeading) {
                    Text(kind.displayName)
                        .padding(6)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(8)
                }
                .onAppear {
                    syncPaletteFromCurrentColors()
                    render()
                }

                .onChange(of: kind) { _, _ in renderMaybeLive() }
                .onChange(of: s) { _, _ in renderMaybeLive() }

            // Controls
            Divider()
                .background(.secondary)
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Picker("Noise Type", selection: $kind) {
                        ForEach(NoiseKind.allCases) { k in
                            Text(k.displayName).tag(k)
                        }
                    }
                    .pickerStyle(.segmented)

                    Group {
                        switch kind {
                        case .perlin, .billow:
                            LabeledSlider(title: "Frequency", value: $s.frequency, range: 0.05...16, step: 0.05)
                            LabeledStepper(title: "Octaves", value: $s.octaveCount, range: 1...12)
                            LabeledSlider(title: "Persistence", value: $s.persistence, range: 0.0...1.0, step: 0.01)
                            LabeledSlider(title: "Lacunarity", value: $s.lacunarity, range: 1.1...6.0, step: 0.05)
                            seedControls
                        case .ridged:
                            LabeledSlider(title: "Frequency", value: $s.frequency, range: 0.05...8, step: 0.05)
                            LabeledStepper(title: "Octaves", value: $s.octaveCount, range: 1...12)
                            LabeledSlider(title: "Lacunarity", value: $s.lacunarity, range: 1.1...6.0, step: 0.05)
                            seedControls
                        case .voronoi:
                            LabeledSlider(title: "Frequency", value: $s.frequency, range: 0.5...32, step: 0.05)
                            LabeledSlider(title: "Displacement", value: $s.displacement, range: 0.0...4.0, step: 0.01)
                            Toggle("Distance Enabled", isOn: $s.distanceEnabled)
                            seedControls
                        case .constant:
                            LabeledSlider(title: "Value", value: $s.value, range: -1.0...1.0, step: 0.01)
                        case .cylinders:
                            LabeledSlider(title: "Radial Frequency", value: $s.radialFrequency, range: 0.05...100, step: 0.05)
                        case .spheres:
                            LabeledSlider(title: "Radial Frequency", value: $s.radialFrequency, range: 0.05...100, step: 0.05)
                        case .checkerboard:
                            LabeledSlider(title: "Square Size", value: $s.squareSize, range: 0.25...8.0, step: 0.05)
                        }
                    }

                    Divider().padding(.vertical, 4)

                    Group {
                        LabeledStepper(title: "Sample Count (px)", value: $s.sampleCount, range: 64...2048)
                        Toggle("Seamless", isOn: $s.seamless)
                        Toggle("Invert Grayscale", isOn: $s.invert)
                        LabeledSlider(title: "Zoom", value: $s.zoom, range: 0.25...4.0, step: 0.01, format: "%.2fx")
                        Toggle("Live Update", isOn: $s.liveUpdate)
                    }

                    Divider().padding(.vertical, 4)
                    Text("Palette").font(.headline)

                    Picker("Palette", selection: $selectedPalette) {
                        ForEach(ColorPreset.allCases) { p in
                            Text(p.displayName).tag(p)
                        }
                    }
                    .pickerStyle(.menu) // or .segmented if you prefer a few; menu scales better
                    .onChange(of: selectedPalette) { _, newValue in
                        applyPreset(newValue)
                    }
                    Divider().padding(.vertical, 4)
                    Text("Gradient Colors").font(.headline)
                    // Optional: a small preview strip
                    Rectangle()
                        .fill(LinearGradient(colors: [Color(s.lowColor), Color(s.highColor)],
                                             startPoint: .leading, endPoint: .trailing))
                        .frame(height: 12)
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                    HStack {
                        ColorPicker("",
                                    selection: Binding<Color>(
                                        get: { Color(s.lowColor) },
                                        set: { newColor in
                                            s.lowColor = newColor.toRGBA()
                                            selectedPalette = .custom
                                            if s.liveUpdate { render() }
                                        }
                                    ))
                        Spacer()
                        Button("Swap Colors") {
                            let tmp = s.lowColor
                            s.lowColor = s.highColor
                            s.highColor = tmp
                            if s.liveUpdate { render() }
                        }
                        Spacer()
                        ColorPicker("",
                                    selection: Binding<Color>(
                                        get: { Color(s.highColor) },
                                        set: { newColor in
                                            s.highColor = newColor.toRGBA()
                                            selectedPalette = .custom
                                            if s.liveUpdate { render() }
                                        }
                                    ))

                    }



                    HStack {
                        Button("Apply") { render() }
                            .keyboardShortcut(.return)
                        Button("Random Seed") {
                            s.seed = Int32(Int32.random(in: Int32.min ... Int32.max))
                            if s.liveUpdate { render() }
                        }.disabled(!usesSeed(kind))
                        Spacer()

                            Button("Save…") {
                                saveCurrentPreset()
                            }

                        Button(role: .destructive) {
                            resetControls(for: kind)
                            if s.liveUpdate { render() }
                        } label: { Text("Reset") }
                    }
                }
                .padding(16)
            }
            .background(.gray.opacity(0.5))
            .frame(minWidth: 320)
        }
        .background(.black)
    }

    private var seedControls: some View {
        HStack {
            Text("Seed")
            Spacer()
            TextField("Seed", value: $s.seed, format: .number)
                .textFieldStyle(.roundedBorder)
                .frame(width: 120)
            Button("🎲") {
                s.seed = Int32(Int32.random(in: Int32.min...Int32.max))
                if s.liveUpdate { render() }
            }
            .help("Randomize Seed")
        }
    }

    private func renderMaybeLive() {
        if s.liveUpdate { render() }
    }

    private func render() {
        scene.render(kind: kind, settings: s)
    }

    private func usesSeed(_ k: NoiseKind) -> Bool {
        switch k {
        case .perlin, .billow, .ridged, .voronoi: return true
        default: return false
        }
    }

    // MARK: - Saving

    private func saveCurrentPreset() {
        var preset = NoisePreset(kind: kind, settings: s)
        preset.paletteName = selectedPalette == .custom ? nil : selectedPalette
        do {
            let data = try encodePresetToJSON(preset)
            presentSavePanelAndWrite(data: data,
                                     suggestedName: suggestedFilename(for: preset))
        } catch {
            NSLog("Failed to encode preset: \(error.localizedDescription)")
        }
    }


    private func encodePresetToJSON(_ preset: NoisePreset) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(preset)
    }

    private func suggestedFilename(for preset: NoisePreset) -> String {
        // Example: "Perlin-2025-08-17T14-05-00.json"
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH-mm-ss"
        let stamp = df.string(from: preset.exportedAt)
        return "\(preset.kind.displayName)-\(stamp).json"
    }

    /// Presents an NSSavePanel and writes the provided data if the user confirms.
    private func presentSavePanelAndWrite(data: Data, suggestedName: String) {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.canCreateDirectories = true
        panel.isExtensionHidden = false
        panel.nameFieldStringValue = suggestedName

        // You can use runModal() for simplicity in a tool/debugger window:
        let response = panel.runModal()
        guard response == .OK, let url = panel.url else { return }

        do {
            try data.write(to: url, options: .atomic)
        } catch {
            NSLog("Failed to write file: \(error.localizedDescription)")
        }
    }

    // MARK: - Reset

    private func resetControls(for k: NoiseKind) {
        var d = NoiseSettings()
        // keep some globals
        d.sampleCount = s.sampleCount
        d.seamless = s.seamless
        d.zoom = s.zoom
        d.liveUpdate = s.liveUpdate
        d.invert = s.invert

        switch k {
        case .perlin:
            d.frequency = 1.5; d.octaveCount = 6; d.persistence = 0.5; d.lacunarity = 2.0
        case .billow:
            d.frequency = 1.5; d.octaveCount = 6; d.persistence = 0.5; d.lacunarity = 2.0
        case .ridged:
            d.frequency = 1.5; d.octaveCount = 6; d.lacunarity = 2.0
        case .voronoi:
            d.frequency = 1.0; d.displacement = 1.0; d.distanceEnabled = false
        case .constant:
            d.value = 0.0
        case .cylinders, .spheres:
            d.radialFrequency = 1.0
        case .checkerboard:
            d.squareSize = 1.0
        }
        s = d
    }

    // MARK: - Color Preset
    private func applyPreset(_ preset: ColorPreset) {
        guard preset != .custom else { return }
        let pair = preset.colors
        s.lowColor = pair.low
        s.highColor = pair.high
        selectedPalette = preset
        if s.liveUpdate { render() }
    }

    private func syncPaletteFromCurrentColors() {
        if let match = ColorPreset.allCases.first(where: {
            $0 != .custom && $0.matches(low: s.lowColor, high: s.highColor)
        }) {
            selectedPalette = match
        } else {
            selectedPalette = .custom
        }
    }

}
