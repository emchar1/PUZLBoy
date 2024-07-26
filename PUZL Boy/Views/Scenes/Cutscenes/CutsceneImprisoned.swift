//
//  CutsceneImprisoned.swift
//  PUZL Boy
//
//  Created by Eddie Char on 3/4/24.
//

import SpriteKit

// TODO: - Cutscene Princess Imprisoned

class CutsceneImprisoned: Cutscene {
    
    // MARK: - Properties
    
    
    // MARK: - Initialization
    
    init() {
        super.init(size: K.ScreenDimensions.size, playerLeft: .hero, playerRight: .princess, xOffsetsArray: nil)
        
        //Custom implementation.
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupScene() {
        super.setupScene()
        
        //Custom implementation.
    }
    
    override func cleanupScene(buttonTap: ButtonTap.ButtonType?, fadeDuration: TimeInterval?) {
        super.cleanupScene(buttonTap: buttonTap, fadeDuration: fadeDuration)
        
        //Custom implementation here, if needed.
    }
    
    
    // MARK: - Functions
    
    
}
