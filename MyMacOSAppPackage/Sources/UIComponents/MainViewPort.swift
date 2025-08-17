//
//  SwiftUIView.swift
//  MyMacOSAppFeature
//
//  Created by Moritz Ellerbrock on 17.08.25.
//

import SwiftUI

public struct MainViewPort: View {

    public init () { }

    public var body: some View {
//        SpriteKitContentView()
        NoiseDebugView()
    }
}

#Preview {
    MainViewPort()
}
