//
//  FinalGameboard.swift
//  PUZL Boy
//
//  Created by Eddie Char on 10/8/24.
//

import SpriteKit

class FinalGameboard: SKNode {
    
    // MARK: - Properties
    
    private var hero: Player!
    private var villain: Player!
    private var partyTile: SKSpriteNode!
    private var dragonOverlay: SKSpriteNode!
    
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        
        setupNodes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("FinalGameboard deinit")
    }
    
    private func setupNodes() {
        hero = Player(type: .hero)
        villain = Player(type: .villain)
        
        partyTile = SKSpriteNode(imageNamed: "partytile")

        dragonOverlay = SKSpriteNode(imageNamed: "enemy")
    }
    
    
    // MARK: - Functions
    
    override func move(toParent parent: SKNode) {
        super.move(toParent: parent)
        
        addChild(hero.sprite)
        addChild(villain.sprite)
        addChild(partyTile)
        addChild(dragonOverlay)
        
        parent.addChild(self)
    }
    
    
    
}
