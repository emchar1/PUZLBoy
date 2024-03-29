//
//  LevelSelectPage.swift
//  PUZL Boy
//
//  Created by Eddie Char on 9/29/23.
//

import SpriteKit

protocol LevelSelectPageDelegate: AnyObject {
    func didTapLevelSelect()
}


class LevelSelectPage: ParentPage {
    
    // MARK: - Properties
    
    private var levelPicker: UIPickerView!
    private var dismissNode: SettingsTapButton!
    
    weak var delegate: LevelSelectPageDelegate?
    
    
    // MARK: - Initialization
    
    init(contentSize: CGSize) {
        super.init(contentSize: contentSize, titleText: "Level Select")
        
        setupNodes()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deinit LevelSelectPage")
    }
    
    private func setupNodes() {
        levelPicker = UIPickerView(frame: .zero)
                      
        dismissNode = SettingsTapButton(text: "Start Game")
        dismissNode.position = CGPoint(x: (contentSize.width + SettingsTapButton.buttonSize.width) / 2,
                                       y: -contentSize.height + SettingsTapButton.buttonSize.height / 2)
        dismissNode.zPosition = dismissNode.zPositionOffset
        dismissNode.name = "dismissNode"
        dismissNode.delegate = self
        
        contentNode.addChild(dismissNode)
    }
    
    
    // MARK: - UI Functions
    
    override func touchDown(for touches: Set<UITouch>) {
        super.touchDown(for: touches)
        
        guard let superScene = superScene else { return }
        guard let location = touches.first?.location(in: superScene) else { return }

        dismissNode.touchDown(in: location)
        
    }
    
    override func touchUp() {
        super.touchUp()
        
        dismissNode.touchUp()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        dismissNode.touchesMoved(touches, with: event)
    }
    
    override func touchNode(for touches: Set<UITouch>) {
        super.touchNode(for: touches)
        
        guard let superScene = superScene else { return }
        guard let location = touches.first?.location(in: superScene) else { return }
        
        dismissNode.tapButton(in: location, type: .buttontap3)
    }
}


// MARK: - SettingsTapButtonDelegate

extension LevelSelectPage: SettingsTapButtonDelegate {
    func didTapButton(_ buttonNode: SettingsTapButton) {
        delegate?.didTapLevelSelect()
    }
    
    
}
