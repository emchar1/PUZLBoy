//
//  ChapterTitleSprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 7/15/24.
//

import SpriteKit

class ChapterTitleSprite: SKNode {
    
    // MARK: - Properties
    
    static let size = CGSize(width: 1125, height: 410)
    static var scale: CGFloat { (K.ScreenDimensions.size.width - 80) / size.width }
    private let moveY: CGFloat = 200
    private var sprite: SKSpriteNode!
    private var chapter: Int {
        didSet {
            chapter = chapter.clamp(min: 0, max: 4)
        }
    }
    
    
    // MARK: - Initialization
    
    init(chapter: Int) {
        self.chapter = chapter
        
        super.init()
        
        setupNodes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deinit ChapterTitleSprite")
    }
    
    private func setupNodes() {
        sprite = SKSpriteNode(texture: SKTexture(imageNamed: "chapter\(chapter)Title"))
        sprite.position = CGPoint(x: K.ScreenDimensions.size.width / 2, y: K.ScreenDimensions.topOfGameboard - moveY)
        sprite.anchorPoint = CGPoint(x: 0.5, y: 0)
        sprite.size = ChapterTitleSprite.size * ChapterTitleSprite.scale
        sprite.setScale(0.85)
        sprite.alpha = 0
        sprite.zPosition = K.ZPosition.messagePrompt
        sprite.name = "ChapterTitleNode"
        
        addChild(sprite)
    }
    
    
    // MARK: - Functions
    
    func showTitle(completion: (() -> Void)?) {
        let songDuration: TimeInterval = 7
        let animationDuration: TimeInterval = 3
        let fadeDuration: TimeInterval = 1
        var waitDuration: TimeInterval { songDuration - animationDuration - fadeDuration }

        AudioManager.shared.lowerVolume(for: AudioManager.shared.currentTheme)
        AudioManager.shared.playSound(for: "titlechapter")
        
        sprite.run(SKAction.group([
            SKAction.moveBy(x: 0, y: moveY, duration: songDuration),
            SKAction.fadeIn(withDuration: fadeDuration),
            SKAction.sequence([
                SKAction.scale(to: 1, duration: animationDuration),
                SKAction.wait(forDuration: waitDuration),
                SKAction.fadeOut(withDuration: fadeDuration)
            ])
        ])) {
            AudioManager.shared.raiseVolume(for: AudioManager.shared.currentTheme, fadeDuration: 1)
            
            completion?()
        }
    }
    
    func setChapter(_ chapter: Int) {
        self.chapter = chapter
        
        resetSprite()
    }
    
    private func resetSprite() {
        sprite.texture = SKTexture(imageNamed: "chapter\(self.chapter)Title")
        sprite.position = CGPoint(x: K.ScreenDimensions.size.width / 2, y: K.ScreenDimensions.topOfGameboard - moveY)
        sprite.setScale(0.85)
        sprite.alpha = 0
    }
}