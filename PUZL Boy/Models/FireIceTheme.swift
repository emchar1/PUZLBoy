//
//  FireIceTheme.swift
//  PUZL Boy
//
//  Created by Eddie Char on 1/25/24.
//

import SpriteKit

///Just a collection of shortcuts and properties for the new Fire and Ice theme 1/25/24.
struct FireIceTheme {
    
    // MARK: - Properties
    
    
    
    // FIXME: - FIRE/ICE TEST
    static private(set) var isFire: Bool = (DayTheme.currentTheme == .morning || DayTheme.currentTheme == .afternoon) ? true : false
    
    
    
    
    
    // MARK: - Computed Properties
    
    //Colors
    static var overlayColor: UIColor { isFire ? .red : .blue }
    static var overlaySystemColor: UIColor { isFire ? .systemRed : .systemBlue }
    
    //Sounds
    static var soundMovementSandSnow: String { isFire ? "movesand\(Int.random(in: 1...3))" : "movesnow\(Int.random(in: 1...3))" }
    static var soundEnemyAttack: String { isFire ? "enemyflame" : "enemyice"}
    
    //Sprites, Textures & Images
    static var spriteEnemyExplode: String { isFire ? "enemy" : "enemyIce" }
    static var spriteEnemyLarge: String { isFire ? "enemyLarge" : "enemyIceLarge" }
    static var imageSkyNodeOverlay: UIImage { isFire ? UIImage.gradientTextureSkyBlood : UIImage.gradientTextureSkyIce }
    static var textureFlyingDragon: String { isFire ? "flyingDragon" : "flyingDragonIce" }

    //Effects
    static var particleTypeDragonFire: ParticleEngine.ParticleType { isFire ? .dragonFire : .dragonIce }
    static var particleTypeDragonFireIdle: ParticleEngine.ParticleType { isFire ? .dragonFireIdle : .dragonIceIdle }
    static var particleTypeDragonFireLite: ParticleEngine.ParticleType { isFire ? .dragonFireLite : .dragonIceLite }

    //Strings
    static var skyColorDescription: String { isFire ? "blood" : "ice" }

    
    // MARK: - Functions
    
    static func setOnFire(_ isFire: Bool) {
        self.isFire = isFire
    }
    
    
}
