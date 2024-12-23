//
//  FinalBattle2Controls.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/21/24.
//

import SpriteKit

class FinalBattle2Controls {
    
    // MARK: - Properties
    
    private var gameboard: GameboardSprite
    private var player: Player
    private var playerPosition: K.GameboardPosition
    
    private var location: CGPoint!
    private var isDisabled: Bool

    
    // MARK: - Initialization
    
    init(gameboard: GameboardSprite, player: Player, playerPosition: K.GameboardPosition) {
        self.gameboard = gameboard
        self.player = player
        self.playerPosition = playerPosition
        
        self.isDisabled = false
    }
    
    deinit {
        print("deinit FinalBattle2Controls")
    }
    
    
    // MARK: - Functions
    
    /**
     Handles player movement based on control input.
     - parameters:
        - location: Location for which comparison is to occur
        - playerPosition: the player's position, which will be overridden becuase it's an inout parameter
        - completion: handler to perform tasks upon completion
     */
    func handleControls(in location: CGPoint, playerPosition: inout K.GameboardPosition, completion: (() -> Void)?) {
        guard !isDisabled else { return }
        
        self.location = location
        
        if inBounds(.up) {
            movePlayerHelper(.up, completion: completion)
        }
        else if inBounds(.down) {
            movePlayerHelper(.down, completion: completion)
        }
        else if inBounds(.left) {
            movePlayerHelper(.left, completion: completion)
        }
        else if inBounds(.right) {
            movePlayerHelper(.right, completion: completion)
        }
        else {
            //handle default cases here...
        }
        
        //Since argument is inout, remember to set the global variable, self.playerPosition to the playerPosition argument! Put this line last!!!
        playerPosition = self.playerPosition
    }
    
    
    // MARK: - Controls Helper Functions
    
    /**
     Takes a tap location and compares it to the player's next position.
     - parameter direction: The player's next position, either up, down, left, or right
     - returns: true or false, depending on if the requested direction of movement is within the gameboard bounds
     */
    private func inBounds(_ direction: Controls) -> Bool {
        let maxDistance: CGFloat = CGFloat(gameboard.panelCount)
        let panelSize: CGFloat = gameboard.panelSize * UIDevice.spriteScale
        let gameboardSize: CGFloat = panelSize * CGFloat(maxDistance)
        let gameboardOffset: CGPoint = GameboardSprite.offsetPosition
        
        var bottomBound: CGFloat = CGFloat(playerPosition.row) + 1
        var rightBound: CGFloat = CGFloat(playerPosition.col) + 1
        var topBound: CGFloat = CGFloat(playerPosition.row) {
            didSet { topBound = max(0, topBound) }
        }
        var leftBound: CGFloat = CGFloat(playerPosition.col) {
            didSet { leftBound = max(0, leftBound) }
        }
        
        switch direction {
        case .up:
            topBound = -maxDistance
            bottomBound -= 1
        case .down:
            topBound += 1
            bottomBound = maxDistance
        case .left:
            leftBound = -maxDistance
            rightBound -= 1
        case .right:
            leftBound += 1
            rightBound = maxDistance
        default:
            print("Unknown direction in FinalBattle2Controls.inBounds()")
        }
        
        //Finally...
        let locationInsideLeftBound = location.x > gameboardOffset.x + leftBound * panelSize
        let locationInsideRightBound = location.x < gameboardOffset.x + rightBound * panelSize
        let locationInsideBottomBound = location.y > gameboardOffset.y + gameboardSize - bottomBound * panelSize
        let locationInsideTopBound = location.y < gameboardOffset.y + gameboardSize - topBound * panelSize
        
        return locationInsideLeftBound && locationInsideRightBound && locationInsideBottomBound && locationInsideTopBound
    }
    
    private func isValidMove(_ direction: Controls) -> Bool {
        // TODO: - Check if move intersects with villain or any other unforseen obstacle...
        return true
    }
    
    /**
     Physically move the player in the intended direction.
     - parameters:
        - direction: The direction the player would like to move to
        - completion: handler to perform functions upon animation completion
     */
    private func movePlayerHelper(_ direction: Controls, completion: (() -> Void)?) {
        var nextPanel: K.GameboardPosition
        
        switch direction {
        case .up:
            nextPanel = (row: playerPosition.row - 1, col: playerPosition.col)
        case .down:
            nextPanel = (row: playerPosition.row + 1, col: playerPosition.col)
        case .left:
            nextPanel = (row: playerPosition.row, col: playerPosition.col - 1)
            player.sprite.xScale = -abs(player.sprite.xScale)
        case .right:
            nextPanel = (row: playerPosition.row, col: playerPosition.col + 1)
            player.sprite.xScale = abs(player.sprite.xScale)
        default:
            nextPanel = (row: playerPosition.row, col: playerPosition.col)
        }
        
        let runSound = "movetile\(Int.random(in: 1...3))"
        
        playerPosition = nextPanel
        isDisabled = true
        
        AudioManager.shared.playSound(for: runSound)
        
        player.sprite.run(Player.animate(player: player, type: .run))
        player.sprite.run(SKAction.sequence([
            SKAction.wait(forDuration: Player.Texture.run.movementSpeed),
            Player.animate(player: player, type: .idle)
        ]))
        player.sprite.run(SKAction.move(to: gameboard.getLocation(at: nextPanel), duration: Player.Texture.run.movementSpeed)) { [weak self] in
            self?.isDisabled = false
            
            AudioManager.shared.stopSound(for: runSound, fadeDuration: 0.25)
            completion?()
        }
    }
}
