//
//  Circle.swift
//  PUZL Boy
//
//  Created by Eddie Char on 3/17/24.
//

import Foundation

struct Circle {
    
    // MARK: - Properties
    
    var side: CGFloat
    var initialAngle: CGFloat
    var center: CGPoint
    var radius: CGFloat
    
    
    // MARK: - Initialization
    
    init(side: CGFloat, initialAngle: CGFloat = .pi / 4, center: CGPoint) {
        self.side = side
        self.initialAngle = initialAngle
        self.center = center
        
        radius = sqrt(2) * side
    }
    
    
    // MARK: - Functions
    
    func getPointOnCircle(angleRad: CGFloat) -> CGPoint {
        return CGPoint(x: center.x + cos(initialAngle + angleRad) * radius, y: center.y + sin(initialAngle + angleRad) * radius)
    }
    
    func getPointOnCircle(angleDeg: CGFloat) -> CGPoint {
        return getPointOnCircle(angleRad: angleDeg * .pi / 180)
    }

}
