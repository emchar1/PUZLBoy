//
//  ChatItem.swift
//  PUZL Boy
//
//  Created by Eddie Char on 7/31/24.
//

import Foundation

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
    
    mutating func updateChat(_ newChat: String) {
        self.chat = newChat
    }
}
