//
//  LeaderboardsPage.swift
//  PUZL Boy
//
//  Created by Eddie Char on 10/22/23.
//

import SpriteKit

class LeaderboardsPage: ParentPage {
    
    // MARK: - Properties

    //Nodes
    private var title2Label: SKLabelNode!
    private var loadingLabel: SKLabelNode!
    private var backButton: SKSpriteNode!
    private var headerBackgroundNode: SKShapeNode!
    private var levelLabel: SKLabelNode!
    private var usernameLabel: SKLabelNode!
    private var scoreLabel: SKLabelNode!
    
    //Misc
    private(set) var tableView: LeaderboardsTableView!
    private(set) var leaderboardType: LeaderboardType
    private var currentLevel: Int
    private var originalCurrentLevel: Int
    private var backButtonPressed = false
    
    enum LeaderboardType {
        case all, level
    }
    
    
    // MARK: - Initialization
    
    init(contentSize: CGSize, leaderboardType: LeaderboardType, currentLevel: Int) {
        self.leaderboardType = leaderboardType
        self.currentLevel = currentLevel
        self.originalCurrentLevel = currentLevel

        super.init(contentSize: contentSize, titleText: "All Leaderboards")
        
        self.nodeName = "leaderboardsPage"
        name = nodeName
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        title2Label = SKLabelNode(text: "LV \(currentLevel) - LEADERBOARD")
        title2Label.position = CGPoint(x: contentSize.width / 2, y: -ParentPage.padding)
        title2Label.horizontalAlignmentMode = .center
        title2Label.verticalAlignmentMode = .top
        title2Label.fontName = UIFont.gameFont
        title2Label.fontSize = UIFont.gameFontSizeLarge
        title2Label.fontColor = UIFont.gameFontColor
        title2Label.yScale = -1
        title2Label.alpha = 0
        title2Label.name = "title2Label"
        title2Label.zPosition = 10
        title2Label.addHeavyDropShadow()

        backButton = SKSpriteNode(imageNamed: "backButton")
        backButton.position = CGPoint(x: ParentPage.padding / 2, y: -ParentPage.padding / 2)
        backButton.size = CGSize(width: 80, height: 80)
        backButton.anchorPoint = CGPoint(x: 0, y: 1)
        backButton.alpha = 0
        backButton.color = .black
        backButton.name = "backButton"
        backButton.zPosition = 10
        
        tableView = LeaderboardsTableView(frame: .zero, style: .plain)
        tableView.leaderboardType = leaderboardType
        tableView.leaderboardsTableViewDelegate = self
        
        headerBackgroundNode = SKShapeNode(rectOf: CGSize(width: contentSize.width, height: UIDevice.isiPad ? 80 : 60))
        headerBackgroundNode.position = CGPoint(x: 0, y: contentSize.height / 2 - 2 * headerBackgroundNode.frame.size.height - ParentPage.padding)
        headerBackgroundNode.fillColor = .gray // FIXME: - Use sky colors??
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
        
        updateTitleForLeaderboardType(shouldAnimate: false)
        updateHeadersForLeaderboardType()
        addLoadingLabel()
        
        contentNode.addChild(title2Label)
        contentNode.addChild(backButton)
        headerBackgroundNode.addChild(levelLabel)
        headerBackgroundNode.addChild(usernameLabel)
        headerBackgroundNode.addChild(scoreLabel)
    }
    
    
    // MARK: - Functions
    
    ///Updates the leaderboardType, currentLevel and originalCurrentLevel = currentLevel.
    func updateValues(leaderboardType: LeaderboardType, currentLevel: Int) {
        self.leaderboardType = leaderboardType
        self.currentLevel = currentLevel
        self.originalCurrentLevel = currentLevel
    }
    
    ///Adds the LOADING label to the view.
    func addLoadingLabel() {
        removeLoadingLabel()
        
        addChild(loadingLabel)
    }
    
    ///Removes the LOADING label from the view.
    func removeLoadingLabel() {
        loadingLabel.removeFromParent()
    }
    
    ///Adds the tableView headers to the view.
    func addHeaderBackgroundNode() {
        removeHeaderBackgroundNode()
        
        addChild(headerBackgroundNode)
    }
    
    ///Removes the tableView headers from the view.
    func removeHeaderBackgroundNode() {
        headerBackgroundNode.removeFromParent()
    }
    
    ///Adds the LOADING label and removes the tableView headers from the view. Also hides the tableView by setting its alpha = 0.
    func prepareTableView() {
        updateTitleForLeaderboardType(shouldAnimate: true)
        addLoadingLabel()
        removeHeaderBackgroundNode()
        
        tableView.alpha = 0
    }
    
    ///Removes the LOADING label and adds the tableView headers to the view. Also shows the tableView by setting its alpha = 1.
    func didLoadTableView(scores: [GameCenterManager.Score]) {
        updateHeadersForLeaderboardType()
        removeLoadingLabel()
        addHeaderBackgroundNode()
        
        tableView.scores = scores
        tableView.leaderboardType = leaderboardType
        tableView.flashScrollIndicators()
        tableView.reloadData()
        
        if leaderboardType == .all {
            tableView.scrollToRow(at: IndexPath(row: scores.count - 1, section: 0), at: .bottom, animated: true)
        }
        else {
            backButton.alpha = 1
        }
        
        tableView.alpha = 1
    }
    
    ///Switches the leaderboard based on the type, i.e. All Leaderboards or level-specific Leaderboard. Updates the title, table view headers and table view itself.
    private func switchLeaderboard(toSecondary: Bool) {
        leaderboardType = toSecondary ? .level : .all
        
        prepareTableView()

        if leaderboardType == .all {
            currentLevel = originalCurrentLevel
        }
        
        GameCenterManager.shared.loadScores(leaderboardType: leaderboardType, level: currentLevel) { [unowned self] scores in
            didLoadTableView(scores: scores)
        }
    }
    
    ///Updates the table view headers based on leaderboardType.
    private func updateHeadersForLeaderboardType() {
        switch leaderboardType {
        case .all:
            levelLabel.text = "Lvl"
            usernameLabel.text = "Top Player"
        case .level:
            levelLabel.text = "Rank"
            usernameLabel.text = "Player"
        }
        
        levelLabel.updateShadow()
        usernameLabel.updateShadow()
    }
    
    ///Helper function that updates the title based on the leaderboard type, and applies an animation, if indicated.
    private func updateTitleForLeaderboardType(shouldAnimate: Bool) {
        let duration: CGFloat = shouldAnimate ? 0.5 : 0
        let timingMode: SKActionTimingMode = .easeOut
        
        let rotateUpsideDown = SKAction.group([
            SKAction.moveTo(y: -ParentPage.padding - titleLabel.frame.height, duration: duration),
            SKAction.scaleY(to: -1, duration: duration)
        ])
        let rotateRightsideUp = SKAction.group([
            SKAction.moveTo(y: -ParentPage.padding, duration: duration),
            SKAction.scaleY(to: 1, duration: duration)
        ])
        let fadeIn = SKAction.fadeIn(withDuration: duration)
        let fadeOut = SKAction.fadeOut(withDuration: duration)
        
        rotateUpsideDown.timingMode = timingMode
        rotateRightsideUp.timingMode = timingMode
        fadeIn.timingMode = timingMode
        fadeOut.timingMode = timingMode
        
        switch leaderboardType {
        case .all:
            titleLabel.run(SKAction.group([rotateRightsideUp, fadeIn]))
            title2Label.run(SKAction.group([rotateUpsideDown, fadeOut]))

            backButton.alpha = 0
        case .level:
            title2Label.run(SKAction.group([rotateRightsideUp, fadeIn]))
            titleLabel.run(SKAction.group([rotateUpsideDown, fadeOut]))
            
            title2Label.text = "LV \(currentLevel) - LEADERBOARD"
            title2Label.updateShadow()
        }
    }
    
    
    // MARK: - Touch Functions
    
    override func touchDown(for touches: Set<UITouch>) {
        super.touchDown(for: touches)
        
        guard let superScene = superScene else { return }
        guard let tapLocation = touches.first?.location(in: superScene) else { return }
        let convertedPoint = superScene.convert(tapLocation, to: contentNode)
        guard contentNode.nodes(at: convertedPoint).filter({ $0.name == "backButton" }).first != nil else { return }
        
        backButtonPressed = true
        backButton.colorBlendFactor = 0.25
    }
    
    override func touchNode(for touches: Set<UITouch>) {
        super.touchNode(for: touches)
        
        guard backButtonPressed else { return }
        guard let superScene = superScene else { return }
        guard let tapLocation = touches.first?.location(in: superScene) else { return }
        let convertedPoint = superScene.convert(tapLocation, to: contentNode)
        guard contentNode.nodes(at: convertedPoint).filter({ $0.name == "backButton" }).first != nil else { return }

        ButtonTap.shared.tap(type: .buttontap6)
        switchLeaderboard(toSecondary: false)
    }
    
    override func touchUp() {
        super.touchUp()
        
        backButton.colorBlendFactor = 0
        backButtonPressed = false
    }
}


// MARK: - LeaderboardsTableViewDelegate

extension LeaderboardsPage: LeaderboardsTableViewDelegate {
    func didTapRow(scoreEntry: GameCenterManager.Score) {
        ButtonTap.shared.tap(type: .buttontap2)

        currentLevel = scoreEntry.level
        switchLeaderboard(toSecondary: true)
    }
}
