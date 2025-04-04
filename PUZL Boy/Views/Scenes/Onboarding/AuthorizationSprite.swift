//
//  AuthorizationSprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 5/24/24.
//

import SpriteKit

class AuthorizationSprite: ConfirmSprite {
    
    // MARK: - Initialization
    
    init(title: String, message: String, confirm: String = "OK") {
        super.init(title: title,
                   message: message,
                   confirm: confirm,
                   cancel: nil,
                   customHeight: UIDevice.isiPad ? K.ScreenDimensions.size.height / 3 + 80 : K.ScreenDimensions.size.height / 4 + 40,
                   customColor: .orange)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
