//
//  ChatDecisionEngine.swift
//  PUZL Boy
//
//  Created by Eddie Char on 3/7/24.
//

import SpriteKit

protocol ChatDecisionEngineDelegate: AnyObject {
    func decisionWasMade(index: Int, order: ChatDecisionEngine.ButtonOrder)
    func decisionHasAppeared(node: ChatDecisionSprite)
    func decisionHasDisappeared(node: ChatDecisionSprite, didGetTapped: Bool)
}


class ChatDecisionEngine: ChatDecisionSpriteDelegate {
    
    // MARK: - Properties
    
    typealias ChatDecisionType = (left: ChatDecisionSprite, right: ChatDecisionSprite, selected: ButtonOrder?)
    private var decisionButtons: [ChatDecisionType] = []
    private var buttonSize: CGSize
    private var position: CGPoint
    
    var isActive: Bool {
        for i in 0..<decisionButtons.count {
            //DON'T CHANGE THIS!!! MUST ensure BOTH are visible, ELSE return false!
            if decisionButtons[i].left.isVisible && decisionButtons[i].right.isVisible {
                return true
            }
        }
        
        return false
    }
    
    enum ButtonOrder {
        case left, right
    }
    
    weak var delegate: ChatDecisionEngineDelegate?
    
    
    // MARK: - Initialization
    
    init(buttonSize: CGSize, position: CGPoint,
         decision0: (left: String, right: String),
         decision1: (left: String, right: String),
         decision2: (left: String, right: String),
         decision3: (left: String, right: String)) {
        
        self.buttonSize = buttonSize
        self.position = position
        
        decisionButtons.append((getButton(text: decision0.left, order: .left, index: 0), getButton(text: decision0.right, order: .right, index: 0), nil))
        decisionButtons.append((getButton(text: decision1.left, order: .left, index: 1), getButton(text: decision1.right, order: .right, index: 1), nil))
        decisionButtons.append((getButton(text: decision2.left, order: .left, index: 2), getButton(text: decision2.right, order: .right, index: 2), nil))
        decisionButtons.append((getButton(text: decision3.left, order: .left, index: 3), getButton(text: decision3.right, order: .right, index: 3), nil))
    }
    
    private func getButton(text: String, order: ButtonOrder, index: Int) -> ChatDecisionSprite {
        let positionRight: CGPoint = CGPoint(x: position.x + buttonSize.width + 20, y: position.y)
        let buttonColor = order == .left ? DecisionButtonSprite.colorViolet : DecisionButtonSprite.colorBlue

        let selectedButton = ChatDecisionSprite(text: text, buttonSize: buttonSize, color: buttonColor)
        selectedButton.position = order == .left ? position : positionRight
        selectedButton.zPosition = 20
        selectedButton.name = "\(order == .left ? "leftButton" : "rightButton")\(index)"
        selectedButton.delegate = self
        
        return selectedButton
    }
    
    
    // MARK: - Touch Functions
    
    func touchDown(location: CGPoint, selectedButton: ChatDecisionSprite) {
        touchHelper(function: "touchDown", location: location, selectedButton: selectedButton)
    }
    
    func didTapButton(location: CGPoint, selectedButton: ChatDecisionSprite) {
        touchHelper(function: "didTapButton", location: location, selectedButton: selectedButton)
    }
    
    func touchUp() {
        touchHelper(function: "touchUp")
    }
    
    /**
     Helper function to the touchDown(), didTapButton() and touchUp() functions by initializing boilerplate code.
     - parameters:
        - function: which function to return
        - location: location of the tap
        - selectedButton: the selected ChatDecisionSprite, with left or right, and index.
     */
    private func touchHelper(function: String, location: CGPoint = .zero, selectedButton: ChatDecisionSprite? = nil) {
        switch function {
        case "touchDown":
            guard let selectedButton = selectedButton, let indexOrder = getIndexSelectedButton(selectedButton) else { break }

            if indexOrder.order == .left {
                decisionButtons[indexOrder.index].left.touchDown(in: location)
            }
            else {
                decisionButtons[indexOrder.index].right.touchDown(in: location)
            }
        case "didTapButton":
            guard let selectedButton = selectedButton, let indexOrder = getIndexSelectedButton(selectedButton) else { break }
            
            if indexOrder.order == .left {
                decisionButtons[indexOrder.index].left.tapButton(in: location)
            }
            else {
                decisionButtons[indexOrder.index].right.tapButton(in: location)
            }
            
            decisionButtons[indexOrder.index].selected = indexOrder.order
        case "touchUp":
            for i in 0..<decisionButtons.count {
                decisionButtons[i].left.touchUp()
                decisionButtons[i].right.touchUp()
            }
        default:
            print("Unknown Touch function in ChatDecisionEngine()")
            break
        }
    }
    
    private func getIndexSelectedButton(_ selectedButton: ChatDecisionSprite) -> (index: Int, order: ButtonOrder)? {
        guard let name = selectedButton.name else { return nil }
        guard let index = Int("\(name.last ?? "0")") else { return nil }
        
        let order: ButtonOrder = name.contains("left") ? .left : .right
        
        return (index, order)
    }
    
    
    // MARK: - Show Functions
    
    func showDecisions(index: Int, toNode node: SKNode) {
        decisionButtons[index].left.animateAppear(toNode: node)
        decisionButtons[index].right.animateAppear(toNode: node)
    }
}


// MARK: - ChatDecisionSprite Delegate

extension ChatDecisionEngine {
    func buttonWasTapped(_ node: ChatDecisionSprite) {
        guard let indexOrder = getIndexSelectedButton(node) else { return }
        
        decisionButtons[indexOrder.index].left.animateDisappear(didGetTapped: indexOrder.order == .left)
        decisionButtons[indexOrder.index].right.animateDisappear(didGetTapped: indexOrder.order == .right)
        
        delegate?.decisionWasMade(index: indexOrder.index, order: indexOrder.order)
    }
    
    func buttonHasAppeared(_ node: ChatDecisionSprite) {
        delegate?.decisionHasAppeared(node: node)
    }
    
    func buttonHasDisappeared(_ node: ChatDecisionSprite, didGetTapped: Bool) {
        delegate?.decisionHasDisappeared(node: node, didGetTapped: didGetTapped)
    }

}
