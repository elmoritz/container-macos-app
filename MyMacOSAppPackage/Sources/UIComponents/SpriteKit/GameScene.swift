//
//  GameScene.swift
//  MyMacOSAppFeature
//
//  Created by Moritz Ellerbrock on 09.08.25.
//


import SpriteKit
import GameplayKit

final class GameScene: SKScene {
    // Tune these to taste
    private let columns = 256
    private let rows = 256
    private let tileSize = CGSize(width: 16, height: 16)
    private let seed: Int32 = 1337

    override func didMove(to view: SKView) {
        backgroundColor = .black

        let tileSet = makeSimpleColorTileSet()           // 4 basic colored tiles
        let tileMap = SKTileMapNode(tileSet: tileSet,
                                    columns: columns,
                                    rows: rows,
                                    tileSize: tileSize)

        // Generate noise (Perlin here; try Billow or Ridged for different looks)
        let perlin = GKPerlinNoiseSource(frequency: 1.2,
                                         octaveCount: 6,
                                         persistence: 0.5,
                                         lacunarity: 2.0,
                                         seed: seed)
        let noise = GKNoise(perlin)

        let controlPoints: [NSNumber: NSNumber] = [
            NSNumber(value: 0.00): NSNumber(value: 0.05),
            NSNumber(value: 0.35): NSNumber(value: 0.25),
            NSNumber(value: 0.55): NSNumber(value: 0.65),
            NSNumber(value: 1.00): NSNumber(value: 1.00),
        ]
        // Scale noise so one “feature” spans multiple tiles
        noise.remapValues(toCurveWithControlPoints: controlPoints)
        let noiseMap = GKNoiseMap(noise,
                                  size: vector_double2(8.0, 8.0),  // “zoom” of the noise
                                  origin: vector_double2(0, 0),
                                  sampleCount: vector_int2(Int32(columns), Int32(rows)),
                                  seamless: false)

        // Map noise values to tile groups (biomes / terrain)
        let water  = tileSet.tileGroups.first { $0.name == "water" }!
        let sand   = tileSet.tileGroups.first { $0.name == "sand" }!
        let grass  = tileSet.tileGroups.first { $0.name == "grass" }!
        let rock   = tileSet.tileGroups.first { $0.name == "rock" }!

        for y in 0..<rows {
            for x in 0..<columns {
                let v = noiseMap.value(at: vector_int2(Int32(x), Int32(y))) // -1...+1
                let t: SKTileGroup
                switch v {
                case ..<(-0.25): t = water             // deep water
                case -0.25..<(-0.05): t = sand         // shore
                case -0.05..<0.45: t = grass           // plains
                default: t = rock                       // mountains
                }
                tileMap.setTileGroup(t, forColumn: x, row: y)
            }
        }

        tileMap.position = CGPoint(x: -tileMap.mapSize.width/2, y: -tileMap.mapSize.height/2)
        addChild(tileMap)

        // Optional: camera so you can zoom/pan
        let cam = SKCameraNode()
        self.camera = cam
        addChild(cam)
        cam.setScale(1.0)
    }

    // Simple tileset with solid-color textures (replace with real art later)
    private func makeSimpleColorTileSet() -> SKTileSet {
        func tileGroup(name: String, color: NSColor) -> SKTileGroup {
            let tex = SKTexture(image: NSImage(size: NSSize(width: 8, height: 8), flipped: false) { rect in
                color.setFill(); rect.fill(); return true
            })
            let def = SKTileDefinition(texture: tex, size: tileSize)
            let rule = SKTileGroupRule(adjacency: .adjacencyAll, tileDefinitions: [def])
            let group = SKTileGroup(rules: [rule]); group.name = name
            return group
        }

        let groups = [
            tileGroup(name: "water", color: NSColor.systemBlue),
            tileGroup(name: "sand",  color: NSColor.systemYellow),
            tileGroup(name: "grass", color: NSColor.systemGreen),
            tileGroup(name: "rock",  color: NSColor.systemGray)
        ]
        return SKTileSet(tileGroups: groups)
    }
}
