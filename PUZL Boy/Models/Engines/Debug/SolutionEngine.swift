//
//  SolutionEngine.swift
//  PUZL Boy
//
//  Created by Eddie Char on 11/19/23.
//

import SpriteKit

class SolutionEngine {
    
    // MARK: - Properties
    
    private let solutionArray: [String]
    private let solutionLabel: SKLabelNode
    private var attemptLabel: SKLabelNode
    let sprite: SKSpriteNode

    private var isMatch: Bool {
        solutionLabel.text == attemptLabel.text
    }

    
    // MARK: - Initialization
    
    init(solution: String, yPos: CGFloat) {
        solutionArray = solution.components(separatedBy: ",")

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
                
        print(solutionArray)
    }
    
    
    // MARK: - Functions
    
    func appendDirection(_ direction: Controls) {
        switch direction {
        case .up:
            attemptLabel.text! += "U,"
        case .down:
            attemptLabel.text! += "D,"
        case .left:
            attemptLabel.text! += "L,"
        case .right:
            attemptLabel.text! += "R,"
        }
        
        attemptLabel.updateShadow()
    }
 
    func dropLastDirection() {
        attemptLabel.text = String(attemptLabel.text!.dropLast(2))
        attemptLabel.updateShadow()
    }
    
    func checkForMatch() {
        attemptLabel.fontColor = isMatch ? .green : .red
    }
    
    func clearAttempt() {
        attemptLabel.text = ""
        attemptLabel.updateShadow()
    }
}
