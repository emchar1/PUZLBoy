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
    let chat: String
    let handler: (() -> Void)?
    
    enum ChatProfile {
        case hero, trainer, princess, princessCursed, princess2, villain,
             blankvillain, blankprincess, blanktrainer,
             statue0, statue1, statue2, statue3
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
}
