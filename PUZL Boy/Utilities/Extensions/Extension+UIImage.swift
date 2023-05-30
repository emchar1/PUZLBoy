//
//  Extension+UIImage.swift
//  PUZL Boy
//
//  Created by Eddie Char on 11/30/22.
//

import UIKit

extension UIImage {
    ///Commonly used in menu background colors.
    static let menuGradientTexture = UIImage.createGradientImage(startPoint: CGPoint(x: 0.5, y: 1), endPoint: CGPoint(x: 0.5, y: 0.5), topColorWhiteValue: 200, bottomColorWhiteValue: 255)
    
    ///Commonly used gradient texture used in chat bubbles, etc.
    static let chatGradientTexture = UIImage.createGradientImage(startPoint: CGPoint(x: 0.5, y: 1), endPoint: CGPoint(x: 0.5, y: 0.5), topColorWhiteValue: 100, bottomColorWhiteValue: 200)
    
    ///Commonly used in Purchase Buttons, with image inlay.
    static let purchaseButtonGradientTexture = UIImage.createGradientImage(
        withBounds: CGRect(x: 0, y: 0, width: K.ScreenDimensions.iPhoneWidth, height: K.ScreenDimensions.height),
        startPoint: CGPoint(x: 0.5, y: 1), endPoint: CGPoint(x: 0.5, y: 0.5),
        colors: [UIColor(red: 100 / 255, green: 100 / 255, blue: 100 / 255, alpha: 1).cgColor,
                 UIColor(red: 200 / 255, green: 200 / 255, blue: 200 / 255, alpha: 0.1).cgColor]
    )

    ///Can also be used in menu background colors.
    static var skyGradientTexture: UIImage {
        UIImage.createGradientImage(
            withBounds: CGRect(x: 0, y: 0, width: K.ScreenDimensions.iPhoneWidth, height: K.ScreenDimensions.height),
            startPoint: CGPoint(x: 0.5, y: 1), endPoint: CGPoint(x: 0.5, y: 0.5),
            colors: [DayTheme.skyColor.top.cgColor, DayTheme.skyColor.bottom.cgColor])
    }

    ///Convenience method to createGradientImage(withBounds:startPoint:endPoint:colors)
    static func createGradientImage(startPoint: CGPoint, endPoint: CGPoint, topColorWhiteValue topValue: CGFloat, bottomColorWhiteValue bottomValue: CGFloat) -> UIImage {
        let image = UIImage.createGradientImage(
            withBounds: CGRect(x: 0, y: 0, width: K.ScreenDimensions.iPhoneWidth, height: K.ScreenDimensions.height),
            startPoint: startPoint, endPoint: endPoint,
            colors: [UIColor(red: topValue / 255, green: topValue / 255, blue: topValue / 255, alpha: 1).cgColor,
                     UIColor(red: bottomValue / 255, green: bottomValue / 255, blue: bottomValue / 255, alpha: 1).cgColor])
        
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
