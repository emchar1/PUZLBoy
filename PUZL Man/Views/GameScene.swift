//
//  GameScene.swift
//  PUZL Man
//
//  Created by Eddie Char on 9/27/22.
//

import SpriteKit

class GameScene: SKScene {
    
    // MARK: - Properties
    
    var gameboardSprite: GameboardSprite
    var controlsSprite: ControlsSprite
    var playerSprite: PlayerSprite
    
    // MARK: - Initialization
    
    override init(size: CGSize) {
        let level = LevelBuilder.levels[1]
        gameboardSprite = GameboardSprite(level: level)
        print(level)
        
        controlsSprite = ControlsSprite()
        
        playerSprite = PlayerSprite()

        super.init(size: size)

        scaleMode = .aspectFill
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Touches

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        
        if contains(location: location, in: controlsSprite.up, offset: controlsSprite.offsetPosition) {
            print(gameboardSprite.gameboardSize)
        }
        else if contains(location: location, in: controlsSprite.down, offset: controlsSprite.offsetPosition) {
            print("Down pressed")
        }
        else if contains(location: location, in: controlsSprite.left, offset: controlsSprite.offsetPosition) {
            print("Left pressed")
        }
        else if contains(location: location, in: controlsSprite.right, offset: controlsSprite.offsetPosition) {
            print("Right pressed")
        }
    }
    
    private func contains(location: CGPoint, in sprite: SKSpriteNode, offset: CGPoint = .zero) -> Bool {
        
        
        return location.x > offset.x + sprite.position.x &&
        location.x < offset.x + sprite.position.x + sprite.size.width &&
        location.y > offset.y + sprite.position.y &&
        location.y < offset.y + sprite.position.y + sprite.size.height
    }
    

    // MARK: - Required Functions
    
    override func didMove(to view: SKView) {
        addChild(gameboardSprite.sprite)
        addChild(controlsSprite.sprite)
        gameboardSprite.sprite.addChild(playerSprite.sprite)
    }
    
    override func update(_ currentTime: TimeInterval) {

    }
    
}
