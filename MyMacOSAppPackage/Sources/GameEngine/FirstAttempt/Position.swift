//
//  Position.swift
//  MyMacOSAppFeature
//
//  Created by Moritz Ellerbrock on 27.07.25.
//


public struct Position: Hashable, Codable {
    public let x: Int
    public let y: Int

    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    public func set(x newXValue: Int) -> Self {
        .init(x: newXValue, y: self.y)
    }

    public func set(y newYValue: Int) -> Self {
        .init(x: self.x, y: newYValue)
    }
}

extension Position {
    public static var zero: Position {
        .init(x: 0, y: 0)
    }
}
