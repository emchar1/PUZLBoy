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
    
    static var isFire: Bool = true
    
    //Computed properties
    static var overlayColor: UIColor { isFire ? .red : .blue }
    static var overlaySystemColor: UIColor { isFire ? .systemRed : .systemBlue }
    static var soundMovementSandSnow: String { isFire ? "movesand\(Int.random(in: 1...3))" : "movesnow\(Int.random(in: 1...3))" }
    static var soundEnemyAttack: String { isFire ? "enemyflame" : "enemyice"}
    static var spriteEnemyExplode: String { isFire ? "enemy" : "enemyIce" }
    static var skyNodeOverlay: UIImage { isFire ? UIImage.gradientTextureSkyBlood : UIImage.gradientTextureSkyIce }
    static var skyColorDescription: String { isFire ? "blood" : "ice" }
    static var particleTypeDragonLiteAttack: ParticleEngine.ParticleType { isFire ? .dragonFireLite : .dragonIceLite }
    static var particleTypeDragonFireIdle: ParticleEngine.ParticleType { isFire ? .dragonFireIdle : .dragonIceIdle }

    
    // MARK: - Functions
    
    static func setOnFire(_ isFire: Bool) {
        self.isFire = isFire
    }
}
