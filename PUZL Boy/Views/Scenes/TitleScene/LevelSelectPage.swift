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
    private var useMorningSky: Bool
    
    weak var delegate: LevelSelectPageDelegate?
    
    
    // MARK: - Initialization
    
    init(contentSize: CGSize, useMorningSky: Bool) {
        self.useMorningSky = useMorningSky
        
        super.init(contentSize: contentSize, titleText: "Level Select")
        
        setupNodes()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupNodes() {
        levelPicker = UIPickerView(frame: .zero)
                      
        dismissNode = SettingsTapButton(text: "Start Game", useMorningSky: useMorningSky)
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

        // TODO: -
        print("touchDown in \(location)")
        dismissNode.touchDown(in: location)
        
    }
    
    override func touchUp() {
        super.touchUp()
        
        // TODO: -
        print("touchUp")
        dismissNode.touchUp()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        // TODO: -
        print("touchesMoved")
        dismissNode.touchesMoved(touches, with: event)
    }
    
    override func touchNode(for touches: Set<UITouch>) {
        super.touchNode(for: touches)
        
        guard let superScene = superScene else { return }
        guard let location = touches.first?.location(in: superScene) else { return }
        
        // TODO: -
        print("touchNode in \(location)")
        dismissNode.tapButton(in: location, type: .buttontap3)
    }
}


// MARK: - SettingsTapButtonDelegate

extension LevelSelectPage: SettingsTapButtonDelegate {
    func didTapButton(_ buttonNode: SettingsTapButton) {
        delegate?.didTapLevelSelect()
    }
    
    
}
