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
    static var isFire: Bool { FIRManager.decisions[1] == nil || FIRManager.decisions[1].isLeftButton() }
    static var isDay: Bool { DayTheme.currentTheme == .morning || DayTheme.currentTheme == .afternoon }
    
    //Colors
    static var overlayColor: UIColor { isFire ? .red : .blue }
    static var overlaySystemColor: UIColor { isFire ? .systemRed : .systemBlue }
    
    //Sounds
    static var soundMovementSandSnow: String { isFire ? "movesand\(Int.random(in: 1...3))" : "movesnow\(Int.random(in: 1...3))" }
    static var soundEnemyAttack: String { isFire ? "enemyflame" : "enemyice" }
    static var soundWinLevel: String { isFire || isDay ? "winlevel" : "winlevelice" }
    static var musicGameOver: String { isFire || isDay ? "gameover" : "gameoverice" }
    static var musicOverworldTheme: String { isFire || isDay ? AudioManager.shared.overworldTheme : AudioManager.shared.overworldIceTheme }
    
    //Sprites, Textures & Images
    static var spriteEnemyExplode: String { isFire ? "enemy" : "enemyIce" }

    //Effects
    static var particleTypeDragonFireIdle: ParticleEngine.ParticleType { isFire ? .dragonFireIdle : .dragonIceIdle }
    static var particleTypeDragonFireLite: ParticleEngine.ParticleType { isFire ? .dragonFireLite : .dragonIceLite }
}
