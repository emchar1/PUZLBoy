//
//  Extension+UIColor.swift
//  PUZL Boy
//
//  Created by Eddie Char on 4/1/23.
//

import UIKit

extension UIColor {
    
    // MARK: - Properties
    
    var complementary: UIColor {
        return withHueOffset(180 / 360)
    }
    
    var splitComplementary: (first: UIColor, second: UIColor) {
        return (withHueOffset(150 / 360), withHueOffset(210 / 360))
    }
    
    var triadic: (first: UIColor, second: UIColor) {
        return (withHueOffset(120 / 360), withHueOffset(240 / 360))
    }
    
    var analogous: (first: UIColor, second: UIColor) {
        return (withHueOffset(-30 / 360), withHueOffset(30 / 360))
    }
    
    private var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return (red, green, blue, alpha)
    }
    
    
    // MARK: - Functions
    
    private func withHueOffset(_ offset: CGFloat) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        let offsetColor = UIColor(hue: fmod(hue + offset, 1), saturation: saturation, brightness: brightness, alpha: alpha)
        
        return offsetColor
    }
    
    func isLight() -> Bool? {
        guard let componentColors: [CGFloat] = cgColor.components else { return nil }
        
        let threshold = ((componentColors[0] * 299) + (componentColors[1] * 587) + (componentColors[2] * 114)) / 1000
        
        return threshold > 0.5
    }
    
    func lightenColor(factor: CGFloat = 1) -> UIColor {
        return adjustColor(UIColor(red: (10 * factor) / 255, green: (10 * factor) / 255, blue: (10 * factor) / 255, alpha: 0))
    }

    func darkenColor(factor: CGFloat = 1) -> UIColor {
        return adjustColor(UIColor(red: (-10 * factor) / 255, green: (-10 * factor) / 255, blue: (-10 * factor) / 255, alpha: 0))
    }

    func adjustColor(_ adjusted: UIColor) -> UIColor {
        return UIColor(red: min(255, max(0, components.red + adjusted.components.red)),
                       green: min(255, max(0, components.green + adjusted.components.green)),
                       blue: min(255, max(0, components.blue + adjusted.components.blue)),
                       alpha: min(255, max(0, components.alpha + adjusted.components.alpha)))
    }
}
