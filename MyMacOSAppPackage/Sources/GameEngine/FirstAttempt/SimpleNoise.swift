//
//  SimpleNoise.swift
//  MyMacOSAppFeature
//
//  Created by Moritz Ellerbrock on 27.07.25.
//


public struct SimpleNoise {
    private let seed: UInt64

    public init(seed: UInt64) {
        self.seed = seed
    }

    public func value(atX x: Int, y: Int) -> Double {
        // Convert grid position to a unique hash based on coordinates and seed
        var state = UInt64(x &* 73856093) ^ UInt64(y &* 19349663) ^ seed
        state ^= state >> 12
        state ^= state << 25
        state ^= state >> 27
        let raw = state &* 2685821657736338717
        return Double(raw % UInt64.max) / Double(UInt64.max)
    }
}