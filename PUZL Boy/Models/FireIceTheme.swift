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
    
    //Main
    static var isFire: Bool { FIRManager.decisionsLeftButton[1] == nil || FIRManager.decisionsLeftButton[1]! }
    
    //Colors - I don't think these are in use??? 8/12/24
    static var overlayColor: UIColor { isFire ? .red : .blue }
    static var overlaySystemColor: UIColor { isFire ? .systemRed : .systemBlue }
    
    //Sounds
    static var soundMovementSandSnow: String { isFire ? "movesand\(Int.random(in: 1...3))" : "movesnow\(Int.random(in: 1...3))" }
    static var soundEnemyAttack: String { isFire ? "enemyflame" : "enemyice" }
    
    //Sprites, Textures & Images
    static var spriteEnemyExplode: String { isFire ? "enemy" : "enemyIce" }

    //Effects
    static var particleTypeDragonFireIdle: ParticleEngine.ParticleType { isFire ? .dragonFireIdle : .dragonIceIdle }
    static var particleTypeDragonFireLite: ParticleEngine.ParticleType { isFire ? .dragonFireLite : .dragonIceLite }
}
