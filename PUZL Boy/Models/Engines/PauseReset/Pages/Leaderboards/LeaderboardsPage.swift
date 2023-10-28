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
    
    var leaderboardType: LeaderboardType {
        didSet {
            updateHeadersForLeaderboardType()
        }
    }
    
    var currentLevel: Int {
        didSet {
            updateHeadersForLeaderboardType()
        }
    }

    enum LeaderboardType {
        case all, level
    }
    
    // MARK: - Initialization
    
    init(contentSize: CGSize, leaderboardType: LeaderboardType, currentLevel: Int) {
        self.leaderboardType = leaderboardType
        self.currentLevel = currentLevel

        super.init(contentSize: contentSize, titleText: "All Leaderboards")
        
        self.nodeName = "leaderboardsPage"
        name = nodeName
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        tableView = LeaderboardsTableView(frame: .zero, style: .plain)
        tableView.leaderboardType = leaderboardType
        tableView.leaderboardsTableViewDelegate = self
        
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
        levelLabel.zPosition = 5
        levelLabel.addDropShadow()
        
        usernameLabel = SKLabelNode(text: "Top Player")
        usernameLabel.position = CGPoint(x: -contentSize.width / 2 + labelPadding + (UIDevice.isiPad ? 140 : 120), y: UIDevice.isiPad ? -8 : -4)
        usernameLabel.fontName = UIFont.chatFont
        usernameLabel.fontSize = UIFont.chatFontSizeLarge
        usernameLabel.fontColor = UIFont.chatFontColor
        usernameLabel.horizontalAlignmentMode = .left
        usernameLabel.verticalAlignmentMode = .center
        usernameLabel.zPosition = 5
        usernameLabel.addDropShadow()
        
        scoreLabel = SKLabelNode(text: "Score")
        scoreLabel.position = CGPoint(x: contentSize.width / 2 - labelPadding, y: 0)
        scoreLabel.fontName = UIFont.chatFont
        scoreLabel.fontSize = UIFont.chatFontSizeLarge
        scoreLabel.fontColor = UIFont.chatFontColor
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.zPosition = 5
        scoreLabel.addDropShadow()
        
        loadingLabel = SKLabelNode(text: "LOADING...")
        loadingLabel.position = .zero
        loadingLabel.fontName = UIFont.gameFont
        loadingLabel.fontSize = UIFont.gameFontSizeLarge
        loadingLabel.fontColor = UIFont.gameFontColor
        loadingLabel.horizontalAlignmentMode = .center
        loadingLabel.verticalAlignmentMode = .center
        loadingLabel.addDropShadow()
        
        loadingLabel.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.fadeIn(withDuration: 0.5)
        ])))
        
        updateHeadersForLeaderboardType()
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
    
    func prepareTableView() {
        addLoadingLabel()
        removeHeaderBackgroundNode()
    }
    
    func didLoadTableView() {
        removeLoadingLabel()
        addHeaderBackgroundNode()
    }
    
    private func updateHeadersForLeaderboardType() {
        switch leaderboardType {
        case .all:
            updateTitle("All Leaderboards")
            
            levelLabel.text = "Lvl"
            usernameLabel.text = "Top Player"
        case .level:
            updateTitle("Lv \(currentLevel) - Leaderboard")
            
            levelLabel.text = "Rank"
            usernameLabel.text = "Player"
        }
        
        levelLabel.updateShadow()
        usernameLabel.updateShadow()
    }
}


// MARK: - LeaderboardsTableViewDelegate

extension LeaderboardsPage: LeaderboardsTableViewDelegate {
    func didTapRow(scoreEntry: GameCenterManager.Score) {
        // TODO: - Build this out!
        
        print("It's about to go down!")
    }
}
