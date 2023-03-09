//
//  TabBarEngine.swift
//  PUZL Boy
//
//  Created by Eddie Char on 3/9/23.
//

import SpriteKit

class TabBarEngine {
    
    // MARK: - Properties
    
    private var sprite: SKShapeNode
    private(set) var titleButton: TabBarButton
    private(set) var buyButton: TabBarButton
    private(set) var pauseResetButton: TabBarButton
    private(set) var leaderboardButton: TabBarButton
    private(set) var settingsButton: TabBarButton
    
    
    
    
    // MARK: - Initialization
    
    init() {
        sprite = SKShapeNode(rect: CGRect(x: 0, y: 0, width: K.ScreenDimensions.iPhoneWidth, height: K.ScreenDimensions.bottomMargin + 200))
        sprite.fillColor = .lightGray
        sprite.lineWidth = 0
        
        let buttonSize: CGFloat = 60
        
        titleButton = TabBarButton(imageName: "enemy", type: .title, position: CGPoint(x: 0, y: 0))
        buyButton = TabBarButton(imageName: "enemy", type: .buy, position: CGPoint(x: buttonSize, y: 0))
        pauseResetButton = TabBarButton(imageName: "enemy", type: .pauseReset, position: CGPoint(x: 2 * buttonSize, y: 0))
        leaderboardButton = TabBarButton(imageName: "enemy", type: .leaderboard, position: CGPoint(x: 3 * buttonSize, y: 0))
        settingsButton = TabBarButton(imageName: "enemy", type: .settings, position: CGPoint(x: 4 * buttonSize, y: 0))
    }
    
    
    // MARK: - Functions
    
    func moveTo(superScene: SKScene) {
        sprite.addChild(titleButton)
        sprite.addChild(buyButton)
        sprite.addChild(pauseResetButton)
        sprite.addChild(leaderboardButton)
        sprite.addChild(settingsButton)

        superScene.addChild(sprite)
    }
    
}
