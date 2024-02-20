//
//  SpeechBubbleItem.swift
//  PUZL Boy
//
//  Created by Eddie Char on 8/30/23.
//

import Foundation

struct SpeechBubbleItem {
    let profile: SpeechBubbleSprite
    let speed: TimeInterval
    let chat: String
    let handler: (() -> Void)?
    
    init(profile: SpeechBubbleSprite, speed: TimeInterval = SpeechBubbleSprite.animationSpeedOrig, chat: String, handler: (() -> Void)?) {
        self.profile = profile
        self.speed = speed
        self.chat = chat
        self.handler = handler
    }
    
    init(profile: SpeechBubbleSprite, speed: TimeInterval = SpeechBubbleSprite.animationSpeedOrig, chat: String) {
        self.init(profile: profile, speed: speed, chat: chat, handler: nil)
    }
}
