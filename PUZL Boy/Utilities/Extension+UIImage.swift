//
//  Extension+UIImage.swift
//  PUZL Boy
//
//  Created by Eddie Char on 11/30/22.
//

import UIKit

extension UIImage {
    static func gradientImage(withBounds bounds: CGRect, startPoint: CGPoint, endPoint: CGPoint, colors: [CGColor]) -> UIImage {
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
