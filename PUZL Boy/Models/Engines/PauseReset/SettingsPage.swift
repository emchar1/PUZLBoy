//
//  SettingsPage.swift
//  PUZL Boy
//
//  Created by Eddie Char on 4/29/23.
//

import UIKit
import SpriteKit

class SettingsPage: SKNode {
    
    private var scrollView: UIScrollView
    private var contentView: UIView
    
    // MARK: - Initialization
    
    override init() {
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        
        contentView = UIView()
        
        super.init()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
