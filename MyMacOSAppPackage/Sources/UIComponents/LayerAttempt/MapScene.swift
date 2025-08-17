
//
//  MapScene.swift
//  MyMacOSAppFeature
//
//  Created by Moritz Ellerbrock on 11.08.25.
//


import SpriteKit
import GameplayKit
import Combine
final class MapScene: SKScene {
    private static let fallBackSeed: Int32 = 1234567890
    private let cols: Int
    private let rows: Int
    private let tileSize: CGSize
    private weak var state: WorldState?

    private var baseLayer: SKTileMapNode!
    private var featureLayer: SKTileMapNode!
    private var propsLayer: SKNode!
    private let cam = SKCameraNode()

    private var bindings: Set<AnyCancellable> = []

    // Simple tile sets (replace with your own atlas/tilesets)
    private lazy var baseTileSet: SKTileSet = SKTileSet(tileGroups: [
        makeSolidGroup(name: BaseType.water.rawValue, color: .systemBlue),
        makeSolidGroup(name: BaseType.ground.rawValue, color: .systemGreen),
        makeSolidGroup(name: BaseType.sand.rawValue, color: .systemYellow)
    ])

    private lazy var featureTileSet: SKTileSet = SKTileSet(tileGroups: [
        makeSolidGroup(name: FeatureType.forest.rawValue, color: .green.withAlphaComponent(0.7)),
        makeSolidGroup(name: FeatureType.mountain.rawValue, color: .gray),
        makeSolidGroup(name: FeatureType.lake.rawValue, color: .blue.withAlphaComponent(0.8))
    ])

    init(size: CGSize, cols: Int, rows: Int, tileSize: CGSize, state: WorldState) {
        self.cols = cols
        self.rows = rows
        self.tileSize = tileSize
        self.state = state
        super.init(size: size)
        scaleMode = .resizeFill
    }

    required init?(coder: NSCoder) { fatalError() }

    override func didMove(to view: SKView) {
        camera = cam
        addChild(cam)
        view.allowsTransparency = false
        view.ignoresSiblingOrder = true
        view.preferredFramesPerSecond = 120
        view.showsFPS = true
        view.showsNodeCount = true
        view.window?.acceptsMouseMovedEvents = true

        buildLayers()
        centerCamera()
    }

    private func buildLayers() {
        // 1) Base noise → Water / Ground / Sand
        let base = generateBaseMap(cols: cols, rows: rows, with: state?.seed)

        baseLayer = SKTileMapNode(tileSet: baseTileSet, columns: cols, rows: rows, tileSize: tileSize)
        baseLayer.name = "Base"
        stamp(base, into: baseLayer)
        addChild(baseLayer)

        // 2) Features noise → Forest / Mountain / Lake
        let features = generateFeatureMap(cols: cols, rows: rows, base: base, with: state?.seed)
        featureLayer = SKTileMapNode(tileSet: featureTileSet, columns: cols, rows: rows, tileSize: tileSize)
        featureLayer.name = "Features"
        stamp(features, into: featureLayer)
        addChild(featureLayer)

        // 3) Props (trees/rocks) as loose nodes, avoid water
        propsLayer = SKNode(); propsLayer.name = "Props"
        populateProps(base: base, on: propsLayer)
        addChild(propsLayer)

        // Bind visibility to state
        state?.$showsBase.sink { [weak self] on in self?.baseLayer.isHidden = !on }.store(in: &bindings)
        state?.$showsFeatures.sink { [weak self] on in self?.featureLayer.isHidden = !on }.store(in: &bindings)
        state?.$showsProps.sink { [weak self] on in self?.propsLayer.isHidden = !on }.store(in: &bindings)
        state?.$scale.sink { [weak self] scale in
                self?.cam.xScale = scale
                self?.cam.yScale = scale
            }
            .store(in: &bindings)
    }

    // MARK: Generation — super simple GKNoise thresholds

    enum BaseType: String { case water, ground, sand }
    enum FeatureType: String { case none, forest, mountain, lake }

    private func generateBaseMap(cols: Int, rows: Int, with seed: Int32?) -> [[BaseType]] {
        let noise = GKNoise(GKPerlinNoiseSource(frequency: 0.015,
                                                octaveCount: 5,
                                                persistence: 0.55,
                                                lacunarity: 2.0,
                                                seed: seed ?? Self.fallBackSeed))
        var map = Array(repeating: Array(repeating: BaseType.ground, count: rows), count: cols)
        for c in 0..<cols {
            for r in 0..<rows {
                let v = noise.value(atPosition: vector_float2(Float(c), Float(r))) // ~[-1,1]
                switch v {
                    case ..<(-0.15): map[c][r] = .water
                    case 0.15...:    map[c][r] = .ground
                    default:         map[c][r] = .sand
                }
            }
        }
        return map
    }

    private func generateFeatureMap(cols: Int, rows: Int, base: [[BaseType]], with seed: Int32?) -> [[FeatureType]] {
        let n1 = GKNoise(GKPerlinNoiseSource(frequency: 0.03,
                                             octaveCount: 3,
                                             persistence: 0.45,
                                             lacunarity: 2.0,
                                             seed: seed ?? Self.fallBackSeed))
        let n2 = GKNoise(GKBillowNoiseSource(frequency: 0.02,
                                             octaveCount: 3,
                                             persistence: 0.5,
                                             lacunarity: 2.1,
                                             seed: seed ?? Self.fallBackSeed))
        var map = Array(repeating: Array(repeating: FeatureType.none, count: rows), count: cols)
        for c in 0..<cols {
            for r in 0..<rows {
                if base[c][r] == .water { continue } // lakes will override intentionally
                let v1 = n1.value(atPosition: vector_float2(Float(c), Float(r)))
                let v2 = n2.value(atPosition: vector_float2(Float(c), Float(r)))

                if v2 > 0.45 { map[c][r] = .mountain }
                else if v1 > 0.25 { map[c][r] = .forest }
                else { map[c][r] = .none }
            }
        }
        // sprinkle lakes in ground/sand pockets
        for _ in 0..<(cols*rows/600) {
            let c = Int.random(in: 2..<(cols-2))
            let r = Int.random(in: 2..<(rows-2))
            if base[c][r] != .water {
                for i in (c-1)...(c+1) { for j in (r-1)...(r+1) { map[i][j] = .lake } }
            }
        }
        return map
    }

    // MARK: Stamping helpers

    private func stamp(_ base: [[BaseType]], into tilemap: SKTileMapNode) {
        for c in 0..<cols { for r in 0..<rows {
            let groupName: String = base[c][r].rawValue
            if let g = baseTileSet.tileGroups.first(where: { $0.name == groupName }) {
                tilemap.setTileGroup(g, forColumn: c, row: r)
            }
        }}
    }

    private func stamp(_ features: [[FeatureType]], into tilemap: SKTileMapNode) {
        for c in 0..<cols { for r in 0..<rows {
            let groupName: String? = features[c][r].rawValue
            if let name = groupName, let g = featureTileSet.tileGroups.first(where: { $0.name == name }) {
                tilemap.setTileGroup(g, forColumn: c, row: r)
            }
        }}
    }

    private func populateProps(base: [[BaseType]], on node: SKNode) {
        // trees on ground/forest, rocks on mountain edges — super light pass
//        for c in stride(from: 0, to: cols, by: 3) {
//            for r in stride(from: 0, to: rows, by: 3) {
//                guard base[c][r] != .water, Double.random(in: 0...1) < 0.15 else { continue }
//                let tree = SKShapeNode(circleOfRadius: min(tileSize.width, tileSize.height) * 0.25)
//                tree.fillColor = .init(red: 0.0, green: 0.5, blue: 0.2, alpha: 1)
//                tree.strokeColor = .clear
//                tree.position = positionFor(col: c, row: r)
//                node.addChild(tree)
//            }
//        }
    }

    // MARK: Camera & input

    private func centerCamera() {
        cam.position = CGPoint(x: CGFloat(cols / 4) * tileSize.width,
                               y: CGFloat(rows / 4) * tileSize.height)
    }

    override func scrollWheel(with event: NSEvent) {
        let dz = -event.scrollingDeltaY * 0.001
        cam.setScale(max(0.2, min(4.0, cam.xScale + dz)))
        cam.yScale = cam.xScale
    }

    private var lastDrag: CGPoint?
    override func mouseDown(with event: NSEvent) { lastDrag = event.location(in: self) }
    override func mouseDragged(with event: NSEvent) {
        guard let last = lastDrag else { return }
        let p = event.location(in: self)
        cam.position.x -= (p.x - last.x)
        cam.position.y -= (p.y - last.y)
        lastDrag = p
    }
    override func mouseUp(with event: NSEvent) { lastDrag = nil }

    override func mouseMoved(with event: NSEvent) {
        let p = event.location(in: baseLayer)
        let col = Int(floor(p.x / tileSize.width))
        let row = Int(floor(p.y / tileSize.height))
        guard (0..<cols).contains(col), (0..<rows).contains(row) else {
            state?.hover = nil; return
        }

        // Probe topmost layer first
        let hitFeature = featureLayer.tileGroup(atColumn: col, row: row)?.name
        let hitBase = baseLayer.tileGroup(atColumn: col, row: row)?.name
        let (layer, name) = hitFeature != nil ? ("Features", hitFeature) : ("Base", hitBase)

        state?.hover = .init(col: col, row: row, layerName: layer, tileGroupName: name)
    }


    // MARK: Utilities

    private func makeSolidGroup(name: String, color: NSColor) -> SKTileGroup {
        let def = SKTileDefinition(texture: SKTexture(image: solidImage(color: color)))
        def.name = name
        let rule = SKTileGroupRule(adjacency: .adjacencyAll, tileDefinitions: [def])
        let group = SKTileGroup(rules: [rule]); group.name = name
        return group
    }

    private func solidImage(color: NSColor, size: CGSize = .init(width: 32, height: 32)) -> NSImage {
        let img = NSImage(size: size); img.lockFocus()
        color.setFill(); NSBezierPath(rect: .init(origin: .zero, size: size)).fill()
        img.unlockFocus(); return img
    }

    private func positionFor(col: Int, row: Int) -> CGPoint {
        CGPoint(x: (CGFloat(col) + 0.5) * tileSize.width,
                y: (CGFloat(row) + 0.5) * tileSize.height)
    }
}
