//
//  TabBarEngine.swift
//  PUZL Boy
//
//  Created by Eddie Char on 3/9/23.
//

import SpriteKit

class TabBarEngine {
    
    // MARK: - Properties
    
    private var disableControls: Bool = false
    private(set) var sprite: SKShapeNode
    private(set) var titleButton: TabBarButton
    private(set) var buyButton: TabBarButton
    private(set) var pauseResetButton: TabBarButton
    private(set) var leaderboardButton: TabBarButton
    private(set) var settingsButton: TabBarButton
    
    
    
    
    // MARK: - Initialization
    
    init() {
        let buttonSize: CGFloat = K.ScreenDimensions.iPhoneWidth / 5
        let bottomMargin: CGFloat = K.ScreenDimensions.bottomMargin

        sprite = SKShapeNode(rect: CGRect(x: 0, y: 0, width: K.ScreenDimensions.iPhoneWidth, height: bottomMargin + buttonSize))
        sprite.fillColor = .lightGray
        sprite.lineWidth = 0
        
        titleButton = TabBarButton(imageName: "enemy", type: .title,
                                   position: CGPoint(x: buttonSize / 2, y: buttonSize / 2 + bottomMargin))
        buyButton = TabBarButton(imageName: "enemy", type: .buy,
                                 position: CGPoint(x: 3 * buttonSize / 2, y: buttonSize / 2 + bottomMargin))
        pauseResetButton = TabBarButton(imageName: "enemy", type: .pauseReset,
                                        position: CGPoint(x: 5 * buttonSize / 2, y: buttonSize / 2 + bottomMargin))
        leaderboardButton = TabBarButton(imageName: "enemy", type: .leaderboard,
                                         position: CGPoint(x: 7 * buttonSize / 2, y: buttonSize / 2 + bottomMargin))
        settingsButton = TabBarButton(imageName: "enemy", type: .settings,
                                      position: CGPoint(x: 9 * buttonSize / 2, y: buttonSize / 2 + bottomMargin))

        sprite.addChild(titleButton)
        sprite.addChild(buyButton)
        sprite.addChild(pauseResetButton)
        sprite.addChild(leaderboardButton)
        sprite.addChild(settingsButton)
    }
    
    
    // MARK: - Functions
    
    func moveTo(superScene: SKScene) {
        superScene.addChild(sprite)
    }
    
    func didTapButton(_ touches: Set<UITouch>) {
//        guard !disableControls else { return print("Controls disabled in TabBarEngine.didTapButton. Aborting.") }
        guard let touch = touches.first else { return print("Error capturing touch in TabBarEngine.didTapButton") }
        
        let location = touch.location(in: sprite)
        let nodes = sprite.nodes(at: location)
        
        for node in nodes {
            switch node.name {
            case TabBarButton.TabBarType.title.rawValue:
                titleButton.tapButton()
            case TabBarButton.TabBarType.buy.rawValue:
                buyButton.tapButton()
            case TabBarButton.TabBarType.pauseReset.rawValue:
                pauseResetButton.tapButton()
            case TabBarButton.TabBarType.leaderboard.rawValue:
                leaderboardButton.tapButton()
            case TabBarButton.TabBarType.settings.rawValue:
                settingsButton.tapButton()
            default:
                print("unknown button pressed")
            }
        }
    }
    
    
    
}
