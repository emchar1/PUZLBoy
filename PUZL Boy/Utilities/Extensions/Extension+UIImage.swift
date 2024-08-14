//
//  Extension+UIImage.swift
//  PUZL Boy
//
//  Created by Eddie Char on 11/30/22.
//

import UIKit

extension UIImage {
    //Gradient Textures
    static let gradientTextureMenu = UIImage(named: "gradientMenu") ?? UIImage() //(yStart: 0.5, yEnd: 1); (whitenessStart: 100%, whitenessEnd: 80%)
    static let gradientTextureChat = UIImage(named: "gradientChat") ?? UIImage() //(0.5, 1); (80%, 40%)
    static let gradientTextureDisplayIcon = UIImage(named: "gradientDisplayIcon") ?? UIImage() //(0.5, 1); (60%, 80%)
    static let gradientTexturePurchaseButton = UIImage(named: "gradientPurchaseButton") ?? UIImage() //(0.5, 1); (60%, 40%)
    static let gradientTextureLoadingBar = UIImage(named: "gradientLoadingBar") ?? UIImage() //(0.5, 1); (80%, 100%)
    static let gradientTextureLoadingContainer = UIImage(named: "gradientLoadingContainer") ?? UIImage() //(0, 1); (0%, 60%)
    
    //Sky Gradient Textures
    static let gradientTextureSkyDawn = UIImage(named: "gradientSkyDawn") ?? UIImage()
    static let gradientTextureSkyMorning = UIImage(named: "gradientSkyMorning") ?? UIImage()
    static let gradientTextureSkyAfternoon = UIImage(named: "gradientSkyAfternoon") ?? UIImage()
    static let gradientTextureSkyNight = UIImage(named: "gradientSkyNight") ?? UIImage()
    static let gradientTextureSkyBlood = UIImage(named: "gradientSkyBlood") ?? UIImage()
    static let gradientTextureSkyIce = UIImage(named: "gradientSkyIce") ?? UIImage()
}
