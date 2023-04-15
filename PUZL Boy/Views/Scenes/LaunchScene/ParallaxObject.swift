//
//  ParallaxObject.swift
//  PUZL Boy
//
//  Created by Eddie Char on 4/12/23.
//

import Foundation

struct ParallaxObject {
    
    // MARK: - Properties
    
    let set: SetType
    let layer: Int
    let type: ObjectType
    let speed: TimeInterval
    let size: CGSize
    let zPosition: CGFloat
    var scale: CGFloat { K.ScreenDimensions.height / size.height }
    var sizeScaled: CGFloat { size.width * scale }
    var imageName: String { "set\(set.rawValue)_layer\(layer)" }
    var nodeName: String {
        switch type {
        case .ground:   return LaunchScene.nodeName_groundObjectNode
        case .sky:      return LaunchScene.nodeName_skyObjectNode
        }
    }
    
    enum SetType: Int, CaseIterable {
        case grass = 0, marsh, ice, sand, lava
    }

    enum ObjectType {
        case ground, sky
    }

    
    // MARK: Initialization
    
    init(set: SetType, layer: Int, type: ObjectType, speed: TimeInterval, size: CGSize, zPosition: CGFloat) {
        self.set = set
        self.layer = layer
        self.type = type
        self.speed = speed
        self.size = size
        self.zPosition = zPosition
    }
}
