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
}
