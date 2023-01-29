//
//  Extension+UIImage.swift
//  PUZL Boy
//
//  Created by Eddie Char on 11/30/22.
//

import UIKit

extension UIImage {
    ///Commonly used gradient texture used in chat bubbles, etc.
    static let chatGradientTexture = UIImage.createGradientImage(startPoint: CGPoint(x: 0.5, y: 1), endPoint: CGPoint(x: 0.5, y: 0.5), topColorWhiteValue: 100, bottomColorWhiteValue: 200)

    ///Convenience method to createGradientImage(withBounds:startPoint:endPoint:colors)
    static func createGradientImage(startPoint: CGPoint, endPoint: CGPoint, topColorWhiteValue: CGFloat, bottomColorWhiteValue: CGFloat) -> UIImage {
        let image = UIImage.createGradientImage(
            withBounds: CGRect(x: 0, y: 0, width: K.ScreenDimensions.iPhoneWidth, height: K.ScreenDimensions.height),
            startPoint: startPoint, endPoint: endPoint,
            colors: [UIColor(red: topColorWhiteValue / 255, green: topColorWhiteValue / 255, blue: topColorWhiteValue / 255, alpha: 1).cgColor,
                     UIColor(red: bottomColorWhiteValue / 255, green: bottomColorWhiteValue / 255, blue: bottomColorWhiteValue / 255, alpha: 1).cgColor])
        
        return image
    }
    
    /**
     Creates a gradient image, used as a texture for sprites.
     - parameters:
        - withBounds: the bounds of the gradient
        - startPoint: starting point of the gradient
        - endPoint: ending point of the gradient
        - colors: array of colors used in the gradient
     - returns: the gradient UIImage
     */
    static func createGradientImage(withBounds bounds: CGRect, startPoint: CGPoint, endPoint: CGPoint, colors: [CGColor]) -> UIImage {
        //Configure the gradient layer based on input
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        
        //Render the image using the gradient layer
        UIGraphicsBeginImageContext(gradientLayer.frame.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}
