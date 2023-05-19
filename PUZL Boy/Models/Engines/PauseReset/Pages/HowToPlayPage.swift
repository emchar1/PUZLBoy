//
//  HowToPlayPage.swift
//  PUZL Boy
//
//  Created by Eddie Char on 5/10/23.
//

import SpriteKit

class HowToPlayPage: ParentPage {
    
    // MARK: - Properties
    
    private let maxPositionChange: CGFloat = 50
    private var isPressed = false
    private var initialYPosition: CGFloat?
    private var finalYPosition: CGFloat?
    private var positionChange: CGFloat {
        guard let finalYPosition = finalYPosition, let initialYPosition = initialYPosition else { return 0 }

        return min(max(-maxPositionChange, finalYPosition - initialYPosition), maxPositionChange)
    }
    
    private var howToPlayNodes: [HowToPlayNode] = []
    private var currentLevel: Int!
    private var maskSize: CGSize!
    private var cropNode: SKCropNode!
    private var maskNode: SKSpriteNode!
    
    
    // MARK: - Initialization
    
    init(maskSize: CGSize, level: Int) {
        let content = CGSize(width: maskSize.width, height: maskSize.height * 5)

        super.init(contentSize: content, titleText: "How To Play")

        self.currentLevel = level
        self.maskSize = maskSize
        self.contentSize = content
        
        maskNode = SKSpriteNode(color: .magenta, size: maskSize)
        maskNode.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        maskNode.name = "maskNode"

        cropNode = SKCropNode()
        cropNode.position = CGPoint(x: 0, y: maskSize.height / 2)
        cropNode.maskNode = maskNode
        
        contentNode.color = .green
                
        name = nodeName
        
        let terrainLabel = SKLabelNode(text: "TERRAIN\n")
        terrainLabel.position = CGPoint(x: padding, y: calculateYOffsetForContent(row: 0, hintType: .terrain) + 20)
        terrainLabel.horizontalAlignmentMode = .left
        terrainLabel.verticalAlignmentMode = .bottom
        terrainLabel.numberOfLines = 0
        terrainLabel.fontName = UIFont.gameFont
        terrainLabel.fontSize = UIFont.gameFontSizeMedium
        terrainLabel.fontColor = UIFont.gameFontColor
        terrainLabel.zPosition = 10
        terrainLabel.addDropShadow()

        let overlayLabel = SKLabelNode(text: "OVERLAYS\n")
        overlayLabel.position = CGPoint(x: padding, y: calculateYOffsetForContent(row: 8, hintType: .overlay) + 20)
        overlayLabel.horizontalAlignmentMode = .left
        overlayLabel.verticalAlignmentMode = .bottom
        overlayLabel.numberOfLines = 0
        overlayLabel.fontName = UIFont.gameFont
        overlayLabel.fontSize = UIFont.gameFontSizeMedium
        overlayLabel.fontColor = UIFont.gameFontColor
        overlayLabel.zPosition = 10
        overlayLabel.addDropShadow()

        addChild(cropNode)
        cropNode.addChild(contentNode)
        contentNode.addChild(super.titleLabel)
        contentNode.addChild(terrainLabel)
        contentNode.addChild(overlayLabel)
        
        loadContent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///Adds the how to play instructions. Order of adding the hints MATTER! DON'T CHANGE THIS ORDERING!!!
    private func loadContent() {
        
        //TERRAIN Hints
        loadContentHelper(imageName: "start", title: "Start", hintType: .terrain, requiredLevel: 0,
                          description: "Your starting point. PUZL Boy begins each level on this panel.")
        
        loadContentHelper(imageName: "endClosed", title: "End", hintType: .terrain, requiredLevel: 0,
                          description: "Your ending point. You'll need to collect all the gems to open the gate and move on to the next level.")
        
        loadContentHelper(imageName: "grass", title: "Grass", hintType: .terrain, requiredLevel: 0,
                          description: "Your typical terrain. Stepping on grass will cost you 1 move. Diagonal moves are not allowed.")
        
        loadContentHelper(imageName: "marsh", title: "Poison Marsh", hintType: .terrain, requiredLevel: 19,
                          description: "This crimson colored panel will cost you 2 moves if you're so unlucky to wander into it.")
        
        loadContentHelper(imageName: "ice", title: "Ice", hintType: .terrain, requiredLevel: 76,
                          description: "Walking on this will cause you to slide for only 1 move until you hit an obstacle or other terrain.")
        
        loadContentHelper(imageName: "partytile", title: "Rainbow", hintType: .terrain, requiredLevel: 100,
                          description: "These tiles don't take up any moves and are here for your enjoyment. Run around to your heart's content!")

        loadContentHelper(imageName: "sand", title: "Sand", hintType: .terrain, requiredLevel: 351,
                          description: "Once you move off of a sand panel, it'll turn into lava, so retracing your steps is a huge no no.")
        
        loadContentHelper(imageName: "lava", title: "Lava", hintType: .terrain, requiredLevel: 351,
                          description: "Just like in real life, lava is SUPER hot. Tread here accidentally and it's instant death. ☠️")
                
        
        //OVERLAY Hints
        loadContentHelper(imageName: "gem", title: "Gem", hintType: .overlay, requiredLevel: 1,
                          description: "Collect all the gems in each level to open the gate and advance to the next level.")
        
        loadContentHelper(imageName: "boulder", title: "Boulder", hintType: .overlay, requiredLevel: 8,
                          description: "Boulders block you from passing through. Find a hammer and smash them to bits.")
        
        loadContentHelper(imageName: "hammer", title: "Hammer", hintType: .overlay, requiredLevel: 12,
                          description: "Hammers can break boulders to clear a path. One hammer can break only one boulder.")
        
        loadContentHelper(imageName: "warp", title: "Yellow Warp", hintType: .overlay, requiredLevel: 34,
                          description: "Stepping on a warp will transport you to the other warp, and vice versa. Don't ask me how it works.")
        
        loadContentHelper(imageName: "enemy", title: "Dragon", hintType: .overlay, requiredLevel: 51,
                          description: "Like boulders, dragons block your path. Unlike boulders, if you touch a dragon, it'll cost you 1 health.")
        
        loadContentHelper(imageName: "sword", title: "Sword", hintType: .overlay, requiredLevel: 53,
                          description: "A sword can dispatch a dragon effectively to clear a path so you can proceed.")
        
        loadContentHelper(imageName: "gemparty", title: "Party Gem", hintType: .overlay, requiredLevel: 100,
                          description: "Collect party gems to earn extra lives. Sooo shiny!")

        loadContentHelper(imageName: "heart", title: "Heart", hintType: .overlay, requiredLevel: 151,
                          description: "Hearts increase your health, protecting against dragon attacks. If your health hits 0 it's game over.")
        
        loadContentHelper(imageName: "warp2", title: "Green Warp", hintType: .overlay, requiredLevel: 251,
                          description: "Just like the Yellow Warp, the Green Warp will teleport you to the next Green Warp. Color coding yeah!")
        
        loadContentHelper(imageName: "warp3", title: "Blue Warp", hintType: .overlay, requiredLevel: 401,
                          description: "As if two warps aren't enough, the Blue Warp takes you to, you guessed it, the other Blue Warp.")
    }
        
    private func loadContentHelper(imageName: String, title: String, hintType: HowToPlayNode.HintType, requiredLevel: Int, description: String) {
        let howToPlayNode = HowToPlayNode(imageName: imageName,
                                          titleText: title,
                                          hintType: hintType,
                                          currentLevel: currentLevel,
                                          requiredLevel: requiredLevel,
                                          nodeWidth: maskSize.width - 2 * padding,
                                          descriptionText: description)
        
        howToPlayNode.position = CGPoint(x: padding, y: calculateYOffsetForContent(row: howToPlayNodes.count, hintType: hintType))
        
        howToPlayNodes.append(howToPlayNode)
        contentNode.addChild(howToPlayNode)
    }
    
    private func calculateYOffsetForContent(row: Int, hintType: HowToPlayNode.HintType) -> CGFloat {
        let topSpacing: CGFloat = hintType == .terrain ? 220 : 400
        
        return -CGFloat(row + 1) * padding - topSpacing - CGFloat(row) * HowToPlayNode.iconSize
    }

    
    // MARK: - Touch Functions
    
    override func touchDown(at location: CGPoint) {
        super.touchDown(at: location)
        
        isPressed = true
        
        initialYPosition = location.y
    }
    
    override func touchUp() {
        super.touchUp()
        
        isPressed = false

        if contentNode.position.y <= 0 {
            moveContentNode(to: 0, duration: 0.25)
        }
        else if contentNode.position.y >= contentSize.height - maskSize.height {
            moveContentNode(to: contentSize.height - maskSize.height, duration: 0.25)
        }

        initialYPosition = nil
        finalYPosition = nil
    }
    
    func moveContentNode(to y: CGFloat, duration: TimeInterval) {
        contentNode.run(SKAction.moveTo(y: y, duration: duration))
    }
    
    func scrollNode(to location: CGPoint) {
        guard isPressed else { return }
        guard initialYPosition != nil else { return }

        let scrollThreshold: CGFloat = 40

        finalYPosition = location.y

        if contentNode.position.y <= -scrollThreshold && positionChange <= -maxPositionChange {
            contentNode.position.y += -1
        }
        else if contentNode.position.y >= contentSize.height - maskSize.height + scrollThreshold && positionChange >= maxPositionChange {
            contentNode.position.y += 1
        }
        else {
            contentNode.position.y += positionChange
        }
    }
    
    
    // MARK: - Functions
    
    func updatLabels(level: Int) {
        for node in howToPlayNodes {
            node.updateLabels(level: level)
        }
    }
}
