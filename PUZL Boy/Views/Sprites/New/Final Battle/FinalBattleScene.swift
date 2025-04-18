//
//  FinalBattleScene.swift
//  PUZL Boy
//
//  Created by Eddie Char on 11/23/24.
//

import SpriteKit

class FinalBattleScene: SKScene {
    
    // MARK: - Properties
    
    private var tapPointerEngine: TapPointerEngine!
    private var finalBattle2Engine: FinalBattle2Engine!
    private var chatEngine: ChatEngine!
    
    
    // MARK: - Initialization
    
    override init(size: CGSize) {
        super.init(size: size)
        
        setupScene()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("FinalBattleScene deinit")
    }
    
    private func setupScene() {
        backgroundColor = .black
        
        tapPointerEngine = TapPointerEngine(using: ChosenSword(type: FIRManager.chosenSword))
        finalBattle2Engine = FinalBattle2Engine(size: self.size)
        chatEngine = ChatEngine()
    }
    
    
    // MARK: - Functions
    
    override func didMove(to view: SKView) {
        finalBattle2Engine.moveSprites(to: self)
        chatEngine.moveSprites(to: self)
    }
    
    
    // MARK: - Touch Functions
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        
        tapPointerEngine.move(to: self, at: location, particleType: .pointer)
        chatEngine.touchDown(in: location)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        
        finalBattle2Engine.handleControls(in: location)
        chatEngine.didTapButton(in: location)
        chatEngine.touchUp()
    }
    
    
    // MARK: - Functions
    
    func animateScene() {
        finalBattle2Engine.animateSprites()
    }
    
    func playDialogue(level: Int) {
        chatEngine.playDialogue(level: level, completion: nil)
    }
    
    func cleanupScene(didWin: Bool, completion: @escaping () -> Void) {
        // FIXME: - For use with build# 1.28(30).
        finalBattle2Engine.animateCleanup { [weak self] in
            self?.tapPointerEngine = nil
            self?.finalBattle2Engine = nil
            self?.chatEngine = nil
            completion()
        }
    }
    
    
}
