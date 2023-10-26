//
//  LeaderboardsPage.swift
//  PUZL Boy
//
//  Created by Eddie Char on 10/22/23.
//

import SpriteKit

class LeaderboardsPage: ParentPage {
    
    // MARK: - Properties
    
    private(set) var tableView: LeaderboardsTableView!
    private var headerBackgroundNode: SKShapeNode!
    private var levelLabel: SKLabelNode!
    private var usernameLabel: SKLabelNode!
    private var scoreLabel: SKLabelNode!
    private var loadingLabel: SKLabelNode!
    
    
    // MARK: - Initialization
    
    init(contentSize: CGSize) {
        super.init(contentSize: contentSize, titleText: "Leaderboards")
        
        self.nodeName = "leaderboardsPage"
        name = nodeName
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        tableView = LeaderboardsTableView(frame: .zero, style: .plain)
        
        headerBackgroundNode = SKShapeNode(rectOf: CGSize(width: contentSize.width, height: UIDevice.isiPad ? 80 : 60))
        headerBackgroundNode.position = CGPoint(x: 0, y: contentSize.height / 2 - 2 * headerBackgroundNode.frame.size.height - ParentPage.padding)
        headerBackgroundNode.fillColor = .gray
        headerBackgroundNode.lineWidth = 0
                
        let labelPadding: CGFloat = UIDevice.isiPad ? 64 : 32
        
        levelLabel = SKLabelNode(text: "Lvl")
        levelLabel.position = CGPoint(x: -contentSize.width / 2 + labelPadding, y: 0)
        levelLabel.fontName = UIFont.chatFont
        levelLabel.fontSize = UIFont.chatFontSizeLarge
        levelLabel.fontColor = UIFont.chatFontColor
        levelLabel.horizontalAlignmentMode = .left
        levelLabel.verticalAlignmentMode = .center
        levelLabel.addDropShadow()
        
        usernameLabel = SKLabelNode(text: "Top Player")
        usernameLabel.position = CGPoint(x: -contentSize.width / 2 + labelPadding + (UIDevice.isiPad ? 140 : 120), y: UIDevice.isiPad ? -8 : -4)
        usernameLabel.fontName = UIFont.chatFont
        usernameLabel.fontSize = UIFont.chatFontSizeLarge
        usernameLabel.fontColor = UIFont.chatFontColor
        usernameLabel.horizontalAlignmentMode = .left
        usernameLabel.verticalAlignmentMode = .center
        usernameLabel.addDropShadow()
        
        scoreLabel = SKLabelNode(text: "Score")
        scoreLabel.position = CGPoint(x: contentSize.width / 2 - labelPadding, y: 0)
        scoreLabel.fontName = UIFont.chatFont
        scoreLabel.fontSize = UIFont.chatFontSizeLarge
        scoreLabel.fontColor = UIFont.chatFontColor
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.addDropShadow()
        
        loadingLabel = SKLabelNode(text: "LOADING...")
        loadingLabel.position = .zero
        loadingLabel.fontName = UIFont.gameFont
        loadingLabel.fontSize = UIFont.gameFontSizeLarge
        loadingLabel.fontColor = UIFont.gameFontColor
        loadingLabel.horizontalAlignmentMode = .center
        loadingLabel.verticalAlignmentMode = .center
        loadingLabel.addDropShadow()

        addLoadingLabel()
        
        headerBackgroundNode.addChild(levelLabel)
        headerBackgroundNode.addChild(usernameLabel)
        headerBackgroundNode.addChild(scoreLabel)
    }
    
    
    // MARK: - Functions
    
    func addLoadingLabel() {
        removeLoadingLabel()
        
        addChild(loadingLabel)
    }
    
    func removeLoadingLabel() {
        loadingLabel.removeFromParent()
    }
    
    func addHeaderBackgroundNode() {
        removeHeaderBackgroundNode()
        
        addChild(headerBackgroundNode)
    }
    
    func removeHeaderBackgroundNode() {
        headerBackgroundNode.removeFromParent()
    }
}
