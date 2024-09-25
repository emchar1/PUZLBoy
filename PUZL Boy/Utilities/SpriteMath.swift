//
//  SpriteMath.swift
//  PUZL Boy
//
//  Created by Eddie Char on 9/22/23.
//

import Foundation

///A struct with various math formulas and properties.
struct SpriteMath {
    ///Specific to Trigonometric functions.
    struct Trigonometry {
        /**
         Obtains the midpoint between two points at a given step, among a number of steps in between.
         - parameters:
            - startPoint: starting point on the line
            - endPoint: end point on the line
            - step: the nth step among numerous equidistant steps along the line
            - totalSteps: total number of equidistant steps along the line
         - returns: the midpoint (not necessarily in the middle) given the values entered in the arguments
         */
        static func getMidpoint(startPoint: CGPoint, endPoint: CGPoint, step: Int, totalSteps: Int) -> CGPoint {
            guard step > 0 && totalSteps > 0 else { return .zero }
            
            let (sideX, _, hypotenuse) = getSides(startPoint: startPoint, endPoint: endPoint)
            let alpha = asin(sideX / hypotenuse)
            let hypotenuseMid = hypotenuse * CGFloat(step) / CGFloat(totalSteps)
            let midPoint = CGPoint(x: sin(alpha) * hypotenuseMid, y: cos(alpha) * hypotenuseMid)
            
            //Add or subtract, depending on where midPoint is situated in relation to startPoint on the xy-axis.
            return CGPoint(x: startPoint.x + midPoint.x * (endPoint.x > startPoint.x ? 1 : -1),
                           y: startPoint.y + midPoint.y * (endPoint.y > startPoint.y ? 1 : -1))
        }
        
        /**
         Obtains the 2 non-right angle of a right triangle, given two points.
         - parameters:
            - startPoint: starting point on the line
            - endPoint: end point on the line
         - returns: the two non-right angle of the right triangle; alpha is adjacent to the vertical line (y) and beta is adjacent to the horizontal line (x), in radians
         */
        static func getAngles(startPoint: CGPoint, endPoint: CGPoint) -> (alpha: CGFloat, beta: CGFloat) {
            let (sideX, sideY, hypotenuse) = getSides(startPoint: startPoint, endPoint: endPoint)
            let alpha = asin(sideX / hypotenuse)        //radians
            let beta = asin(sideY / hypotenuse)         //radians
            
            return (alpha, beta)
        }
        
        /**
         Obtains the length of all sides of a right triangle, given two points.
         - parameters:
            - startPoint: starting point on the line
            - endPoint: end point on the line
         - returns: the lengths of x, y, and the hypotenuse
         */
        static func getSides(startPoint: CGPoint, endPoint: CGPoint) -> (sideX: CGFloat, sideY: CGFloat, hypotenuse: CGFloat) {
            let sideX = abs(endPoint.x - startPoint.x)
            let sideY = abs(endPoint.y - startPoint.y)
            let hypotenuse = sqrt(pow(sideX, 2) + pow(sideY, 2))
            
            return (sideX, sideY, hypotenuse)
        }
    }
    
    ///Specific to circles.
    struct Circle {
        /**
         Returns the (x, y) positions coordinates of a circle given 3 positions on the GameBoard.
         - parameters:
            - positions: 3 points on the GameBoard
            - step: Number of divisions, the more, the smoother the circle.
         - returns: (x, y0) top and (x, y1) bottom halves of the circle.
         */
        static func getPositions(positions: [K.GameboardPosition], divisionsOf2Pi: CGFloat) -> [K.GameboardPositionCGFloat] {
            var allPositions: [K.GameboardPositionCGFloat] = []

            //Guard checks
            guard positions.count == 3 else { return allPositions }
            guard let center = getCenter(positions: positions) else { return allPositions }
            guard let radius = getRadius(positions: positions) else { return allPositions }
            
            let sinAngle = asin((CGFloat(positions[0].col) - center.y) / radius)
            let cosAngle = acos((CGFloat(positions[0].row) - center.x) / radius)

            // FIXME: - This seems hokey! FIGURE THIS PART OUT!!
            let startAngle = CGFloat(positions[0].row) > center.x ? sinAngle : cosAngle
            
            for angle in stride(from: startAngle, through: 4 * CGFloat.pi + startAngle, by: 2 * CGFloat.pi / divisionsOf2Pi) {
                let nextPosition: K.GameboardPositionCGFloat = (center.x + radius * cos(angle), center.y + radius * sin(angle))
                
                allPositions.append(nextPosition)
            }
            
//            print("SpriteMath.Circle.getPositions: \(allPositions)")
            return allPositions
        }
        
        /**
         Returns the center of a circle, given 2 or 3 (non-collinear) positions on a K.GameboardSprite.
         */
        static func getCenter(positions: [K.GameboardPosition]) -> CGPoint? {
            let center: CGPoint?
            
            switch positions.count {
            case 2:
                center = CGPoint(x: CGFloat(positions[0].row + positions[1].row) / 2, y: CGFloat(positions[0].col + positions[1].col) / 2)
            case 3:
                let p0 = CGPoint(x: positions[0].row, y: positions[0].col)
                let p1 = CGPoint(x: positions[1].row, y: positions[1].col)
                let p2 = CGPoint(x: positions[2].row, y: positions[2].col)
                
                guard let isCollinear = checkCollinear(positions: positions), !isCollinear else {
                    print("Oops! Points on circle are collinear")
                    center = nil
                    break
                }
                
                let A: CGFloat = (p1.y - p0.y) / (p2.y - p0.y)
                let B: CGFloat = pow(p1.x, 2) + pow(p1.y, 2) - pow(p0.x, 2) - pow(p0.y, 2) - A * (pow(p2.x, 2) + pow(p2.y, 2) - pow(p0.x, 2) - pow(p0.y, 2))
                
                let h = -B / (2 * A * (p2.x - p0.x) - 2 * (p1.x - p0.x))
                let k = (pow(p2.x, 2) + pow(p2.y, 2) - pow(p0.x, 2) - pow(p0.y, 2) - 2 * h * (p2.x - p0.x)) / (2 * (p2.y - p0.y))
                
                center = CGPoint(x: h, y: k)
            default:
                center = nil
            }
            
//            print("SpriteMath.Circle.getCenter: \(center)")
            return center
        }
        
        /**
         Returns the radius of a circle, given 2 or 3 (non-collinear) positions on a K.GameboardSprite.
         */
        static func getRadius(positions: [K.GameboardPosition]) -> CGFloat? {
            guard let center = getCenter(positions: positions) else { return nil }
            
            let radius: CGFloat?
            
            switch positions.count {
            case 2, 3:
                radius = sqrt(pow(CGFloat(positions[0].row) - center.x, 2) + pow(CGFloat(positions[0].col) - center.y, 2))
            default:
                radius = nil
            }
            
//            print("SpriteMath.Circle.getRadius: \(radius)")
            return radius
        }
        
        /**
         Checks if 3 points are collinear, return true if so.
         */
        static func checkCollinear(positions: [K.GameboardPosition]) -> Bool? {
            guard positions.count == 3 else { return nil }
            
            func slope(p0: K.GameboardPosition, p1: K.GameboardPosition) -> CGFloat {
                return CGFloat(p1.col - p0.col) / CGFloat(p1.row - p0.row)
            }
            
            let m0_1 = slope(p0: positions[0], p1: positions[1])
            let m0_2 = slope(p0: positions[0], p1: positions[2])
            let m1_2 = slope(p0: positions[1], p1: positions[2])
            
            let isCollinear = (m0_1 == m0_2 && (m0_1 == m1_2 || m0_2 == m1_2))
            
//            print("SpriteMath.Circle.checkCollinear: \(isCollinear)")
            return isCollinear
        }
        
        /**
         Returns the domain (lowerRange...upperRange) of x-values, given 3 points.
         */
        static func getDomain(positions: [K.GameboardPosition]) -> ClosedRange<CGFloat>? {
            guard positions.count == 3 else { return nil }
            guard let center = getCenter(positions: positions) else { return nil }
            guard let radius = getRadius(positions: positions) else { return nil }
            
            let lowerRange = center.x - radius
            let upperRange = center.x + radius

//            print("SpriteMath.Circle.getDomain: \(lowerRange...upperRange)")
            return lowerRange...upperRange
        }
        
    } //end struct Circle
    
    
}
