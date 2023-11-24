//
//  SolutionEngine.swift
//  PUZL Boy
//
//  Created by Eddie Char on 11/19/23.
//

import SpriteKit

class SolutionEngine {
    
    // MARK: - Properties
    
    private var solutionArray: [Controls]
    private var attemptArray: [Controls]
    private let nodeNameArrowHint = "hintarrow"
    private let solutionLabel: SKLabelNode
    private var attemptLabel: SKLabelNode
    let sprite: SKSpriteNode

    private var isMatch: Bool {
        for (i, direction) in attemptArray.enumerated() {
            if direction != solutionArray[i] { 
                return false
            }
        }

        return true
    }

    
    // MARK: - Initialization
    
    init(solution: String, yPos: CGFloat) {
        solutionArray = []
        attemptArray = []

        for direction in solution.components(separatedBy: ",") {
            solutionArray.append(Controls(rawValue: direction) ?? .unknown)
        }

        solutionLabel = SKLabelNode(text: "\(solution),")
        solutionLabel.position = CGPoint(x: K.ScreenDimensions.lrMargin + 20, y: yPos - 8)
        solutionLabel.horizontalAlignmentMode = .left
        solutionLabel.verticalAlignmentMode = .top
        solutionLabel.numberOfLines = 0
        solutionLabel.preferredMaxLayoutWidth = K.ScreenDimensions.size.width * GameboardSprite.spriteScale
        solutionLabel.fontName = UIFont.chatFont
        solutionLabel.fontSize = UIFont.chatFontSizeSmall
        solutionLabel.fontColor = UIFont.chatFontColor
        solutionLabel.zPosition = 20
        solutionLabel.addDropShadow()

        // FIXME: - Debug
        attemptLabel = SKLabelNode(text: "")
        attemptLabel.position = CGPoint(x: K.ScreenDimensions.lrMargin + 20, y: solutionLabel.position.y - solutionLabel.frame.size.height)
        attemptLabel.horizontalAlignmentMode = .left
        attemptLabel.verticalAlignmentMode = .top
        attemptLabel.numberOfLines = 0
        attemptLabel.preferredMaxLayoutWidth = K.ScreenDimensions.size.width * GameboardSprite.spriteScale
        attemptLabel.fontName = UIFont.chatFont
        attemptLabel.fontSize = UIFont.chatFontSizeSmall
        attemptLabel.fontColor = UIFont.chatFontColor
        attemptLabel.zPosition = 20
        attemptLabel.addDropShadow()
        
        sprite = SKSpriteNode(color: .clear, size: K.ScreenDimensions.size)
        sprite.zPosition = 20

        sprite.addChild(solutionLabel)
        sprite.addChild(attemptLabel)
    }
    
    
    // MARK: - Functions
    
    func getHint(gameboardSprite: GameboardSprite, playerPosition: K.GameboardPosition, completion: (() -> Void)?) -> Controls? {
        guard isMatch else {
            print("SolutionEngine.getHint(): User attempt diverged from solution path.")
            return nil
        }
        
        guard solutionArray.count >= attemptArray.count else {
            print("SolutionEngine.getHint(): solutionArray is too small.")
            return nil
        }
        
        guard let hint = Array(solutionArray.dropFirst(attemptArray.count)).first else {
            print("SolutionEngine.getHint: solutionArray is empty.")
            return nil
        }
        
        guard gameboardSprite.sprite.childNode(withName: nodeNameArrowHint) == nil else {
            print("There's already an arrow node. Returning.")
            return nil
        }
        
        removeAnimatingHint(from: gameboardSprite)
        
        let positionOffset: K.GameboardPosition
        let rotationAngle: CGFloat

        switch hint {
        case .up:
            positionOffset = (row: -1, col: 0)
            rotationAngle = -.pi / 2
        case .down:
            positionOffset = (row: 1, col: 0)
            rotationAngle = .pi / 2
        case .left:
            positionOffset = (row: 0, col: -1)
            rotationAngle = 0
        case .right:
            positionOffset = (row: 0, col: 1)
            rotationAngle = .pi
        default:
            positionOffset = (row: 0, col: 0)
            rotationAngle = 0
        }
        
        let arrow = SKSpriteNode(imageNamed: nodeNameArrowHint)
        arrow.position = gameboardSprite.getLocation(at: (row: playerPosition.row + positionOffset.row, col: playerPosition.col + positionOffset.col))
        arrow.zPosition = K.ZPosition.itemsAndEffects
        arrow.setScale(2 * 3 / CGFloat(gameboardSprite.panelCount))
        arrow.name = nodeNameArrowHint
        arrow.run(SKAction.rotate(byAngle: rotationAngle, duration: 0))

        gameboardSprite.sprite.addChild(arrow)
        
        let blinkAction = SKAction.sequence([
            SKAction.run {
                AudioManager.shared.stopSound(for: "arrowblink")
                AudioManager.shared.playSound(for: "arrowblink")
            },
            SKAction.fadeIn(withDuration: 0),
            SKAction.wait(forDuration: 0.5),
            SKAction.fadeOut(withDuration: 0.5)
        ])
        
        arrow.run(SKAction.sequence([
            blinkAction,
            blinkAction,
            blinkAction,
            SKAction.removeFromParent()
        ])) {
            completion?()
        }

        return hint
    }
    
    func removeAnimatingHint(from gameboardSprite: GameboardSprite) {
        guard let lastArrow = gameboardSprite.sprite.childNode(withName: nodeNameArrowHint) else { return }

        lastArrow.removeAllActions()
        
        lastArrow.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0),
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.removeFromParent()
        ]))
    }
    
    func appendDirection(_ direction: Controls) {
        attemptLabel.text! += direction.rawValue + ","
        attemptLabel.updateShadow()
        
        attemptArray.append(direction)
    }
 
    func dropLastDirection() {
        attemptLabel.text = String(attemptLabel.text!.dropLast(2))
        attemptLabel.updateShadow()
        
        if !attemptArray.isEmpty {
            attemptArray.removeLast()
        }
    }
    
    func checkForMatch() {
        attemptLabel.fontColor = isMatch ? .green : .red
    }
    
    func clearAttempt() {
        attemptLabel.text = ""
        attemptLabel.updateShadow()
        
        attemptArray = []
    }
}
