//
//  Circle.swift
//  PUZL Boy
//
//  Created by Eddie Char on 3/17/24.
//

import Foundation
// TODO: - Merge this with SpriteMath.Circle
struct Circle {
    
    // MARK: - Properties
    
    ///Length of HALF the side of a square inscribed in the circle
    private var side: CGFloat
    
    ///The initial angle from 0 degrees. If none is specified, .pi / 4 = 45 degrees will be used
    private var initialAngle: CGFloat

    ///Center point of the circle/square
    private var center: CGPoint
    
    ///Radius of the circle
    private var radius: CGFloat
    
    
    // MARK: - Initialization
    
    init(side: CGFloat, initialAngle: CGFloat = -3 * .pi / 4, center: CGPoint) {
        self.side = side
        self.initialAngle = initialAngle
        self.center = center
        
        radius = sqrt(2) * side
    }
    
    
    // MARK: - Functions
    
    /**
     Gets a point on the circumference of a circle given an angle, in radians, and adding the initialAngle to it.
     - parameter angleRad: the angle, in radians used to compute the point on the circle,
     - returns: the point on the circle
     */
    func getPointOnCircle(angleRad: CGFloat) -> CGPoint {
        return CGPoint(x: center.x + cos(initialAngle + angleRad) * radius, y: center.y + sin(initialAngle + angleRad) * radius)
    }

}
