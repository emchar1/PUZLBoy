//
//  FinalBattle2Controls.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/21/24.
//

import SpriteKit

protocol FinalBattle2ControlsDelegate: AnyObject {
    func didHeroAttack(chosenSword: ChosenSword)
}

class FinalBattle2Controls {
    
    // MARK: - Properties
    
    private var gameboard: GameboardSprite
    private var player: Player
    private var villain: Player
    private var playerPosition: K.GameboardPosition
    private var villainPosition: K.GameboardPosition
    private var chosenSword: ChosenSword
    
    //These get set every time in handleControls()
    private var location: CGPoint!
    private var villainPositionNew: K.GameboardPosition!
    private var safePanelFound: Bool!
    
    private var isDisabled: Bool
    private var canAttack: Bool
    
    weak var delegate: FinalBattle2ControlsDelegate?
    
    
    // MARK: - Initialization
    
    init(gameboard: GameboardSprite, player: Player, villain: Player, playerPosition: K.GameboardPosition, villainPosition: K.GameboardPosition) {
        self.gameboard = gameboard
        self.player = player
        self.villain = villain
        self.playerPosition = playerPosition
        self.villainPosition = villainPosition
        
        self.isDisabled = false
        self.canAttack = true
        
        chosenSword = ChosenSword(didPursueMagmoor: FIRManager.didPursueMagmoor,
                                  didGiveAwayFeather: FIRManager.didGiveAwayFeather,
                                  bravery: FIRManager.bravery)
        chosenSword.spriteNode.setScale(gameboard.panelSize / chosenSword.spriteNode.size.width)
        chosenSword.spriteNode.zPosition = K.ZPosition.itemsAndEffects
    }
    
    deinit {
        print("deinit FinalBattle2Controls")
    }
    
    
    // MARK: - Functions
    
    /**
     Handles player movement based on control input.
     - parameters:
        - location: location for which comparison is to occur
        - playerPosition: the player's position, which will be overridden becuase it's an inout parameter
        - villainPosition: the villain's (inout) position
        - safePanelFound: returns true if a safe panel i.e. sand/snow is found in the player's position
        - completion: handler to perform tasks upon completion
     */
    func handleControls(in location: CGPoint, playerPosition: inout K.GameboardPosition, villainPosition: inout K.GameboardPosition, safePanelFound: Bool, completion: (() -> Void)?) {
        guard !isDisabled else { return }
        
        self.location = location
        self.safePanelFound = safePanelFound
        
        //Villain's new spawn position cannot be where player position or start position are!
        repeat {
            villainPositionNew = (Int.random(in: 0...gameboard.panelCount - 1), Int.random(in: 0...gameboard.panelCount - 1))
        } while villainPositionNew == playerPosition || villainPositionNew == FinalBattle2Engine.startPosition
        
        //Now check for movement/attack!
        if inBounds(.up) && !canAttackVillain(.up) {
            movePlayerHelper(.up, completion: completion)
        }
        else if inBounds(.down) && !canAttackVillain(.down) {
            movePlayerHelper(.down, completion: completion)
        }
        else if inBounds(.left) && !canAttackVillain(.left) {
            movePlayerHelper(.left, completion: completion)
        }
        else if inBounds(.right) && !canAttackVillain(.right) {
            movePlayerHelper(.right, completion: completion)
        }
        else {
            //handle default cases here...
        }
        
        //Since these arguments are inout, remember to set the global variables! Put these lines last!!!
        playerPosition = self.playerPosition
        villainPosition = villainPositionNew
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
    
    private func getNextPanel(direction: Controls) -> K.GameboardPosition {
        let nextPanel: K.GameboardPosition
        
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
        
        return nextPanel
    }
    
    private func canAttackVillain(_ direction: Controls) -> Bool {
        let attackPanel: K.GameboardPosition = getNextPanel(direction: direction)
        
        guard attackPanel == villainPosition else { return false }
        
        if (safePanelFound || playerPosition == FinalBattle2Engine.startPosition || playerPosition == FinalBattle2Engine.endPosition) && canAttack {
            isDisabled = true
            canAttack = false
            
            gameboard.sprite.addChild(chosenSword.spriteNode)
            
            chosenSword.spriteNode.position = gameboard.getLocation(at: villainPosition)
            chosenSword.attack { [weak self] in
                guard let self = self else { return }
                
                isDisabled = false
                
                moveVillainHelper()
            }
            
            delegate?.didHeroAttack(chosenSword: chosenSword)
        }
                
        return true
    }
    
    /**
     Physically move the player in the intended direction.
     - parameters:
     - direction: The direction the player would like to move to
     - completion: handler to perform functions upon animation completion
     */
    private func movePlayerHelper(_ direction: Controls, completion: (() -> Void)?) {
        let nextPanel: K.GameboardPosition = getNextPanel(direction: direction)
        let panelType = gameboard.getUserDataForLevelType(sprite: gameboard.getPanelSprite(at:playerPosition).terrain!)
        let runSound: String
        
        if safePanelFound {
            runSound = FireIceTheme.isFire ? "movesand\(Int.random(in: 1...3))" : "movesnow\(Int.random(in: 1...3))"
        }
        else {
            switch panelType {
            case .lava, .water:
                runSound = "movemarsh\(Int.random(in: 1...3))"
            default:
                runSound = "movetile\(Int.random(in: 1...3))"
            }
        }
        
        print("panelType: \(panelType)")
        
        isDisabled = true
        playerPosition = nextPanel
        
        AudioManager.shared.playSound(for: runSound)
        
        //First, run animation...
        player.sprite.run(Player.animate(player: player, type: .run))
        
        //Wait, then idle animation...
        player.sprite.run(SKAction.sequence([
            SKAction.wait(forDuration: Player.Texture.run.movementSpeed),
            Player.animate(player: player, type: .idle)
        ]))
        
        //In between, move player and completion...
        player.sprite.run(SKAction.move(to: gameboard.getLocation(at: nextPanel), duration: Player.Texture.run.movementSpeed)) { [weak self] in
            self?.isDisabled = false
            
            AudioManager.shared.stopSound(for: runSound, fadeDuration: 0.25)
            completion?()
        }
    }
    
    /**
     Helper function to assist with moving the villain after he's been attacked by the hero.
     */
    private func moveVillainHelper() {
        let fadeDistance = CGPoint(x: 0, y: gameboard.panelSize) + FinalBattle2Engine.villainFloatOffset
        let fadeDuration: TimeInterval = 2
        let waitDuration = TimeInterval.random(in: 2...6)
        let villainDirection: CGFloat = CGFloat(villainPositionNew.col) < CGFloat(gameboard.panelCount) / 2 ? 1 : -1
        
        villainPosition = villainPositionNew

        villain.sprite.run(SKAction.sequence([
            SKAction.group([
                SKAction.moveBy(x: fadeDistance.x, y: fadeDistance.y, duration: fadeDuration),
                SKAction.fadeOut(withDuration: fadeDuration)
            ]),
            SKAction.wait(forDuration: waitDuration),
            Player.moveWithIllusions(playerNode: villain.sprite,
                                     backgroundNode: gameboard.sprite,
                                     color: .black,
                                     playSound: true,
                                     startPoint: villain.sprite.position + fadeDistance,
                                     endPoint: gameboard.getLocation(at: villainPositionNew) + FinalBattle2Engine.villainFloatOffset,
                                     startScale: 1,
                                     endScale: 1),
            SKAction.move(to: gameboard.getLocation(at: villainPositionNew) + FinalBattle2Engine.villainFloatOffset, duration: 0),
            SKAction.scaleX(to: villainDirection * abs(villain.sprite.xScale), duration: 0),
            SKAction.fadeIn(withDuration: 0)
        ])) { [weak self] in
            guard let self = self else { return }
            
            canAttack = true
        }
        
        ParticleEngine.shared.animateParticles(type: .magmoorBamf,
                                               toNode: villain.sprite,
                                               position: .zero,
                                               scale: 3,
                                               duration: 2)
    }
    
    
}
