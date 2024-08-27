//
//  ChatItem.swift
//  PUZL Boy
//
//  Created by Eddie Char on 7/31/24.
//

import UIKit
import SpriteKit

struct ChatItem {
    
    //MARK: - Properties
    
    let profile: ChatProfile
    let imgPos: ImagePosition
    let pause: TimeInterval?
    let startNewChat: Bool?
    let endChat: Bool?
    private(set) var chat: String
    let handler: (() -> Void)?
    
    enum ChatProfile {
        case hero, trainer, princess, princessCursed, princess2, villain,
             blankvillain, blankprincess, blanktrainer, blankhero,
             merton, magmus, melchior,
             statue0, statue1, statue2, statue3, statue4, statue5
    }

    enum ImagePosition {
        case left, right
    }
    

    // MARK: - Initialization
    
    init(profile: ChatProfile,
         imgPos: ImagePosition = .right,
         pause: TimeInterval? = nil,
         startNewChat: Bool? = nil,
         endChat: Bool? = nil,
         chat: String,
         handler: (() -> Void)?) {
        
        self.profile = profile
        self.imgPos = imgPos
        self.pause = pause
        self.startNewChat = startNewChat
        self.endChat = endChat
        self.chat = chat
        self.handler = handler
    }
    
    init(profile: ChatProfile, imgPos: ImagePosition = .right, chat: String) {
        self.init(profile: profile, imgPos: imgPos, pause: nil, startNewChat: nil, endChat: nil, chat: chat, handler: nil)
    }
    
    
    // MARK: - Functions
    
    ///Static function that returns the chat texture picture for the given profile.
    static func getChatProfileTexture(profile: ChatProfile) -> SKTexture? {
        let texture: SKTexture?
        
        switch profile {
        case .hero:             texture = SKTexture(imageNamed: "puzlboy")
        case .trainer:          texture = SKTexture(imageNamed: "trainer")
        case .villain:          texture = SKTexture(imageNamed: "villain")
        case .princess:         texture = SKTexture(imageNamed: "princess")
        case .princess2:        texture = SKTexture(imageNamed: "princess2")
        case .princessCursed:   texture = SKTexture(imageNamed: "princessCursed")
        case .blankhero:        texture = nil
        case .blanktrainer:     texture = nil
        case .blankvillain:     texture = nil
        case .blankprincess:    texture = nil
        case .merton:           texture = SKTexture(imageNamed: "melchior")
        case .magmus:           texture = SKTexture(imageNamed: "melchior")
        case .melchior:         texture = SKTexture(imageNamed: "melchior")
        case .statue0:          texture = SKTexture(imageNamed: "chatStatue0")
        case .statue1:          texture = SKTexture(imageNamed: "chatStatue1")
        case .statue2:          texture = SKTexture(imageNamed: "chatStatue2")
        case .statue3:          texture = SKTexture(imageNamed: "chatStatue3")
        case .statue4:          texture = SKTexture(imageNamed: "chatStatue4")
        case .statue5:          texture = SKTexture(imageNamed: "chatStatue5")
        }
        
        return texture
    }
    
    ///Static function that returns the chat background color for the given profile.
    static func getChatColor(profile: ChatProfile) -> UIColor {
        let chatColor: UIColor
        
        switch profile {
        case .hero, .blankhero:
            chatColor = .orange
        case .trainer, .blanktrainer:
            chatColor = .blue
        case .princess, .princess2, .princessCursed, .blankprincess:
            chatColor = .magenta
        case .villain, .blankvillain:
            chatColor = .red
        case .merton, .magmus, .melchior:
            chatColor = .purple
        case .statue0, .statue1, .statue2, .statue3, .statue4, .statue5:
            chatColor = .systemGreen.darkenColor(factor: 3)
        }
        
        return chatColor
    }
    
    ///Static function that plays the chat sound notification for the given profile.
    static func playChatNotification(profile: ChatProfile) {
        switch profile {
        case .hero, .blankhero:
            AudioManager.shared.playSound(for: "chatopen")
        case .trainer, .blanktrainer:
            AudioManager.shared.playSound(for: "chatopentrainer")
        case .princess, .princess2, .princessCursed, .blankprincess:
            AudioManager.shared.playSound(for: "chatopenprincess")
        case .villain, .blankvillain:
            AudioManager.shared.playSound(for: "chatopenvillain")
        case .merton, .magmus, .melchior:
            AudioManager.shared.playSound(for: "marlinblast")
        case .statue0, .statue1, .statue2, .statue3, .statue4, .statue5:
            AudioManager.shared.playSound(for: "chatopenstatue")
        }
    }
    
    ///Updates the chat property with the newChat argument inputted.
    mutating func updateChat(_ newChat: String) {
        self.chat = newChat
    }
}
