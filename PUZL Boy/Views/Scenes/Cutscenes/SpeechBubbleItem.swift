//
//  SpeechBubbleItem.swift
//  PUZL Boy
//
//  Created by Eddie Char on 8/30/23.
//

import Foundation

struct SpeechBubbleItem {
    let profile: SpeechBubbleSprite
    let chat: String
    let handler: (() -> Void)?
    
    init(profile: SpeechBubbleSprite, chat: String, handler: (() -> Void)?) {
        self.profile = profile
        self.chat = chat
        self.handler = handler
    }
    
    init(profile: SpeechBubbleSprite, chat: String) {
        self.init(profile: profile, chat: chat, handler: nil)
    }
}
