//
//  HintEngine.swift
//  PUZL Boy
//
//  Created by Eddie Char on 11/19/23.
//

import SpriteKit

class HintEngine {
    
    // MARK: - Properties
    
    private let nodeNameArrowHint = "hintarrow"
    static private(set) var hintCount: Int = FIRManager.saveStateModel?.hintCountRemaining ?? 10
    
    //Bools
    private(set) var hintAvailable: Bool = (FIRManager.saveStateModel?.hintAvailable ?? true) && HintEngine.hintCount > 0
    private(set) var hintButtonPressed: Bool = false
    private(set) var canAddToBought: Bool = true
    private var isMatchSolutionAttempt: Bool {
        guard attemptArray.count <= solutionArray.count else { return false }
        
        for (i, direction) in attemptArray.enumerated() {
            if direction != solutionArray[i] {
                return false
            }
        }

        return true
    }
    private var isMatchAttemptBought: Bool {
        guard attemptArray.count == boughtArray.count else { return false }
                
        for (i, direction) in attemptArray.enumerated() {
            if direction != boughtArray[i] {
                return false
            }
        }
        
        return true
    }
    var isAlmostMatchAttemptBought: Bool {
        guard attemptArray.count < boughtArray.count else { return false }

        for (i, direction) in attemptArray.enumerated() {
            if direction != boughtArray[i] {
                return false
            }
        }
        
        return true
    }

    //Arrays
    private(set) var solutionArray: [Controls] = []
    private(set) var attemptArray: [Controls] = [] {
        didSet {
            attemptLabel.text = arrayToString(attemptArray)
            attemptLabel.updateShadow()
        }
    }
    private(set) var boughtArray: [Controls] = [] {
        didSet {
            boughtLabel.text = arrayToString(boughtArray)
            boughtLabel.updateShadow()
        }
    }
    
    //Nodes
    private var solutionLabel: SKLabelNode!
    private var attemptLabel: SKLabelNode!
    private var boughtLabel: SKLabelNode!
    private(set) var sprite: SKSpriteNode!

    
    // MARK: - Initialization
    
    init(solution: String, attempt: String, bought: String, yPos: CGFloat) {
        solutionArray = stringToArray(solution)
        attemptArray = stringToArray(attempt)
        boughtArray = stringToArray(bought)
        canAddToBought = isMatchAttemptBought && HintEngine.hintCount > 0

        setupNodes(solution: solution, attempt: attempt, bought: bought, yPos: yPos)
    }
    
    deinit {
        print("HintEngine deinit")
    }
    
    private func setupNodes(solution: String, attempt: String, bought: String, yPos: CGFloat) {
        solutionLabel = SKLabelNode(text: solution)
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

        attemptLabel = SKLabelNode(text: attempt)
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
        
        boughtLabel = SKLabelNode(text: bought)
        boughtLabel.position = CGPoint(x: K.ScreenDimensions.lrMargin + 20, y: solutionLabel.position.y - 2 * solutionLabel.frame.size.height)
        boughtLabel.horizontalAlignmentMode = .left
        boughtLabel.verticalAlignmentMode = .top
        boughtLabel.numberOfLines = 0
        boughtLabel.preferredMaxLayoutWidth = K.ScreenDimensions.size.width * GameboardSprite.spriteScale
        boughtLabel.fontName = UIFont.chatFont
        boughtLabel.fontSize = UIFont.chatFontSizeSmall
        boughtLabel.fontColor = UIFont.chatFontColor
        boughtLabel.zPosition = 20
        boughtLabel.addDropShadow()
        
        sprite = SKSpriteNode(color: .clear, size: K.ScreenDimensions.size)
        sprite.zPosition = 20
                
        sprite.addChild(solutionLabel)
        sprite.addChild(attemptLabel)
        sprite.addChild(boughtLabel)
    }
    
    
    // MARK: - Functions
    
    @discardableResult func getHint(gameboardSprite: GameboardSprite, playerPosition: K.GameboardPosition, completion: (() -> Void)?) -> Controls? {
        guard hintAvailable else {
            print("HintEngine.getHint(): hintAvailable == false.")
            return nil
        }
        
        guard isMatchSolutionAttempt else {
            print("HintEngine.getHint(): User attempt diverged from solution path.")
            return nil
        }
        
        guard let hint = Array(solutionArray.dropFirst(attemptArray.count)).first else {
            print("HintEngine.getHint(): solutionArray is empty.")
            return nil
        }
        
        guard gameboardSprite.sprite.childNode(withName: nodeNameArrowHint) == nil else {
            print("HintEngine.getHint(): There's already an arrow node. Returning.")
            return nil
        }
        
        
        //Important logic
        removeAnimatingHint(from: gameboardSprite)
        setHintButtonPressed(true)
        
        if canAddToBought {
            boughtArray.append(hint)
            canAddToBought = false
        }
        
        
        //Arrow animation
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
        arrow.zRotation = rotationAngle
        arrow.zPosition = K.ZPosition.itemsAndEffects
        arrow.setScale((1 / GameboardSprite.spriteScale) * (1.8 * 3) / CGFloat(gameboardSprite.panelCount))
        arrow.name = nodeNameArrowHint

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
            //IMPORTANT: Can't be > 0.25s otherwise PUZL Boy may move onto panel faster than arrow can finish animating, so getHint() won't trigger!
            SKAction.fadeOut(withDuration: 0.25),
            SKAction.removeFromParent()
        ]))
    }
    
    
    // MARK: - Getter/Setter Functions
    
    func updateBools(didPurchaseHints: Bool = false) {
        if hintButtonPressed {
            setHintAvailable(isMatchSolutionAttempt && HintEngine.hintCount > 0)
            setCanAddToBought(isMatchAttemptBought && HintEngine.hintCount > 0)
            setHintButtonPressed(false)
        }
        else if didPurchaseHints && (isAlmostMatchAttemptBought || isMatchAttemptBought) {
            setHintAvailable(isMatchSolutionAttempt && HintEngine.hintCount > 0)
            setCanAddToBought(isMatchAttemptBought && HintEngine.hintCount > 0)
        }
        else {
            setHintAvailable(false)
            setCanAddToBought(false)
        }
    }

    func setHintAvailable(_ newValue: Bool) {
        hintAvailable = newValue
    }

    func setHintButtonPressed(_ newValue: Bool) {
        hintButtonPressed = newValue
    }
        
    func setCanAddToBought(_ newValue: Bool) {
        canAddToBought = newValue
    }
    
    func setHintCount(_ newValue: Int) {
        HintEngine.hintCount = newValue
    }
    
    func reduceHintCount() {
        setHintCount(HintEngine.hintCount - 1)
    }
    
    func addToHintCount(valueToAdd addedValue: Int) {
        setHintCount(HintEngine.hintCount + addedValue)
    }
    
    func appendDirection(_ direction: Controls) {
        attemptArray.append(direction)
    }
 
    func dropLastDirection() {
        guard !attemptArray.isEmpty else { return }

        attemptArray.removeLast()
    }
        
    func clearAttempt() {
        attemptArray = []
    }
    
    func checkForMatchSolutionAttempt() {
        attemptLabel.fontColor = isMatchSolutionAttempt ? .green : .red
    }
    
    
    // MARK: - Helper Functions
    
    func arrayToString(_ array: [Controls]) -> String {
        var returnStr: String = ""

        for (i, item) in array.enumerated() {
            returnStr += item.rawValue + (i >= array.count - 1 ? "" : ",")
        }
        
        return returnStr
    }
    
    func stringToArray(_ input: String) -> [Controls] {
        var returnArray: [Controls] = []
        
        guard input.count > 0 else { return returnArray }
        
        for direction in input.components(separatedBy: ",") {
            returnArray.append(Controls(rawValue: direction) ?? .unknown)
        }
        
        return returnArray
    }
}
