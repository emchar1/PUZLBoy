//
//  ChatEngine.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/23/22.
//

import SpriteKit

protocol ChatEngineDelegate: AnyObject {
    //Tutorial
    func illuminatePanel(at position: K.GameboardPosition, useOverlay: Bool)
    func deilluminatePanel(at position: K.GameboardPosition, useOverlay: Bool)
    func illuminateDisplayNode(for displayType: DisplaySprite.DisplayStatusName)
    func deilluminateDisplayNode(for displayType: DisplaySprite.DisplayStatusName)
    func illuminateMinorButton(for button: PauseResetEngine.MinorButton)
    func deilluminateMinorButton(for button: PauseResetEngine.MinorButton)

    //Trainer
    func spawnTrainer(at position: K.GameboardPosition, to direction: Controls)
    func despawnTrainer(to position: K.GameboardPosition?)
    func spawnTrainerWithExit(at position: K.GameboardPosition, to direction: Controls)
    func despawnTrainerWithExit(moves: [K.GameboardPosition])
    
    //Catwalk
    func spawnEldersCatwalk()
    func despawnEldersCatwalk()
    func spawnPrincessCatwalk()
    func despawnPrincessCatwalk()
    func spawnMarlinCatwalk()
    func despawnMarlinCatwalk()
    func spawnMagmoorCatwalk()
    func despawnMagmoorCatwalk(completion: @escaping () -> Void)
    func flashRedCatwalk(message: String, completion: @escaping () -> Void)
    func shiftRedCatwalk(shouldShift: Bool, showMagmoorScary: Bool)

    //Princess/Magmoor Capture
    func spawnPrincessCapture(at position: K.GameboardPosition, shouldAnimateWarp: Bool, completion: @escaping () -> Void)
    func despawnPrincessCapture(at position: K.GameboardPosition, completion: @escaping () -> Void)
    func flashPrincess(at position: K.GameboardPosition, completion: @escaping () -> Void)
    func inbetweenRealmEnter(levelInt: Int, mergeHalfway: Bool, moves: [K.GameboardPosition])
    func inbetweenRealmExit(persistPresence: Bool, completion: @escaping () -> Void)
    func inbetweenFlashPlayer(playerType: Player.PlayerType, position: K.GameboardPosition, persistPresence: Bool)
    func empowerPrincess(powerDisplayDuration: TimeInterval)
    func encagePrincess()
    
    //Daemon the Destroyer
    func peekMinion(at position: K.GameboardPosition, duration: TimeInterval, completion: @escaping () -> Void)
    func spawnDaemon(at position: K.GameboardPosition)
    func spawnMagmoorMinion(at position: K.GameboardPosition, chatDelay: TimeInterval)
    func despawnMagmoorMinion(at position: K.GameboardPosition, fadeDuration: TimeInterval)
    func minionAttack(duration: TimeInterval, completion: @escaping() -> Void)
    func spawnElder(minionPosition: K.GameboardPosition, positions: [K.GameboardPosition], completion: @escaping () -> Void)
    func despawnElders(to position: K.GameboardPosition, completion: @escaping () -> Void)
    
    //Gift
    func getGift(lives: Int)
}

class ChatEngine {
    
    // MARK: - Properties
        
    //Size & Position Properties
    private let avatarSizeNew: CGFloat = 300
    private let avatarSizeOrig: CGFloat = 512
    private let padding: CGPoint = CGPoint(x: 20, y: 8)
    private let borderLineWidth: CGFloat = 6
    private var origin: CGPoint {
        CGPoint(x: GameboardSprite.offsetPosition.x + borderLineWidth / 2,
                y: K.ScreenDimensions.topOfGameboard - backgroundSpriteWidth - avatarSizeNew - 40)
    }
    private var backgroundSpriteWidth: CGFloat {
        K.ScreenDimensions.size.width * UIDevice.spriteScale
    }

    
    //Utilities
    private var timer: Timer
    private var dispatchWorkItem: DispatchWorkItem          //Used to closeChat() and cancel any scheduled closeChat() calls. It works!!!


    //Important Properties
    private var currentProfile: ChatItem.ChatProfile = .hero
    private var dialoguePlayed: [Int: Bool] = [:]           //Only play certain instructions once
    private var dialogueWithCutscene: [Int: Bool] = [:]     //Levels with dialogue that have a cutscene
    private var completion: (() -> ())?

    private let chatSpeedOrig: TimeInterval = 0.08
    private let chatSpeedImmediate: TimeInterval = 0
    private var chatSpeed: TimeInterval
    private var chatText: String = ""
    private var chatIndex: Int = 0

    private(set) var isChatting: Bool = false
    private var isAnimating: Bool = false
    private var allowNewChat: Bool = true
    private var shouldClose: Bool = true
    private var closeChatIsRunning: Bool = false
    
    //For fun
    static var hero251Quote: String = "I used to have regular milk with my cereal, then I discovered oat milk and dude. It. Slaps. And it's vegan!"
    

    //Chat Sprites
    private var chatBackgroundSprite: SKShapeNode!
    private var avatarSprite: SKSpriteNode!
    private var textSprite: SKLabelNode!
    private var fastForwardSprite: SKSpriteNode!
    private var chatDecisionEngine: ChatDecisionEngine!

    
    //Statue Dialogue
    private var dialogueStatue0: StatueDialogue!
    private var dialogueStatue1: StatueDialogue!
    private var dialogueStatue2: StatueDialogue!
    private var dialogueStatue3: StatueDialogue!
    private var dialogueStatue4: StatueDialogue!
    private var dialogueStatue3b: StatueDialogue!


    //Overlay Sprites
    private var superScene: SKScene?
    private var dimOverlaySprite: SKShapeNode!
    private var marlinBlast: MarlinBlastSprite!
    private var magmoorScary: MagmoorScarySprite!
    private var chapterTitleSprite: ChapterTitleSprite!
    
    
    weak var delegate: ChatEngineDelegate?
    
    
    // MARK: - Initialization
    
    init() {
        timer = Timer()
        dispatchWorkItem = DispatchWorkItem(block: {})
        
        chatSpeed = chatSpeedOrig

        populateKeyDialogue()
        setupStatueDialogue()
        setupSprites()
        animateFFButton()
    }
    
    deinit {
        print("ChatEngine deinit")
    }
    
    private func setupSprites() {
        //Chat Sprites setup
        chatBackgroundSprite = SKShapeNode()
        chatBackgroundSprite.lineWidth = borderLineWidth
        chatBackgroundSprite.path = UIBezierPath(roundedRect: CGRect(x: origin.x, y: origin.y,
                                                                     width: backgroundSpriteWidth, height: avatarSizeNew + borderLineWidth),
                                                 cornerRadius: 20).cgPath
        chatBackgroundSprite.fillColor = .orange
        chatBackgroundSprite.strokeColor = .white
        chatBackgroundSprite.fillTexture = SKTexture(image: UIImage.gradientTextureChat)
        chatBackgroundSprite.setScale(0)
        chatBackgroundSprite.name = "backgroundSprite"
        chatBackgroundSprite.zPosition = K.ZPosition.chatDialogue
                
        avatarSprite = SKSpriteNode(texture: SKTexture(imageNamed: "puzlboy"))
        avatarSprite.position = CGPoint(x: origin.x, y: origin.y + borderLineWidth / 2)
        avatarSprite.setScale(avatarSizeNew / avatarSizeOrig * 3)
        avatarSprite.anchorPoint = .zero
        avatarSprite.color = .magenta
        
        textSprite = SKLabelNode(text: "PUZL Boy is the newest puzzle game out there on the App Store. It's so popular, it's going to have over a million downloads, gamers are going to love it - casual gamers, hardcore gamers, and everyone in-between! So download your copy today!!")
        textSprite.position = CGPoint(x: origin.x, y: origin.y + avatarSizeNew - padding.y)
        textSprite.numberOfLines = 0
        textSprite.preferredMaxLayoutWidth = backgroundSpriteWidth - avatarSizeNew
        textSprite.horizontalAlignmentMode = .left
        textSprite.verticalAlignmentMode = .top
        textSprite.fontName = UIFont.chatFont
        textSprite.fontSize = UIFont.chatFontSizeMedium
        textSprite.fontColor = UIFont.chatFontColor
        textSprite.zPosition = 10
        textSprite.addDropShadow()
        
        fastForwardSprite = SKSpriteNode(imageNamed: "forwardButton")
        fastForwardSprite.setScale(0.45 * 3)
        fastForwardSprite.anchorPoint = CGPoint(x: 1, y: 0)
        fastForwardSprite.position = CGPoint(x: origin.x + backgroundSpriteWidth - padding.x, y: origin.y + padding.x)
        fastForwardSprite.alpha = 1
        fastForwardSprite.zPosition = 15
        fastForwardSprite.name = "fastForward"
        
        let buttonSize = CGSize(width: (backgroundSpriteWidth - avatarSizeNew) / 2 - 20, height: avatarSizeNew / 3)
        
        chatDecisionEngine = ChatDecisionEngine(
            buttonSize: buttonSize,
            leftButtonPositionLeft: CGPoint(x: origin.x + buttonSize.width / 2 + 20, y: origin.y + buttonSize.height / 2 + 20),
            leftButtonPositionRightXOffset: avatarSizeNew - 20,
            decision0: ("Pursue Him", "Prepare First"),
            decision1: ("Fire", "Ice"),
            decision2: ("Give It Away", "Keep It"),
            decision3: ("Defeat Him", "Let Him Go"))
        chatDecisionEngine.delegate = self

        
        //Overlay Sprites setup
        dimOverlaySprite = SKShapeNode(rectOf: K.ScreenDimensions.size)
        dimOverlaySprite.position = CGPoint(x: K.ScreenDimensions.size.width / 2, y: K.ScreenDimensions.size.height / 2)
        dimOverlaySprite.fillColor = .black
        dimOverlaySprite.lineWidth = 0
        dimOverlaySprite.alpha = 0
        dimOverlaySprite.zPosition = K.ZPosition.chatDimOverlay

        marlinBlast = MarlinBlastSprite()
        marlinBlast.zPosition = K.ZPosition.chatDialogue - 1
        
        magmoorScary = MagmoorScarySprite(boundingBox: chatBackgroundSprite.path?.boundingBox)
        magmoorScary.zPosition = K.ZPosition.chatDialogue + 5
        
        chapterTitleSprite = ChapterTitleSprite(chapter: 1)
        

        //Add sprites to background
        chatBackgroundSprite.addChild(avatarSprite)
        chatBackgroundSprite.addChild(textSprite)
        chatBackgroundSprite.addChild(fastForwardSprite)
    }
    
    
    // MARK: - Move Functions
    
    /**
     Adds all the sprites to the superScene, i.e. should be called in a GameScene's moveTo() function.
     - parameter superScene: The GameScene to add all the children to.
     */
    func moveSprites(to superScene: SKScene) {
        self.superScene = superScene
        
        superScene.addChild(chatBackgroundSprite)
        superScene.addChild(dimOverlaySprite)
        superScene.addChild(chapterTitleSprite)
    }
    
    
    // MARK: - Touch Functions
    
    func touchDown(in location: CGPoint) {
        guard let superScene = superScene else { return }
        guard superScene.nodes(at: location).filter({ $0.name == "backgroundSprite" }).first != nil else { return }
        guard !isAnimating else { return }
        
        isAnimating = true
        
        //Prevents spamming of the chat while FF tapping. Adds a 0.5s delay; MUST be 0.5s and no shorter to prevent crashing. BUGFIX# 230921E01
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isAnimating = false
        }

        for node in superScene.nodes(at: location) {
            if node.name == "backgroundSprite" && !chatDecisionEngine.isActive && fastForwardSprite.parent != nil {
                animateFFButton()
                fastForward()
            }
            else if let selectedButton = node as? ChatDecisionSprite {
                chatDecisionEngine.touchDown(location: location, selectedButton: selectedButton)
            }
        }
    }
    
    func touchUp() {
        chatDecisionEngine.touchUp()
    }
    
    func didTapButton(in location: CGPoint) {
        guard let superScene = superScene else { return }
        guard superScene.nodes(at: location).filter({ $0.name == "backgroundSprite" }).first != nil else { return }
        
        for node in superScene.nodes(at: location) {
            if let selectedButton = node as? ChatDecisionSprite {
                chatDecisionEngine.didTapButton(location: location, selectedButton: selectedButton)
            }
        }
    }
    
    
    // MARK: - Helper Functions

    func shouldPauseGame(level: Int) -> Bool {
        return dialoguePlayed[level] != nil
    }
    
    static func isTikiLevel(level: Int) -> Bool {
        return level == 319 || level == 339 || level == 351 || level == 376 || level == 401 || level == 475
    }

    private func fastForward() {
        if chatSpeed > chatSpeedImmediate && chatIndex < chatText.count {
            chatSpeed = chatSpeedImmediate
        }
        else {
            dispatchWorkItem.cancel()
            closeChat()
        }
    }
    
    /**
     Hides the fast forward button, and optionally, show text immediately for dramatic effect.
     - parameter showImmediately: if true, show text immediately. text returns to chatSpeedOrig  upon showing FF button.
     */
    private func hideFFButton(showChatImmediately: Bool = false) {
        fastForwardSprite.removeFromParent()
        
        if showChatImmediately {
            chatSpeed = chatSpeedImmediate
        }
    }
    
    /**
     Shows the fast forward button (and return chatSpeed to normal, if it was set to 0 previously).
     */
    private func showFFButton() {
        fastForwardSprite.removeFromParent() //just in case...
        chatBackgroundSprite.addChild(fastForwardSprite)
        
        if chatSpeed <= chatSpeedImmediate {
            chatSpeed = chatSpeedOrig
        }
    }
    
    private func animateFFButton() {
        fastForwardSprite.removeAllActions()
        
        fastForwardSprite.run(SKAction.fadeIn(withDuration: 0))
        fastForwardSprite.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.fadeAlpha(to: 0, duration: 0.5),
            SKAction.fadeAlpha(to: 1, duration: 0.5)
        ])))
    }
    
    private func fadeDimOverlay() {
        dimOverlaySprite.run(SKAction.fadeAlpha(to: 0.0, duration: 1.0))
    }
    
    /**
     Helper function to wrap up a chat dialogue and call the completion handler.
     - parameters:
        - level: the current game level
        - cutscene: the cutscene to play upon completion, if any
        - completion: completion that allows for handling code, but also passes through the cutscene argument for further processing
     */
    private func handleDialogueCompletion(level: Int, cutscene: Cutscene? = nil, completion: ((Cutscene?) -> Void)?) {
        if cutscene == nil { //Do not set dialoguePlayed[level] = true if there's a cutscene (is this still relevant??? 6/3/24)
            dialoguePlayed[level] = true
        }
        
        isChatting = false
        fadeDimOverlay()
        completion?(cutscene)
    }
    
    ///Animates magical feather falling from the sky
    private func animateFeather() {
        func featherDescendAction(moveByX: CGFloat, shouldFade: Bool = false) -> SKAction {
            let descendDuration: TimeInterval = 0.95

            let fadeAction = SKAction.sequence([
                SKAction.wait(forDuration: descendDuration * 0.5),
                SKAction.fadeOut(withDuration: descendDuration * 0.5)
            ])

            let descendAction = SKAction.group([
                SKAction.moveBy(x: moveByX, y: -200, duration: descendDuration),
                SKAction.rotate(byAngle: .pi / 4, duration: descendDuration)
            ])
            
            let descendAndFadeAction = SKAction.group([
                descendAction,
                fadeAction
            ])
            
            return shouldFade ? descendAndFadeAction : descendAction
        }
        
        let featherSprite = SKSpriteNode(imageNamed: "magicFeather")
        featherSprite.position = CGPoint(x: K.ScreenDimensions.size.width / 2, y: K.ScreenDimensions.size.height - 512 / 2)
        featherSprite.size = CGSize(width: 512, height: 512)
        featherSprite.zPosition = 10
        
        chatBackgroundSprite.addChild(featherSprite)
        
        featherSprite.run(SKAction.sequence([
            featherDescendAction(moveByX: -25),
            featherDescendAction(moveByX: 50),
            featherDescendAction(moveByX: -50),
            featherDescendAction(moveByX: 50, shouldFade: true),
            SKAction.removeFromParent()
        ]))
        
        AudioManager.shared.playSound(for: "pickupitem")
    }
    
    ///Animates the screen shaking
    private func animateFateSealed() {
        guard let superScene = superScene, let gameScene = superScene as? GameScene else { return }
        
        dimOverlaySprite.fillColor = FIRManager.decisionsLeftButton[1] ?? true ? .red : .blue
        dimOverlaySprite.run(SKAction.fadeAlpha(to: 0.4, duration: 1))

        gameScene.shakeScreen(duration: 5, shouldPlaySFX: true) { [weak self] in
            self?.dimOverlaySprite.run(SKAction.fadeOut(withDuration: 5)) {
                self?.dimOverlaySprite.fillColor = .black
            }
        }
    }
    
    
    // MARK: - Chat Functions
    
    ///Helper function that handles the nesting of chats via recursion
    private func sendChatArray(shouldSkipDim: Bool = false, items: [ChatItem], currentIndex: Int = 0, completion: (() -> Void)?) {
        if currentIndex == items.count {
            //Base case
            completion?()
        }
        else {
            sendChat(profile: items[currentIndex].profile,
                     imgPos: items[currentIndex].imgPos,
                     pause: items[currentIndex].pause,
                     startNewChat: items[currentIndex].startNewChat ?? (currentIndex == 0),
                     endChat: items[currentIndex].endChat ?? (currentIndex == items.count - 1),
                     shouldSkipDim: shouldSkipDim,
                     chat: items[currentIndex].chat) { [weak self] in
                items[currentIndex].handler?()

                //Recursion!! Also the [weak self] prevents a retain cycle here...
                //Added shouldSkipDim argument here to propagate it through, recursively. It wasn't added before 9/5/24
                self?.sendChatArray(shouldSkipDim: shouldSkipDim, items: items, currentIndex: currentIndex + 1, completion: completion)
            }
        }
    }
    
    private func sendChat(profile: ChatItem.ChatProfile, imgPos: ChatItem.ImagePosition, pause: TimeInterval?, startNewChat: Bool, endChat: Bool, shouldSkipDim: Bool, chat: String, completion: (() -> ())? = nil) {
        //Only allow a new chat if current chat isn't happening
        guard allowNewChat else { return }
        

        textSprite.text = ""
        textSprite.updateShadow()
        avatarSprite.texture = ChatItem.getChatProfileTexture(profile: profile)
        chatBackgroundSprite.fillColor = ChatItem.getChatColor(profile: profile)
        timer.invalidate()
        chatText = chat
        chatIndex = 0
        allowNewChat = false //prevents interruption of current chat, which could lead to crashing due to index out of bounds
        shouldClose = endChat
        currentProfile = profile
        self.completion = completion
        
        if profile == .blankhero || profile == .blanktrainer || profile == .blankvillain || profile == .blankprincess || profile == .blankelders {
            avatarSprite.isHidden = true
            
            textSprite.position.x = K.ScreenDimensions.size.width / 2
            textSprite.preferredMaxLayoutWidth = backgroundSpriteWidth
            textSprite.horizontalAlignmentMode = .center
        }
        else {
            avatarSprite.position.x = origin.x + (imgPos == .left ? padding.x : backgroundSpriteWidth - padding.x)
            avatarSprite.xScale = imgPos == .left ? abs(avatarSprite.xScale) : -abs(avatarSprite.xScale)
            avatarSprite.isHidden = false
            
            textSprite.position.x = origin.x + (imgPos == .right ? padding.x : avatarSprite.size.width)
            textSprite.preferredMaxLayoutWidth = backgroundSpriteWidth - avatarSizeNew
            textSprite.horizontalAlignmentMode = .left
        }
        
        chatBackgroundSprite.position.x = imgPos == .left ? 0 : K.ScreenDimensions.size.width
        chatBackgroundSprite.setScale(0)
        

        //Animates the chat bubble zoom in for startNewChat. Need to do 2 cases because even with a wait of 0 seconds, it adds a flicker that could be distracting.
        let animateBackgroundSprite = SKAction.group([
            SKAction.moveTo(x: 0, duration: startNewChat ? 0.4 : 0),
            SKAction.scale(to: 1.0, duration: startNewChat ? 0.4 : 0)
        ])
        
        if let pause = pause {
            chatBackgroundSprite.run(SKAction.sequence([
                SKAction.wait(forDuration: pause),
                animateBackgroundSprite
            ])) { [weak self] in
                guard let self = self else { return }
                
                if startNewChat {
                    playChatOpenNotification()
                }
                
                timer = Timer.scheduledTimer(timeInterval: chatSpeed, target: self, selector: #selector(animateText(_:)), userInfo: nil, repeats: true)
            }
        }
        else {
            //Leave out the wait
            chatBackgroundSprite.run(animateBackgroundSprite) { [weak self] in
                guard let self = self else { return }
                
                if startNewChat {
                    playChatOpenNotification()
                }
                
                timer = Timer.scheduledTimer(timeInterval: chatSpeed, target: self, selector: #selector(animateText(_:)), userInfo: nil, repeats: true)
            }
        }
        
        //Animates dimOverlaySprite to darken the background.
        if startNewChat && !shouldSkipDim {
            dimOverlaySprite.run(SKAction.sequence([
                SKAction.wait(forDuration: pause ?? 0),
                SKAction.fadeAlpha(to: 0.8, duration: 1.0)
            ]))
        }
    }
    
    ///This contains the magic of animating the characters of the string like a typewriter, until it gets to the end of the chat.
    @objc private func animateText(_ sender: Timer) {
        if chatSpeed > chatSpeedImmediate && chatIndex < chatText.count {
            let chatChar = chatText[chatText.index(chatText.startIndex, offsetBy: chatIndex)]
            
            textSprite.text! += "\(chatChar)"
            textSprite.updateShadow()
            
            chatIndex += 1
        }
        else if chatSpeed <= chatSpeedImmediate && chatIndex < chatText.count {
            textSprite.text = chatText
            textSprite.updateShadow()
            
            chatIndex = chatText.count
        }
        else if chatIndex >= chatText.count {
            timer.invalidate()
            
            //Set it here so you can cancel it if needed.
            dispatchWorkItem = DispatchWorkItem(block: { [weak self] in
                self?.closeChat()
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (chatSpeed > chatSpeedImmediate ? 5.0 : max(5.0, Double(chatText.count) / 10)), execute: dispatchWorkItem)
        }
    }
    
    private func playChatOpenNotification() {
        ChatItem.playChatNotification(profile: currentProfile)
    }
    
    private func closeChat() {
        guard !chatDecisionEngine.isActive else { return }
        guard !closeChatIsRunning else { return } //BUGFIX# 240531E01 - prevents closeChat() simultaneous run for FF button vs timer end chat.
        
        let duration: TimeInterval = shouldClose ? 0.2 : 0
        
        closeChatIsRunning = true

        if shouldClose {
            AudioManager.shared.playSound(for: "chatclose")
        }
        else {
            let bounceOffset: CGFloat = 20
            
            chatBackgroundSprite.run(SKAction.sequence([
                SKAction.moveBy(x: 0, y: -bounceOffset, duration: 0),
                SKAction.moveBy(x: 0, y: bounceOffset, duration: 0.25)
            ]))
            
            ButtonTap.shared.tap(type: .buttontap2)
        }
        
        //Animates the chat bubble zoom out for endChat
        chatBackgroundSprite.run(SKAction.group([
            SKAction.moveTo(x: currentProfile != .hero ? backgroundSpriteWidth : 0, duration: duration),
            SKAction.scale(to: 0, duration: duration)
        ])) { [weak self] in
            guard let self = self else { return }
            
            allowNewChat = true
            closeChatIsRunning = false
            chatSpeed = chatSpeedOrig
            
            completion?()
        }
    }
}


// MARK: - ChatDecisionEngine Delegate

extension ChatEngine: ChatDecisionEngineDelegate {
    func decisionWasMade(index: Int, order: ChatDecisionEngine.ButtonOrder) {
        FIRManager.updateFirestoreRecordDecision(index: index, buttonOrder: order)
        
        //Don't forget to update the StatueDialogue object!! (Otherwise it will ask the question again in the same line of questioning).
        switch index {
        case 0:
            break
        case 1:
            dialogueStatue1.setShouldSkipFirstQuestion(true)
        case 2:
            let gaveAwayFeather = FIRManager.decisionsLeftButton[index] ?? false
            
            dialogueStatue3.setShouldSkipFirstQuestion(true)
            dialogueStatue3.updateDialogue(index: dialogueStatue3.indices[0], newDialogue: gaveAwayFeather ? "Ahhhh, this is exquisite!! You won't regret it." : "Fine. Keep your silly feather. I didn't want it anyway!")
            
            if gaveAwayFeather {
                FIRManager.updateFirestoreRecordHasFeather(false)
            }
        case 3:
            break
        default:
            print("Unknown Decision Question, index: \(index)")
            break
        }
    }
    
    func decisionHasAppeared(node: ChatDecisionSprite) {
        fastForwardSprite.removeAllActions()
        fastForwardSprite.alpha = 0
    }
    
    func decisionHasDisappeared(node: ChatDecisionSprite, didGetTapped: Bool) {
        // BUGFIX# 240308E01 - This guard prevents fastForward() being called more than once, which invokes closeChat() twice (two buttons), which results in the stuttering bug!
        guard didGetTapped else { return }
        
        animateFFButton()
        fastForward()
    }
}


// MARK: - Dialogue Functions

extension ChatEngine {
    func setDialogueWithCutscene(level: Int, to newValue: Bool) {
        guard dialogueWithCutscene[level] != nil else { return }
        
        dialogueWithCutscene[level] = newValue
    }
    
    ///Populates the dialoguePlayed array. Need to include all levels where dialogue is to occur, and also add the level case in the playDialogue() function.
    private func populateKeyDialogue() {
        
        dialoguePlayed[Level.partyLevel] = false //Level: -1. IMPORTANT: MUST be called in both, Age of Balance and Age of Ruin!!!
        
        if AgeOfRuin.isActive {
            // TODO: - Chat Dialogue for Age of Ruin

            //AGE OF RUIN - DARK REALM Dialogue
            //enter dialogue here...
            

            //AGE OF RUIN - PUZZLE REALM Dialogue

            dialoguePlayed[201] = false
        }
        else {
            // TODO: - AGE OF BALANCE - CATWALK Dialogue
            
            dialoguePlayed[-999] = false
            dialoguePlayed[-1000] = false
            dialoguePlayed[-1006] = false
            dialoguePlayed[-1010] = false
            dialoguePlayed[-1016] = false
            dialoguePlayed[-1019] = false
            dialoguePlayed[-1025] = false
            dialoguePlayed[-1027] = false
            dialoguePlayed[-1033] = false
            dialoguePlayed[-1034] = false
            
            
            //AGE OF BALANCE - DARK REALM Dialogue

            dialoguePlayed[-100] = false
            dialoguePlayed[-150] = false
            dialoguePlayed[-200] = false
            dialoguePlayed[-250] = false
            dialoguePlayed[-300] = false
            
            
            //AGE OF BALANCE - PUZZLE REALM Dialogue
            
            //Chapter 0 - The Tutorial
            dialoguePlayed[1] = false
            dialoguePlayed[13] = false
            dialoguePlayed[19] = false
            dialoguePlayed[34] = false
            dialoguePlayed[51] = false
            dialoguePlayed[76] = false
            dialoguePlayed[PauseResetEngine.resetButtonUnlock] = false //Level: 100
            
            //Chapter 1 - In Search of the Princess
            dialoguePlayed[101] = false
            dialoguePlayed[112] = false
            dialoguePlayed[PauseResetEngine.hintButtonUnlock] = false //Level: 140
            dialoguePlayed[151] = false
            dialoguePlayed[180] = false
            
            //Chapter 2 - A Mysterious Stranger
            dialoguePlayed[201] = false
            dialoguePlayed[221] = false
            dialoguePlayed[251] = false
            dialoguePlayed[276] = false //spawn at (0, 1)
            dialoguePlayed[282] = false
            dialogueWithCutscene[282] = false
            dialoguePlayed[298] = false //spawn at (0, 1)
            
            //Chapter 3 - You're on Your Own, Kid!
            dialoguePlayed[301] = false
            dialogueWithCutscene[301] = false
            dialoguePlayed[319] = false
            dialoguePlayed[339] = false
            dialoguePlayed[351] = false
            dialoguePlayed[376] = false
            
            //Chapter 4 - The Home Stretch
            dialoguePlayed[401] = false
            dialoguePlayed[412] = false
            dialoguePlayed[417] = false
            dialoguePlayed[434] = false
            dialoguePlayed[441] = false
            dialoguePlayed[451] = false
            dialoguePlayed[475] = false
        }
    }
    
    ///Sets up the dialogue for the Tiki statues. Call this from init().
    private func setupStatueDialogue() {
        
        //For use by Trudee the Truth-telling Tiki
        let currentSky: String
        
        switch DayTheme.currentTheme {
        case .morning:      currentSky = " a bright blue."
        case .afternoon:    currentSky = " a pinkish orange."
        case .night:        currentSky = " a deep sapphire."
        case .dawn:         currentSky = " a lavender haze."
        case .blood:        currentSky = "... gone. Just, gone. WHAT DID YOU DO?!?!"
        }
        
        
        //Lv 319 - Ingrid the Introducer
        dialogueStatue0 = StatueDialogue(dialogue: [
            //0: 7
            ChatItem(profile: .hero, imgPos: .left, chat: "What the heck is this.....?"),
            ChatItem(profile: .statue0, chat: "🎵 ALOHA! We are ancient relics of the forest known as \"Tikis.\" Think of us as friendly guides to help you on your way."),
            ChatItem(profile: .hero, imgPos: .left, chat: "Whoa, it talks!"),
            ChatItem(profile: .statue0, chat: "Some of us may ask you an important question that can alter the course of your journey, so make sure you answer carefully and truthfully."),
            ChatItem(profile: .hero, imgPos: .left, chat: "There's more of you??"),
            ChatItem(profile: .statue0, chat: "There are! We are scattered throughout the PUZZLE REALM. Dance with us! 🎶"),
            ChatItem(profile: .hero, imgPos: .left, chat: "I'm good."),

            //1: 3
            ChatItem(profile: .hero, imgPos: .left, chat: "When is Marlin coming back?"),
            ChatItem(profile: .statue0, chat: "The answer to that question is............"),
            ChatItem(profile: .statue0, chat: "...a difficult one to predict!"),
            
            //2: 3
            ChatItem(profile: .hero, imgPos: .left, chat: "Is Princess Olivia safe?"),
            ChatItem(profile: .statue0, chat: "Let me look into that for you............"),
            ChatItem(profile: .statue0, chat: "...ask again later!"),
            
            //3: 4
            ChatItem(profile: .hero, imgPos: .left, chat: "Where is Magmoor keeping her?"),
            ChatItem(profile: .statue0, chat: "Another great question! To which I reply............"),
            ChatItem(profile: .statue0, chat: "...I don't know!"),
            ChatItem(profile: .hero, imgPos: .left, chat: "You're not very helpful. 😒"),

            //Single dialogue
            ChatItem(profile: .statue0, chat: "Here's something helpful: don't forget to Rate and Review this game on the App Store!"),
            ChatItem(profile: .statue0, chat: "Stuck? Take a break. Come back when your mind is clear 💆🏻‍♂️"),
            ChatItem(profile: .statue0, chat: "Princess Olivia.. I heard she possesses very powerful magic. Though it's just a rumor..."),
            ChatItem(profile: .statue0, chat: "You won't find her standing around here. Get moving!"),
            ChatItem(profile: .statue0, chat: "Tick tock. Time's a wasting!"),
        ], indices: [7, 3, 3, 4, 1, 1, 1, 1, 1], shouldSkipFirstQuestion: false, shouldRepeatLastDialogueOnEnd: false)
        
        
        //Lv 339 - Penne the Poet
        dialogueStatue1 = StatueDialogue(dialogue: [
            //0: 7 - Story branching decision question
            ChatItem(profile: .statue1, chat: "Some say the world will end in fire,\nSome say in ice.\nFrom what I've tasted of desire\nI hold with those who favor fire."),
            ChatItem(profile: .statue1, chat: "But if it had to perish twice,\nI think I know enough of hate\nTo say that for destruction ice\nIs also great\nAnd would suffice."),
            ChatItem(profile: .hero, imgPos: .left, chat: "Robert Frost!") { [weak self] in
                guard let self = self else { return }
                
                chatDecisionEngine.showDecisions(index: 1, toNode: chatBackgroundSprite, displayOnLeft: true)
            },
            ChatItem(profile: .statue1, chat: "How do you want the world to end?") { [weak self] in
                self?.animateFateSealed()
                self?.hideFFButton()
            },
            ChatItem(profile: .statue1, chat: "Your fate has been sealed!!") { [weak self] in
                self?.showFFButton()
            },
            ChatItem(profile: .hero, imgPos: .left, chat: "Wait, what?? No! I didn't—"),
            ChatItem(profile: .statue1, chat: "With every choice comes a consequence! Remember that for next time, PUZL Boy."),
            
            //1: 4
            ChatItem(profile: .hero, imgPos: .left, chat: "Is the world going to end??!!"),
            ChatItem(profile: .statue1, chat: "Not necessarily. You and I won't be here forever, but the world will keep on spinning."),
            ChatItem(profile: .statue1, chat: "Well.. you won't be here. I will."),
            ChatItem(profile: .hero, imgPos: .left, chat: "😳"),
            
            //2: 2
            ChatItem(profile: .hero, imgPos: .left, chat: "Tell me how to find the princess."),
            ChatItem(profile: .statue1, chat: "When she is ready, she will come to you."),

            //3: 2
            ChatItem(profile: .hero, imgPos: .left, chat: "Please! Help me!!"),
            ChatItem(profile: .statue1, chat: "Trust your instincts, kid. You've made it this far. Do not give up!"),
        ], indices: [7, 4, 2, 2], shouldSkipFirstQuestion: FIRManager.decisionsLeftButton[1] != nil, shouldRepeatLastDialogueOnEnd: false)
        
        
        //Lv 351 - Lars the Liar
        dialogueStatue2 = StatueDialogue(dialogue: [
            //0: 4
            ChatItem(profile: .statue2, chat: "Whaddup, bro! You want to know all about the new terrain, amirite?"),
            ChatItem(profile: .statue2, chat: "Look, it's real simple, bro. Whatever you do, don't backtrack or you'll be in a lotta trouble, get what I'm sayin', bro?"),
            ChatItem(profile: .hero, imgPos: .left, chat: "No, I don't. Bro."),
            ChatItem(profile: .statue2, chat: "Broooo! Just keep moving forward. Ya feel me?"),
            
            //1: 9
            ChatItem(profile: .hero, imgPos: .left, chat: "Can you tell me where the princess is?"),
            ChatItem(profile: .statue2, chat: "Ok look, bro. I may not know about allat, but what I do know is you can get to her with a special key."),
            ChatItem(profile: .hero, imgPos: .left, chat: "Special key???"),
            ChatItem(profile: .statue2, chat: "Yeah, bro! The Special Key is buried somewhere in Level 405."),
            ChatItem(profile: .statue2, chat: "...or was it 450? 504???? No, it was 405!"),
            ChatItem(profile: .hero, imgPos: .left, chat: "Are you sure???"),
            ChatItem(profile: .statue2, chat: "Don't doubt me, bro! It's next to the Golden Dragon. But.. you can only beat him with the Golden Sword."),
            ChatItem(profile: .hero, imgPos: .left, chat: "Golden dragon. Golden sword. Special key. Level 405."),
            ChatItem(profile: .statue2, chat: "💯 bro!!! Wait.. or was it 417? Uhhh.. better check 'em all."),
            
            //2: 6
            ChatItem(profile: .statue2, chat: "You hear about the legend of Marlin and Magmoor?"),
            ChatItem(profile: .hero, imgPos: .left, chat: "They were friends at one point, from what I gather."),
            ChatItem(profile: .statue2, chat: "Yeah bro, that's one way of putting it."),
            ChatItem(profile: .hero, imgPos: .left, chat: "Care to elaborate?"),
            ChatItem(profile: .statue2, chat: "Nah, bro. Not really my business, know what I'm sayin'?"),
            ChatItem(profile: .hero, imgPos: .left, chat: "Then why did you bring it up?!"),

            //3: 4
            ChatItem(profile: .statue2, chat: "Oh heyy! I found this magical feather. It wards off the 6-eyed, purple-horned monster."),
            ChatItem(profile: .hero, imgPos: .left, chat: "Uhh.. ok, thanks I guess... Does it really work?"),
            ChatItem(profile: .statue2, chat: "Do ya see any 6-eyed, purple-horn monsters around here???") { [weak self] in
                self?.animateFeather()
                self?.hideFFButton()
                
                FIRManager.updateFirestoreRecordHasFeather(true)
                self?.dialogueStatue3.setShouldSkipFirstQuestion(false) //set it for Trudee
            },
            ChatItem(profile: .blankhero, chat: "\n\nReceived Plume of Seraphim's Grace.") { [weak self] in
                self?.showFFButton()
            },
            
            //4: 4
            ChatItem(profile: .statue2, chat: "Oh! Also you might need this password later on: 1123581321345589144"),
            ChatItem(profile: .hero, imgPos: .left, chat: "Whoa, whoa. Slow down! What do I do with that??"),
            ChatItem(profile: .statue2, chat: "I dunno, bro! All I know is it's very important later on in the story."),
            ChatItem(profile: .statue2, chat: "Hope ya writin' all this down cuz I ain't repeating myself."),

            //5: 3
            ChatItem(profile: .hero, imgPos: .left, chat: "Can you tell me that password one more time?"),
            ChatItem(profile: .statue2, chat: "Yeah sure! It's.......... Huh, weird. I forgot it already!"),
            ChatItem(profile: .hero, imgPos: .left, chat: "You've got to be kidding me.. 🙄"),
            
            //6: 2
            ChatItem(profile: .hero, imgPos: .left, chat: "Sigh. Anything else you can tell me?"),
            ChatItem(profile: .statue2, chat: "Nope.") { [weak self] in
                self?.dialogueStatue2.setShouldRepeatLastDialogueOnEnd(true) //need this here otherwise it'll loop back to dialogue at index 0.
            }
        ], indices: [4, 9, 6, 4, 4, 3, 2], shouldSkipFirstQuestion: false, shouldRepeatLastDialogueOnEnd: FIRManager.hasFeather != nil)
        
        //Lv 376 - Trudee the Truth-telling Tiki
        dialogueStatue3 = StatueDialogue(dialogue: [
            //0: 10 - Story branching decision question
            ChatItem(profile: .hero, imgPos: .left, chat: "Hey! The last Tiki gave me a bunch of info and I forgot it all now. Do you know anything about a password or a golden dragon?"),
            ChatItem(profile: .statue3, chat: "Oh my heavens! You spoke to Lars the Liar? He lies like no other! No wonder you're a mess!"),
            ChatItem(profile: .hero, imgPos: .left, chat: "...........What. 🤨"),
            ChatItem(profile: .statue3, chat: "Yeah! Do you really think 6-eyed, purple-horn monsters and golden dragons exist??"),
            ChatItem(profile: .hero, imgPos: .left, chat: "I dunno!! I assumed you guys are here to help me! So then there's no special key or password? What about this stupid feather?"),
            ChatItem(profile: .statue3, chat: "Utterly useless! Here, I'll take the stupid feather off your hands. No use carrying it around."),
            ChatItem(profile: .hero, imgPos: .left, chat: "Wait, I didn't mention the 6-eyed, purple-horn monster. How do I know you're not a liar??"),
            ChatItem(profile: .statue3, chat: "Because I'm Trudee the truth-telling Tiki. Therefore, I tell the total truth. Now.. gimme!") { [weak self] in
                guard let self = self else { return }
                
                chatDecisionEngine.showDecisions(index: 2, toNode: chatBackgroundSprite)
            },
            ChatItem(profile: .hero, imgPos: .left, chat: "Hmmm.......") { [weak self] in
                self?.animateFeather()
                self?.hideFFButton()
            },
            ChatItem(profile: .hero, imgPos: .left, chat: "You really want this feather, don't you?!?") { [weak self] in
                self?.showFFButton()
            },

            //1: 1
            ChatItem(profile: .statue3, chat: "Hello! I'm Trudee the truth-telling Tiki. I tell the total truth!"),
            
            //2: 4
            ChatItem(profile: .hero, imgPos: .left, chat: "Ok, \"Truth-teller.\" Where are Marlin, Magmoor and the princess?"),
            ChatItem(profile: .statue3, chat: "Right under your feet!"),
            ChatItem(profile: .hero, imgPos: .left, chat: "You're not lying to me, are you?!"),
            ChatItem(profile: .statue3, chat: "I always tell the truth!"),
            
            //Single dialogue
            ChatItem(profile: .statue3, chat: "Magmoor was once quite the good-looking Mystic. Popular, too. Always the center of attention, he was."),
            ChatItem(profile: .statue3, chat: "This game has multiple endings. See if you can unlock them!"),
            ChatItem(profile: .statue3, chat: "The sky is\(currentSky)")
        ], indices: [10, 1, 4, 1, 1, 1], shouldSkipFirstQuestion: FIRManager.hasFeather == nil || !FIRManager.hasFeather! || FIRManager.decisionsLeftButton[2] != nil, shouldRepeatLastDialogueOnEnd: false)

        
        //Lv 401 - Mimi the Tiki
        dialogueStatue4 = StatueDialogue(dialogue: [
            //0: 4
            ChatItem(profile: .hero, imgPos: .left, chat: "Are you a liar? Or do you tell the absolute truth?"),
            ChatItem(profile: .statue4, chat: "I don't know what any of that means."),
            ChatItem(profile: .statue4, chat: "BUT! Before you step onto the blue colored warp, you should know that it will transport you to—"),
            ChatItem(profile: .hero, imgPos: .left, chat: "—to the blue warp. Pretty obvious."),
            
            //1: 2
            ChatItem(profile: .statue4, chat: "There's a reddish haze that lingers in the air. It gets heavier the deeper you go. Makes it hard to breathe sometimes."),
            ChatItem(profile: .hero, imgPos: .left, chat: "Yeah! I did notice it's harder to breathe down here. Figured it was just my anxiety."),
            
            //2: 1
            ChatItem(profile: .statue4, chat: "It never used to be this way... until he arrived. He's not fit to rule. Oops.. don't tell him I said that!"),
            
            //3: 3
            ChatItem(profile: .hero, imgPos: .left, chat: "Please just tell me where I can find them."),
            ChatItem(profile: .statue4, chat: "Of course. They're right under your feet!"),
            ChatItem(profile: .hero, imgPos: .left, chat: "GAAAAAHHHHHH!!!!!! I'M DONE WITH YOU PEOPLE!!! USELESS! ALL OF YOU!!!! 🤬"),
            
            //4: 1
            ChatItem(profile: .statue4, chat: "We're not people, silly boy. We're Tikis!")
        ], indices: [4, 2, 1, 3, 1], shouldSkipFirstQuestion: false, shouldRepeatLastDialogueOnEnd: false)
        
        
        //Lv 475 - Trudee, again
        dialogueStatue3b = StatueDialogue(dialogue: [
            //0: 6
            ChatItem(profile: .statue3b, chat: "WELCOME TO YOUR DOOM!"),
            ChatItem(profile: .hero, imgPos: .left, chat: "NOOOOOOO!!!"),
            ChatItem(profile: .statue3b, chat: "Kidding! I wouldn't do that to you. Look, that Tiki was not one of us, okay? Daemon the Destroyer was sent by Magmoor to traumatize you."),
            ChatItem(profile: .hero, imgPos: .left, chat: "Well, it worked!!"),
            ChatItem(profile: .statue3b, chat: "And you've been such a doll through all this. Answering our questions. And giving me this most luxurious feather. Please accept this little gift from all of us.") { [weak self] in
                self?.hideFFButton()
                self?.delegate?.getGift(lives: StatueDialogue.giftOfLives)
                FIRManager.updateFirestoreRecordGotGift(FIRManager.didGiveAwayFeather)
            },
            ChatItem(profile: .blankhero, chat: "\n\nPUZL Boy received 25 lives.") { [weak self] in
                self?.showFFButton()
                AudioManager.shared.playSound(for: "boywin")
            },
            
            //1: 2
            ChatItem(profile: .hero, imgPos: .left, chat: FIRManager.didGiveAwayFeather ? "Thanks for the generous gift, Trudee!! And that feather looks fetching on you!" : "What are you doing here?"),
            ChatItem(profile: FIRManager.didGiveAwayFeather ? .statue3b : .statue3, chat: FIRManager.didGiveAwayFeather ? "Best of luck, PUZL Boy. Take him down for us!" : "Just hanging out. Nothing to see here. Just wish I had that fabulous feather...") { [weak self] in
                self?.dialogueStatue3b.setShouldRepeatLastDialogueOnEnd(true) //need this here otherwise it'll loop back to dialogue at index 0.
                
                if FIRManager.gotGift == nil {
                    FIRManager.updateFirestoreRecordGotGift(FIRManager.didGiveAwayFeather)
                }
            }
        ], indices: [6, 2], shouldSkipFirstQuestion: !FIRManager.didGiveAwayFeather || FIRManager.didReceiveGiftFromTiki, shouldRepeatLastDialogueOnEnd: false)
    }
    
    /**
     Main function to play chat dialogue for a given level.
     - parameters:
        - level: the level # for the chat dialogue to play
        - completion: completion handler to execute at the end of the dialogue
     */
    func playDialogue(level: Int, statueTapped: Bool = false, completion: ((Cutscene?) -> Void)?) {
        guard let dialoguePlayedCheck = dialoguePlayed[level], !dialoguePlayedCheck || statueTapped else {
            isChatting = false
            completion?(nil)
            return
        }

        isChatting = true

        if AgeOfRuin.isActive {
            playDialogueAgeOfRuin(level: level, completion: completion)
        }
        else {
            playDialogueAgeOfBalance(level: level, statueTapped: statueTapped, completion: completion)
        }
    }//end playDialogue(level:statueTapped:completion:)
    
    ///Sets up and plays dialogue for Age of Balance setting.
    private func playDialogueAgeOfBalance(level: Int, statueTapped: Bool, completion: ((Cutscene?) -> Void)?) {
        switch level {
            
        // TODO: - CATWALK Dialogue TEST for now
            
        case -999:
            sendChatArray(items: [
                ChatItem(profile: .melchior, chat: "Where are you going, PUZL Boy? The only way out is through!")
            ]) { [weak self] in
                self?.handleDialogueCompletion(level: level, completion: completion)
            }
        case -1000:
            let leftButton0 = FIRManager.decisionsLeftButton[0] ?? false
            
            delegate?.spawnEldersCatwalk()
            
            sendChatArray(items: [
                ChatItem(profile: .melchior, chat: "The road ahead is dangerous. There is no turning back. Are you ready to face the darkness?"),
                ChatItem(profile: .hero, imgPos: .left, chat: "\(leftButton0 ? "I'm ready, let's go!!" : "No time like the present! What have we got to lose, right?")"),
                ChatItem(profile: .magmus, chat: "Be warned: Magmoor seeks to destroy everything and everyone in his path, especially the ones who banished him to the NETHER REALM hundreds of years ago."),
                ChatItem(profile: .hero, imgPos: .left, chat: "\(leftButton0 ? "So... technically this is your fight. Can I just sit and watch from the sidelines, or..." : "I've made it this far, I'm not backing down now!")"),
                ChatItem(profile: .magmus, chat: "Do not underestimate our adversary. He has the ability to wipe out all life from existence! It will take our combined strength to vanquish him."),
                ChatItem(profile: .melchior, chat: "Though he may seem beyond powerful, he has his weaknesses. We did, of course, teach him everything he knows."),
                ChatItem(profile: .hero, imgPos: .left, chat: "\(leftButton0 ? "Like I said, I'mma sit here and wait while you guys do your thang." : "He has my friends—Marlin and the princess. I won't go down without a fight!")"),
                ChatItem(profile: .merton, chat: "Remember, he is most malevolent from the merger with our dear Marlin's magic."),
                ChatItem(profile: .merton, chat: "As you proceed, you may witness illusions of despair. But despair not! For all they are are illusions, after all."),
                ChatItem(profile: .melchior, chat: "Let's move forward. And do not believe anything you see or hear.")
            ]) { [weak self] in
                self?.delegate?.despawnEldersCatwalk()
                self?.handleDialogueCompletion(level: level, completion: completion)
            }
        case -1006:
            delegate?.flashRedCatwalk(message: "Turn back now...") { [weak self] in
                self?.handleDialogueCompletion(level: level, completion: completion)
            }
        case -1010:
            delegate?.flashRedCatwalk(message: "You're going to regret it...") { [weak self] in
                self?.sendChatArray(shouldSkipDim: true, items: [
                    ChatItem(profile: .magmus, chat: "Ignore him! Do not let him get inside your head.")
                ]) {
                    self?.handleDialogueCompletion(level: level, completion: completion)
                }
            }
        case -1016:
            delegate?.shiftRedCatwalk(shouldShift: true, showMagmoorScary: false)
            handleDialogueCompletion(level: level, completion: completion)
        case -1019:
            delegate?.spawnPrincessCatwalk()
            
            sendChatArray(shouldSkipDim: true, items: [
                ChatItem(profile: .princessCursed, chat: "you let me down, puzl boy! gaze upon your failures."),
                ChatItem(profile: .hero, imgPos: .left, chat: "No! We're coming to rescue you, princess! Just hang tight for a sec!"),
                ChatItem(profile: .merton, chat: "Dear boy, that is NOT the princess. It is but a phantasmagoria of Magmoor's machinations. We must keep moving!")
            ]) { [weak self] in
                self?.delegate?.despawnPrincessCatwalk()
                self?.delegate?.shiftRedCatwalk(shouldShift: false, showMagmoorScary: false)
                self?.handleDialogueCompletion(level: level, completion: completion)
            }
        case -1025:
            delegate?.shiftRedCatwalk(shouldShift: true, showMagmoorScary: false)
            handleDialogueCompletion(level: level, completion: completion)
        case -1027:
            delegate?.spawnMarlinCatwalk()
            
            sendChatArray(shouldSkipDim: true, items: [
                ChatItem(profile: .trainer, chat: "you have doomed us all, puzl boy! the day of reckoning is at hand."),
                ChatItem(profile: .hero, imgPos: .left, chat: "I didn't do it! I'm just a kid. It's not my fault!!"),
                ChatItem(profile: .magmus, chat: "Disregard this false imagery, child! You must not succumb to his deception. Clarity is needed in the challenge ahead.")
            ]) { [weak self] in
                self?.delegate?.despawnMarlinCatwalk()
                self?.delegate?.shiftRedCatwalk(shouldShift: false, showMagmoorScary: false)
                self?.handleDialogueCompletion(level: level, completion: completion)
            }
        case -1033:
            delegate?.shiftRedCatwalk(shouldShift: true, showMagmoorScary: true)
            delegate?.spawnMagmoorCatwalk()
            
            sendChatArray(shouldSkipDim: true, items: [
                ChatItem(profile: .villain, chat: "You are too late, Earth traveler. The end has begun."),
                ChatItem(profile: .melchior, imgPos: .left, chat: "You will regret ever entering this realm, Magmoor! Your reign of terror ends here!!"),
                ChatItem(profile: .hero, imgPos: .left, chat: "I matter! I am enough!!!")
            ]) { [weak self] in
                self?.handleDialogueCompletion(level: level, completion: completion)
            }
        case -1034:
            delegate?.despawnMagmoorCatwalk() { [weak self] in
                self?.delegate?.shiftRedCatwalk(shouldShift: false, showMagmoorScary: true)
                self?.handleDialogueCompletion(level: level, completion: completion)
            }
            
            
        //DARK REALM
        case Level.partyLevel: //IMPORTANT: This case, Level.partyLevel must ALWAYS be here!!!
            delegate?.spawnTrainer(at: (0, 0), to: .right)
            
            sendChatArray(items: [
                ChatItem(profile: .hero, imgPos: .left, chat: "Dude, I feel funny. I'm seeing colorful flashing lights and the music is bumpin'. I can't stop moving!"),
                ChatItem(profile: .trainer, chat: "Welcome to the DARK REALM, the hidden realm that exists between PUZZLE REALMS. You ate one of those rainbow colored jelly beans, I see."),
                ChatItem(profile: .hero, imgPos: .left, chat: "Jelly beans, right..."),
                ChatItem(profile: .trainer, chat: "Don't worry, the feeling lasts only a short amount of time, but while you're under its effects you can move to your heart's content."),
                ChatItem(profile: .trainer, chat: "Run around collecting all the gems and bonuses that pop up in the level. But you gotta be quick before time runs out."),
                ChatItem(profile: .trainer, chat: "Oh, and the one thing you want to look out for are rainbow bombs."),
                ChatItem(profile: .trainer, chat: "Like, I know they're all pretty and fun looking, but avoid them at all costs, or it's the end of the bonus round."),
                ChatItem(profile: .trainer, chat: "Why is it always the pretty things in life that are the most deadly..."),
                ChatItem(profile: .hero, imgPos: .left, chat: "Don't step on the bombs. Got it."),
                ChatItem(profile: .trainer, chat: "OK. Now if the flashing lights become too much, you can tap the disco ball below to turn them off. 🪩 READY. SET. GO!")
            ]) { [weak self] in
                self?.delegate?.despawnTrainer(to: (0, 0))
                self?.handleDialogueCompletion(level: level, completion: completion)
            }
        case -100:
            AudioManager.shared.playSound(for: "magicheartbeatloop1", fadeIn: 3)
            delegate?.spawnTrainer(at: (0, 0), to: .unknown)

            sendChatArray(items: [
                ChatItem(profile: .blankvillain, chat: "\n\n...turn back now, before it's too late..."),
                ChatItem(profile: .trainer, imgPos: .left, chat: "Who are you!"),
                ChatItem(profile: .blankvillain, chat: "\n\n...the question is, where are we?..."),
                ChatItem(profile: .trainer, imgPos: .left, chat: "We are in the DARK REALM where evil cannot reach. What business do you have here?!") { [weak self] in
                    
                    self?.hideFFButton()
                },
                ChatItem(profile: .blankvillain, chat: "\n\n...all will be revealed soon...") { [weak self] in
                    guard let self = self else { return }
                    
                    superScene?.addChild(marlinBlast)
                    marlinBlast.animateBlast(playSound: true)

                    chatSpeed = chatSpeedImmediate
                },
                ChatItem(profile: .trainer, imgPos: .left, chat: "⚡️REVEAL YOURSELF!!!⚡️") { [weak self] in
                    guard let self = self else { return }
                    
                    AudioManager.shared.playSoundThenStop(for: "littlegirllaugh", playForDuration: 5, fadeOut: 2)
                    
                    chatSpeed = chatSpeedOrig
                },
                ChatItem(profile: .blankvillain, chat: "\n\n...heh heh heh heh...")
            ]) { [weak self] in
                AudioManager.shared.stopSound(for: "magicheartbeatloop1", fadeDuration: 5)

                self?.showFFButton()
                self?.chatBackgroundSprite.run(SKAction.wait(forDuration: 3)) {
                    self?.marlinBlast.removeFromParent()

                    self?.delegate?.despawnTrainer(to: (0, 0))
                    self?.handleDialogueCompletion(level: level, completion: completion)
                }
            }
        case -150:
            AudioManager.shared.playSound(for: "magicheartbeatloop1", fadeIn: 3)
            delegate?.spawnTrainer(at: (0, 0), to: .unknown)

            sendChatArray(items: [
                ChatItem(profile: .blankvillain, chat: "\n\n...Marlin..."),
                ChatItem(profile: .trainer, imgPos: .left, chat: "Geez! Would you stop doing that?? It's most unsettling!"),
                ChatItem(profile: .blankvillain, chat: "\n\n...you're going to regret your decision..."),
                ChatItem(profile: .trainer, imgPos: .left, chat: "You will be the one to regret it if you don't tell me where the princess is!!"),
                ChatItem(profile: .blankvillain, chat: "\n\n...she is home now..."),
                ChatItem(profile: .trainer, imgPos: .left, chat: "Where is she?!! Is she unharmed??"),
                ChatItem(profile: .blankvillain, chat: "\n\n...see for yourself...") { [weak self] in
                    AudioManager.shared.playSoundThenStop(for: "littlegirllaugh", playForDuration: 1, fadeOut: 3)
                    AudioManager.shared.stopSound(for: "magicheartbeatloop1", fadeDuration: 4)

                    self?.hideFFButton()
                },
                ChatItem(profile: .princessCursed, chat: "i am fine. don't worry about me. now leave us."),
                ChatItem(profile: .blankvillain, chat: "\n\n...see??? she's perfectly fine..."),
                ChatItem(profile: .trainer, imgPos: .left, chat: "Listen!! You have no idea who you're dealing with, so enough with the games! Now, show me who you are!!") { [weak self] in
                    guard let self = self else { return }
                    
                    superScene?.addChild(marlinBlast)
                    superScene?.addChild(magmoorScary)

                    marlinBlast.animateBlast(playSound: false)
                    magmoorScary.flashImage(delay: 0.25)

                    AudioManager.shared.playSound(for: "magicheartbeatloop2")
                    AudioManager.shared.playSoundThenStop(for: "scarylaugh", playForDuration: 2, fadeOut: 2, delay: 4.5)

                    chatSpeed = chatSpeedImmediate
                },
                ChatItem(profile: .trainer, imgPos: .left, chat: "⚡️MAGIC SPELL!!!⚡️") { [weak self] in
                    //...but don't forget to add fastForwardSprite back to chatBackgroundSprite!!
                    self?.showFFButton()
                },
                ChatItem(profile: .villain, chat: "MYSTERIOUS FIGURE: I'll be seeing ya shortly."),
                ChatItem(profile: .trainer, imgPos: .left, chat: "..........no. It can't be..")
            ]) { [weak self] in
                
                AudioManager.shared.stopSound(for: "magicheartbeatloop2", fadeDuration: 5)
                
                self?.chatBackgroundSprite.run(SKAction.wait(forDuration: 3)) {
                    self?.marlinBlast.removeFromParent()
                    self?.magmoorScary.removeFromParent()
                    
                    self?.delegate?.despawnTrainer(to: (0, 0))
                    self?.handleDialogueCompletion(level: level, completion: completion)
                }
            }
        case -200:
            delegate?.spawnTrainer(at: (0, 0), to: .unknown)

            sendChatArray(items: [
                ChatItem(profile: .trainer, imgPos: .left, chat: "Hello..........? Are you there??"),
                //Needs like a 5 second pause here.
                ChatItem(profile: .trainer, imgPos: .left, chat: "................................") { [weak self] in
                    self?.hideFFButton()
                },
                ChatItem(profile: .trainer, imgPos: .left, chat: "Hmm.")
            ]) { [weak self] in
                self?.showFFButton()
                
                self?.chatBackgroundSprite.run(SKAction.wait(forDuration: 3)) {
                    self?.delegate?.despawnTrainer(to: (0, 0))
                    self?.handleDialogueCompletion(level: level, completion: completion)
                }
            }
        case -250:
            AudioManager.shared.playSound(for: "magicheartbeatloop1", fadeIn: 3)
            delegate?.spawnTrainer(at: (0, 0), to: .unknown)
            
            let originalBrightness: CGFloat = UIScreen.main.brightness
            
            if originalBrightness < 0.25 {
                UIScreen.main.brightness = 0.25
            }
            else if originalBrightness < 0.5 {
                UIScreen.main.brightness = 0.5
            }
            
            superScene?.addChild(magmoorScary)

            sendChatArray(items: [
                ChatItem(profile: .villain, chat: "MYSTERIOUS FIGURE: You'll never find her. You can keep trying, but it will all be in vain. Give up now...") { [weak self] in
                    self?.magmoorScary.slowReveal(baseAlpha: 0.1)
                },
                ChatItem(profile: .trainer, imgPos: .left, chat: "YOU!!! I should have known! The whole time I'm thinking, \"No way he came crawling back into my life.\" And here you are... lurking in the shadows.") { [weak self] in
                    AudioManager.shared.playSound(for: "scarymusicbox", fadeIn: 10)

                    self?.magmoorScary.slowReveal(baseAlpha: 0.2)
                },
                ChatItem(profile: .villain, chat: "Surprised much? You need me. You're the yin to my yang."),
                ChatItem(profile: .villain, chat: "We're bounded by fate as elder Mystic, Machinegunkelly revealed during the Trial of Mages.") { [weak self] in
                    self?.magmoorScary.slowReveal(baseAlpha: 0.3)
                },
                ChatItem(profile: .trainer, imgPos: .left, chat: "That was over 500 years ago. Give us the child and leave this world!!") { [weak self] in
                    self?.magmoorScary.slowReveal(baseAlpha: 0.4)
                },
                ChatItem(profile: .villain, chat: "We would have made a great duo: the strongest Mystics in all the realms. But you chose a different path ..............why did you leave me?") { [weak self] in
                    self?.magmoorScary.slowReveal(baseAlpha: 0.5)
                },
                ChatItem(profile: .trainer, imgPos: .left, chat: "..............I did what I had to."),
                ChatItem(profile: .villain, chat: "Ah, yes. The self-serving \"Marlin the Magnificent.\" Always thinking he's right. Hmpf! Your loss.. such a shame.. we could've had it all....."),
                ChatItem(profile: .trainer, imgPos: .left, chat: "It's my loss.....")
            ]) { [weak self] in
                self?.delegate?.despawnTrainer(to: nil)
                AudioManager.shared.stopSound(for: "scarymusicbox", fadeDuration: 5)
                AudioManager.shared.stopSound(for: "magicheartbeatloop1", fadeDuration: 5)
                
                self?.chatBackgroundSprite.run(SKAction.wait(forDuration: 3)) {
                    self?.handleDialogueCompletion(level: level) { _ in
                        self?.magmoorScary.resetAlpha()
                        self?.magmoorScary.removeFromParent()
                        
                        UIScreen.main.brightness = originalBrightness
                        
                        completion?(nil)
                    }
                }
            }
        case -300:
            AudioManager.shared.playSound(for: "magicheartbeatloop1", fadeIn: 3)
            delegate?.spawnTrainer(at: (0, 0), to: .unknown)

            sendChatArray(items: [
                ChatItem(profile: .trainer, imgPos: .left, chat: "So you're saying if I merge powers with you, you'll let the princess go?"),
                ChatItem(profile: .villain, chat: "The princess will be free to do whatever she wants..."),
                ChatItem(profile: .princess, chat: "What a relief!"),
                ChatItem(profile: .villain, chat: "...within reason. So what will it be, dear Marlin? Do you accept these terms, so we can begin the merging ritual?"),
                ChatItem(profile: .trainer, imgPos: .left, chat: "..........I accept. *Sigh* This is all my fault. I never should have brought him here. I'll go with you, but first let me tell him."),
                ChatItem(profile: .villain, chat: "Fine. But make it quick. I've got a universe to rule."),
                ChatItem(profile: .trainer, imgPos: .left, chat: "Just do not harm the girl. Promise me."),
                ChatItem(profile: .villain, chat: "Yeah sure, but remember.. you belong to me now."),
                ChatItem(profile: .trainer, imgPos: .left, chat: "I hope he'll forgive me for this... 😞")
            ]) { [weak self] in
                AudioManager.shared.stopSound(for: "magicheartbeatloop1", fadeDuration: 5)

                self?.chatBackgroundSprite.run(SKAction.wait(forDuration: 3)) {
                    self?.delegate?.despawnTrainer(to: (0, 0))
                    self?.handleDialogueCompletion(level: level, completion: completion)
                }
            }
            
        //PUZZLE REALM
        case 1:
            delegate?.spawnTrainer(at: (1, 1), to: .right)
            
            sendChatArray(items: [
                ChatItem(profile: .hero, imgPos: .left, chat: "PUZL BOY: ...then one of the dragons swooped down and carried her away! It. Was. Harrowing. So... where are we? And who are you??"),
                ChatItem(profile: .trainer, chat: "OLD MAN: We must hurry! I suspect she is being taken to the dragon's lair. I have transported you to the PUZZLE REALM, our gateway to the lair."),
                ChatItem(profile: .hero, imgPos:.left, chat: "Cool. I like puzzles. You can call me...... PUZL Boy!"),
                ChatItem(profile: .trainer, chat: "MARLIN: Right.. I am your guide. You can call me Marlin. Now listen up!"),
                ChatItem(profile: .trainer, chat: "The dragon's lair is buried deep inside Earth's core, and the only way to reach it is by solving puzzles."),
                ChatItem(profile: .trainer, chat: "There are 500 levels in total you will have to complete, each with increasing difficulty.") { [weak self] in
                    self?.delegate?.despawnTrainer(to: (1, 2))
                },
                ChatItem(profile: .trainer, chat: "The goal for each level is to make it through the gate in under a certain number of moves.") { [weak self] in
                    self?.delegate?.illuminatePanel(at: (0, 1), useOverlay: false)
                    self?.delegate?.illuminatePanel(at: (1, 0), useOverlay: false)
                    self?.delegate?.illuminatePanel(at: (1, 2), useOverlay: false)
                    self?.delegate?.illuminatePanel(at: (2, 1), useOverlay: false)
                },
                ChatItem(profile: .trainer, chat: "You can move to any available panel on your left, right, above, and below. Simply tap the panel to move there. Diagonal moves are not allowed.") { [weak self] in
                    self?.delegate?.deilluminatePanel(at: (0, 1), useOverlay: false)
                    self?.delegate?.deilluminatePanel(at: (1, 0), useOverlay: false)
                    self?.delegate?.deilluminatePanel(at: (1, 2), useOverlay: false)
                    self?.delegate?.deilluminatePanel(at: (2, 1), useOverlay: false)
                    self?.delegate?.illuminateDisplayNode(for: .moves)
                },
                ChatItem(profile: .trainer, chat: "If your move count hits 0, it's game over buddy! Your move count can be found in the upper left corner next to the boot. 👢") { [weak self] in
                    self?.delegate?.deilluminateDisplayNode(for: .moves)
                    self?.delegate?.illuminatePanel(at: (1, 2), useOverlay: true)
                    self?.delegate?.illuminatePanel(at: (2, 2), useOverlay: false)
                },
                ChatItem(profile: .trainer, chat: "See the gate? It's sealed shut. To open it, collect all the gems in the level. Simple, right?"),
                ChatItem(profile: .hero, imgPos: .left, chat: "Right. Let's go save the princess!")
            ]) { [weak self] in
                self?.delegate?.deilluminatePanel(at: (1, 2), useOverlay: true)
                self?.delegate?.deilluminatePanel(at: (2, 2), useOverlay: false)

                self?.handleDialogueCompletion(level: level, completion: completion)
            }
        case 13:
            delegate?.illuminatePanel(at: (0, 1), useOverlay: true)
            delegate?.illuminatePanel(at: (0, 2), useOverlay: true)
            delegate?.illuminatePanel(at: (1, 2), useOverlay: true)
            
            sendChatArray(items: [
                ChatItem(profile: .trainer, chat: "Easy right? Levels get progressively harder the farther you go. Looks like that gem is trapped between those boulders.") { [weak self] in
                    self?.delegate?.illuminatePanel(at: (2, 1), useOverlay: true)
                },
                ChatItem(profile: .trainer, chat: "Not to worry! See that hammer over there? Use it to break through."),
                ChatItem(profile: .hero, imgPos: .left, chat: "Hammers break boulders. Got it."),
                ChatItem(profile: .trainer, chat: "Collect hammers as you go. They'll break after one use so be mindful of that.") { [weak self] in
                    self?.delegate?.illuminateDisplayNode(for: .hammers)
                },
                ChatItem(profile: .trainer, chat: "Your inventory count can be found in the upper right."),
                ChatItem(profile: .hero, imgPos: .left, chat: "I got this, dude!") { [weak self] in
                    self?.delegate?.deilluminateDisplayNode(for: .hammers)
                    self?.delegate?.deilluminatePanel(at: (0, 1), useOverlay: true)
                    self?.delegate?.deilluminatePanel(at: (0, 2), useOverlay: true)
                    self?.delegate?.deilluminatePanel(at: (1, 2), useOverlay: true)
                    self?.delegate?.deilluminatePanel(at: (2, 1), useOverlay: true)
                }
            ]) { [weak self] in
                self?.handleDialogueCompletion(level: level, completion: completion)
            }
        case 19:
            delegate?.illuminatePanel(at: (0, 1), useOverlay: false)
            delegate?.illuminatePanel(at: (2, 1), useOverlay: false)
            
            sendChatArray(items: [
                ChatItem(profile: .trainer, chat: "Watch out for poisonous marsh! Stepping on one of the crimson colored panels will drag you down, costing you 2 moves."),
                ChatItem(profile: .trainer, chat: "However, sometimes stepping in poisonous marsh is unavoidable."),
                ChatItem(profile: .hero, imgPos: .left, chat: "Man... and I just got these new kicks!")
            ]) { [weak self] in
                self?.delegate?.deilluminatePanel(at: (0, 1), useOverlay: false)
                self?.delegate?.deilluminatePanel(at: (2, 1), useOverlay: false)

                self?.handleDialogueCompletion(level: level, completion: completion)
            }
        case 34:
            delegate?.illuminatePanel(at: (0, 1), useOverlay: true)
            delegate?.illuminatePanel(at: (1, 2), useOverlay: true)
            
            sendChatArray(items: [
                ChatItem(profile: .trainer, chat: "Those fun looking things are warps. Falling into one of them will teleport you to the other one. Weeeeeeeee!"),
                ChatItem(profile: .hero, imgPos: .left, chat: "Uhhh, is it safe?"),
                ChatItem(profile: .trainer, chat: "I haven't tested it. Theoretically—"),
                ChatItem(profile: .hero, imgPos: .left, chat: "MERLIN!! Is it going to rip me apart or what?"),
                ChatItem(profile: .trainer, chat: "I'm sure you'll be fine. Just don't stare at it too long or I'll have you barking like a chicken at the snap of my fingers. ✨SNAP✨ 🫰🏼"),
                ChatItem(profile: .hero, imgPos: .left, chat: "Chickens don't bark, you nutty profess— 😵‍💫 Woof woof.")
            ]) { [weak self] in
                self?.delegate?.deilluminatePanel(at: (0, 1), useOverlay: true)
                self?.delegate?.deilluminatePanel(at: (1, 2), useOverlay: true)
        
                self?.handleDialogueCompletion(level: level, completion: completion)
            }
        case 51:
            delegate?.spawnTrainer(at: (0, 0), to: .right)
            delegate?.illuminatePanel(at: (1, 1), useOverlay: true)
            
            sendChatArray(items: [
                ChatItem(profile: .hero, imgPos: .left, chat: "That's him! That's the dragon that took the princess! 😡"),
                ChatItem(profile: .trainer, chat: "Relax... That's one of many dragons you'll encounter on your journey. But don't get too close or he'll attack, costing you 1 health point."),
                ChatItem(profile: .hero, imgPos: .left, chat: "He looks kinda small and underwhelming to me..."),
                ChatItem(profile: .trainer, chat: "Hey, this is a solo project with zero budget, whaddya want from me?! As I was saying...") { [weak self] in
                    self?.delegate?.illuminateDisplayNode(for: .health)
                },
                ChatItem(profile: .trainer, chat: "Once your health drops to 0, it's lights out! Your health can be found in the upper left next to the heart. 💖") { [weak self] in
                    self?.delegate?.deilluminateDisplayNode(for: .health)
                    self?.delegate?.illuminateDisplayNode(for: .swords)
                },
                ChatItem(profile: .trainer, chat: "Don't believe me? Go ahead. Try and pet him, I dare you! But you won't be able to defeat him without a sword. 🗡"),
                ChatItem(profile: .hero, imgPos: .left, chat: "Yeah, ok old man. Lemme guess, I can only use the sword once before it breaks?") { [weak self] in
                    self?.delegate?.deilluminateDisplayNode(for: .swords)
                },
                ChatItem(profile: .trainer, chat: "You got it. Atta boy! 🫰🏼"),
                ChatItem(profile: .hero, imgPos: .left, chat: "😵‍💫 Woof woof— Stop that!")
            ]) { [weak self] in
                self?.delegate?.despawnTrainer(to: (0, 0))
                self?.handleDialogueCompletion(level: level, completion: completion)
            }
        case 76:
            delegate?.illuminatePanel(at: (0, 1), useOverlay: false)
            delegate?.illuminatePanel(at: (0, 2), useOverlay: false)
            delegate?.illuminatePanel(at: (1, 2), useOverlay: false)
            delegate?.illuminatePanel(at: (0, 1), useOverlay: true)
            delegate?.illuminatePanel(at: (1, 2), useOverlay: true)
            
            sendChatArray(items: [
                ChatItem(profile: .trainer, chat: "You'll encounter frozen ground from time to time. Step on this and you'll slide until you hit an obstacle."),
                ChatItem(profile: .hero, imgPos: .left, chat: "Ice, ice, baby!"),
                ChatItem(profile: .trainer, chat: "The nice thing though is that it'll only cost you 1 move as long as you're sliding continuously."),
                ChatItem(profile: .hero, imgPos: .left, chat: "The cold never bothered me anyway."),
                ChatItem(profile: .trainer, chat: "I don't know what that is in reference to so just... let it go!") { [weak self] in
                    self?.delegate?.deilluminatePanel(at: (0, 1), useOverlay: false)
                    self?.delegate?.deilluminatePanel(at: (0, 2), useOverlay: false)
                    self?.delegate?.deilluminatePanel(at: (1, 2), useOverlay: false)
                    self?.delegate?.deilluminatePanel(at: (0, 1), useOverlay: true)
                    self?.delegate?.deilluminatePanel(at: (1, 2), useOverlay: true)
                },
            ]) { [weak self] in
                self?.handleDialogueCompletion(level: level, completion: completion)
            }
        case PauseResetEngine.resetButtonUnlock: //Level: 100
            delegate?.spawnTrainer(at: (0, 0), to: .right)
            
            sendChatArray(items: [
                ChatItem(profile: .trainer, chat: "Congrats! You made it to level \(PauseResetEngine.resetButtonUnlock). There's a little surprise waiting for you at the end. Beat this and you're one step closer to indescribable fun!!! 💃🏾🪩🕺🏻"),
                ChatItem(profile: .hero, imgPos: .left, chat: "I can hardly contain my excitement.") { [weak self] in
                    self?.delegate?.illuminateMinorButton(for: .reset)
                },
                ChatItem(profile: .trainer, chat: "That's the spirit! Now if you ever get stuck, you can tap the Reset button to restart the level."),
                ChatItem(profile: .trainer, chat: "Be warned though, restarting a level will cost you one of your precious lives...") { [weak self] in
                    self?.delegate?.deilluminateMinorButton(for: .reset)
                },
                ChatItem(profile: .hero, imgPos: .left, chat: "It's all good. I've got my mom's credit card if I need to buy more. 😃")
            ]) { [weak self] in
                GameCenterManager.shared.updateProgress(achievement: .avidReader, shouldReportImmediately: true)

                self?.delegate?.despawnTrainer(to: (0, 0))
                self?.handleDialogueCompletion(level: level, completion: completion)
            }
        case 101: //NEEDS CUTSCENE chance for a funny, short cutscene introducing the mystics then a record scratch when PUZL Boy is bored.
            chapterTitleSprite.setChapter(1)
            chapterTitleSprite.showTitle { [weak self] in
                self?.delegate?.spawnTrainer(at: (0, 0), to: .right)
                
                self?.sendChatArray(items: [
                    ChatItem(profile: .hero, imgPos: .left, chat: "Merlin! C'mon, we gotta go."),
                    ChatItem(profile: .trainer, chat: "The name's Marlin. MARLIN THE MAGNIFICENT! Not Merlin. Not dude. Not crusty old man!"),
                    ChatItem(profile: .hero, imgPos: .left, chat: "Oh! Marlin like the fish??? I hate fish by the way. The smell, the texture..."),
                    ChatItem(profile: .trainer, chat: "No. Not like the fish. Marlin like... the Magician. You see, in my world I am what is known as a Mystic."),
                    ChatItem(profile: .trainer, chat: "As a matter of fact, I come from a long line of legendary and powerful Mystics, each with our own unique powers and abilities..."),
                    ChatItem(profile: .hero, imgPos: .left, chat: "You're thinking of Merlin the Magician."),
                    ChatItem(profile: .trainer, chat: "Some Mystics control the elements: fire, water, air.. Some are all-knowing, while others govern the arts and science. I happen to be a water mage."),
                    ChatItem(profile: .trainer, chat: "Let's see, there's Maxel, Mawren, and Malana, our Mystics in training who I am personally mentoring..."),
                    ChatItem(profile: .hero, imgPos: .left, chat: "Mmmkay. Got it 🥱"),
                    ChatItem(profile: .trainer, chat: "Moving on. I received a visitor while I was in the DARK REALM. He didn't say who he was, but I think he might be connected to the disappearance."),
                    ChatItem(profile: .hero, imgPos: .left, chat: "Water mage... like a fish? A marlin is a fish."),
                    ChatItem(profile: .trainer, chat: "Enough with the fish! We need to be on the lookout for the mysterious figure. He likely holds the key to solving this mystery."),
                    ChatItem(profile: .hero, imgPos: .left, chat: "What's he look like?"),
                    ChatItem(profile: .trainer, chat: "Hmm. If you run into someone who looks mysterious, it's probably him.")
                ]) {
                    self?.delegate?.despawnTrainer(to: (0, 0))
                    self?.handleDialogueCompletion(level: level, completion: completion)
                }
            }
        case 112:
            delegate?.spawnTrainer(at: (0, 0), to: .right)
            
            sendChatArray(items: [
                ChatItem(profile: .hero, imgPos: .left, chat: "What's so special about this little girl anyway?"),
                ChatItem(profile: .trainer, chat: "She's no ordinary little girl. She is the princess of Vaeloria, a mystical realm known for its immense magic."),
                ChatItem(profile: .trainer, chat: "Dragons are ancient and powerful creatures that inhabit the land of Vaeloria and are deeply connected to its magic."),
                ChatItem(profile: .trainer, chat: "The sudden emergence of dragons in your world suggests something bigger is at play, and this little girl... Princess Olivia... is at the center of it all."),
                ChatItem(profile: .hero, imgPos: .left, chat: "What do they want with her?"),
                ChatItem(profile: .trainer, chat: "That has yet to be determined, though I suspect something very dark is behind all this... Come. Let's not waste anymore time.")
            ]) { [weak self] in
                self?.delegate?.despawnTrainer(to: (0, 0))
                self?.handleDialogueCompletion(level: level, completion: completion)
            }
        case PauseResetEngine.hintButtonUnlock: //Level: 140
            delegate?.spawnTrainer(at: (0, 0), to: .right)

            sendChatArray(items: [
                ChatItem(profile: .hero, imgPos: .left, chat: "You good old man— Merlin.. er, Marlin. Sir?? You been awfully quiet. You're usually going on and on and on about useless info right about now."),
                ChatItem(profile: .trainer, chat: "Don't make me snap."),
                ChatItem(profile: .hero, imgPos: .left, chat: "No don't! Look, if it's the old man comments, everybody gets old. It's just an inevitability of life. I'm 16 so everyone looks old to me. You're like what... 50?"),
                ChatItem(profile: .trainer, chat: "902."),
                ChatItem(profile: .hero, imgPos: .left, chat: "NINE HUNDRED??!! What are you, like a wizard or something? \"Marlin the Fish Wizard...\""),
                ChatItem(profile: .trainer, chat: "I told you I am NOT a wizard, I am a Mystic! MYSTIC!! Yeesh, my blood pressure..."),
                ChatItem(profile: .hero, imgPos: .left, chat: "Yikes, calm down. You don't look a day over 800 to be honest."),
                ChatItem(profile: .trainer, chat: "PUZL Boy, I need you to be serious! What lies ahead will test your patience. It will make you want to throw your phone out the window. You need to be prepared!"),
                ChatItem(profile: .hero, imgPos: .left, chat: "Ok ok. I'll be ready. I already know how to use hammers and swords. Nothing can stop me!") { [weak self] in
                    self?.delegate?.illuminateMinorButton(for: .hint)
                },
                ChatItem(profile: .trainer, chat: "Hilarious. I'm adding another tool to your arsenal. Tap the Hints button at the start of a level to illuminate your next move. Tap again to get the next hint."),
                ChatItem(profile: .trainer, chat: "Keep tapping for as many hints as you need. Hints become disabled once you move past your last hint. The number in red is your available hints."),
                ChatItem(profile: .trainer, chat: "If you run out of hints, you can buy more in the Shop tab of the Settings menu. Questions?") { [weak self] in
                    self?.delegate?.deilluminateMinorButton(for: .hint)
                },
                ChatItem(profile: .hero, imgPos: .left, chat: "Wow.. you're 900 years old. What's that in human years?")
            ]) { [weak self] in
                self?.delegate?.despawnTrainer(to: (0, 0))
                self?.handleDialogueCompletion(level: level, completion: completion)
            }
        case 151:
            delegate?.spawnTrainer(at: (0, 0), to: .right)

            sendChatArray(items: [
                ChatItem(profile: .trainer, chat: "I was once a teacher for Princess Olivia. We didn't get very far in her training, but I could see she had a natural ability to harness magic."),
                ChatItem(profile: .hero, imgPos: .left, chat: "For real? Why did you stop training her?"),
                ChatItem(profile: .trainer, chat: "I had to... return home for important \"Mystic duties.\""),
                ChatItem(profile: .hero, imgPos: .left, chat: "Ooh, cryptic!"),
                ChatItem(profile: .trainer, chat: "But before I left the princess, I placed a sigil on her hand: the Veil of Divine Protection. 🪬"),
                ChatItem(profile: .hero, imgPos: .left, chat: "Oh, good. So she should be safe then? Protection from what, evil or something?"),
                ChatItem(profile: .trainer, chat: "Something like that...") { [weak self] in
                    self?.delegate?.illuminatePanel(at: (1, 0), useOverlay: true)
                    self?.delegate?.illuminateDisplayNode(for: .health)
                },
                ChatItem(profile: .trainer, chat: "Hey! You can pick up a heart to add one to your health point. This should protect you when you run into those pesky dragons."),
                ChatItem(profile: .hero, imgPos: .left, chat: "Neat!")
            ]) { [weak self] in
                self?.delegate?.deilluminatePanel(at: (1, 0), useOverlay: true)
                self?.delegate?.deilluminateDisplayNode(for: .health)
                self?.delegate?.despawnTrainer(to: (0, 0))
                self?.handleDialogueCompletion(level: level, completion: completion)
            }
        case 180:
            AudioManager.shared.adjustVolume(to: 0.2, for: AudioManager.shared.currentTheme.overworld, fadeDuration: 3)
            AudioManager.shared.playSound(for: "littlegirllaugh", fadeIn: 3)
            
            sendChatArray(items: [
                ChatItem(profile: .blankprincess, chat: "\n\nIs anybody there???"),
                ChatItem(profile: .blankprincess, chat: "\n\nHello?????"),
                ChatItem(profile: .blankprincess, chat: "\n\nWon't anyone help me!!!"),
                ChatItem(profile: .hero, imgPos: .left, chat: "Princess, is that you??? Hang on! We're coming to get you!!!") {
                    AudioManager.shared.playSound(for: "chatopenvillain")
                    AudioManager.shared.playSound(for: "scarylaugh")
                },
                ChatItem(profile: .blankvillain, chat: "\n\n...heh heh heh heh heh... ") {
                    AudioManager.shared.adjustVolume(to: 1, for: AudioManager.shared.currentTheme.overworld, fadeDuration: 5)
                    AudioManager.shared.stopSound(for: "littlegirllaugh", fadeDuration: 5)
                },
                ChatItem(profile: .hero, imgPos: .left, chat: "Wh—what the... who's there?!! You heard that too, right??"),
                ChatItem(profile: .trainer, chat: "Oh sweet child! Do not worry, we're coming to get you!!")
            ]) { [weak self] in
                self?.handleDialogueCompletion(level: level, completion: completion)
            }
        case 201:
            chapterTitleSprite.setChapter(2)
            chapterTitleSprite.showTitle { [weak self] in
                self?.handleDialogueCompletion(level: level, completion: completion)
            }
        case 221:
            AudioManager.shared.adjustVolume(to: 0.2, for: AudioManager.shared.currentTheme.overworld, fadeDuration: 3)
            AudioManager.shared.playSound(for: "littlegirllaugh", fadeIn: 3)
            
            sendChatArray(items: [
                ChatItem(profile: .blankprincess, chat: "\nHello? Is anyone there? Can anyone hear me? Hellooo? HELLO!!!!!!"),
                ChatItem(profile: .hero, imgPos: .left, chat: "Princess?! We can hear you! Can you hear us??"),
                ChatItem(profile: .blankprincess, chat: "\nI don't know where I am! It's very smoky in here and it smells like burnt toast!"),
                ChatItem(profile: .blankprincess, chat: "\nOh! And this mysterious man has me! Uh oh, he's coming back..."),
                ChatItem(profile: .hero, imgPos: .left, chat: "Where are you!!! Can you hear me! OLIVIA!!! Burnt toast... is she having a stroke?? Marlin we gotta do something!"),
                ChatItem(profile: .trainer, chat: "She can't hear us. I can't sense her presence. Whatever has a hold of her is keeping her in between realms. We must keep moving if we are to find her.") {
                    AudioManager.shared.adjustVolume(to: 1, for: AudioManager.shared.currentTheme.overworld, fadeDuration: 5)
                    AudioManager.shared.stopSound(for: "littlegirllaugh", fadeDuration: 5)
                },
                ChatItem(profile: .hero, imgPos: .left, chat: "Who is this mysterious man you guys are talking about?"),
                ChatItem(profile: .trainer, chat: "I... I can't say for sure. But I have a sinking feeling...")
            ]) { [weak self] in
                self?.handleDialogueCompletion(level: level, completion: completion)
            }
        case 251:
            delegate?.spawnTrainer(at: (0, 0), to: .right)

            sendChatArray(items: [
                ChatItem(profile: .hero, imgPos: .left, chat: "What took you so long? I was talking to myself before I realized you were still in the DARK REALM..."),
                ChatItem(profile: .trainer, chat: "PUZL Boy, I—"),
                ChatItem(profile: .hero, imgPos: .left, chat: "As I was saying, \(ChatEngine.hero251Quote)"),
                ChatItem(profile: .trainer, chat: "Hmm, interesting. We need to get to the princess and send her back to Vaeloria right away. Time is of the essence."),
                ChatItem(profile: .hero, imgPos: .left, chat: "Ok, so let's find this \"man of mystery,\" beat him up, and get our princess back!"),
                ChatItem(profile: .trainer, chat: "Oh, sweet summer child. If it were only that simple. Keep your head down and follow closely. You have no idea what we're up against."),
                ChatItem(profile: .hero, imgPos: .left, chat: "\"Sweet summer child??\"") { [weak self] in
                    self?.delegate?.illuminatePanel(at: (0, 4), useOverlay: true)
                    self?.delegate?.illuminatePanel(at: (3, 2), useOverlay: true)
                },
                ChatItem(profile: .trainer, chat: "And one more thing... you'll notice there are green colored warps on the field. Stepping on a green warp will transport you to the other one.") { [weak self] in
                    self?.delegate?.deilluminatePanel(at: (0, 4), useOverlay: true)
                    self?.delegate?.deilluminatePanel(at: (3, 2), useOverlay: true)
                },
            ]) { [weak self] in
                self?.delegate?.despawnTrainer(to: (0, 0))
                self?.handleDialogueCompletion(level: level, completion: completion)
            }
        case 276:
            guard let delegate = delegate else {
                //This allows the game to move forward in case the delegate is not set, for some reason!
                handleDialogueCompletion(level: level, completion: completion)
                return
            }
            
            let spawnPoint: K.GameboardPosition = (0, 2)
            let decisionIndex = 0
            
            delegate.spawnTrainer(at: spawnPoint, to: .left)
            
            delegate.spawnPrincessCapture(at: spawnPoint, shouldAnimateWarp: true) { [weak self] in
                guard let self = self else { return }
                
                sendChatArray(items: [
                    ChatItem(profile: .princess, chat: "PRINCESS OLIVIA: Help meeeee PUZL Boy!!! It's dark and scary in there. And this guy's breath is really stinky!"),
                    ChatItem(profile: .hero, imgPos: .left, chat: "Gasp! It's the mysterious man!!!!!"),
                    ChatItem(profile: .trainer, imgPos: .left, chat: "Magmoor, stop this at once! It's not too late."),
                    ChatItem(profile: .villain, chat: "MAGMOOR: If you want to see your precious princess again, then let us merge powers."),
                    ChatItem(profile: .trainer, imgPos: .left, chat: "NO! You want absolute power. We Mystics share power equally; it keeps the realms in balance!"),
                    ChatItem(profile: .villain, chat: "I have been floating aimlessly in the NETHER REALM for centuries. Why?? Because the Council saw me as the biggest threat to their tyranny!"),
                    ChatItem(profile: .villain, chat: "But my time in exile helped me find my way. It gave me new meaning and purpose: I WAS MEANT TO RULE THEM ALL."),
                    ChatItem(profile: .trainer, imgPos: .left, chat: "You're calling for all out war! Your actions will surely plunge the realms into total darkness. Don't let this consume you Magmoor!!"),
                    ChatItem(profile: .villain, chat: "The system is broken. The realms are headed towards eternal darkness. It requires a new world order! It needs..... cleansing."),
                    ChatItem(profile: .princess, chat: "Your teeth need cleansing!"),
                    ChatItem(profile: .trainer, imgPos: .left, chat: "MAGMOOR LISTEN TO YOURSELF!!! You've completely lost it. Give up this delusion and let the princess go!!!"),
                    ChatItem(profile: .hero, imgPos: .left, chat: "If you touch a hair on her head, it's gonna be the end for you, Mantamar!"),
                    ChatItem(profile: .villain, chat: "Your quixotic dream of coexistence is the delusion. Open your eyes and see. Join me in the purification!"),
                    ChatItem(profile: .trainer, imgPos: .left, chat: "We will not join in your madness! We will fight to protect the realms!") {
                        AudioManager.shared.playSound(for: "scarylaugh")
                    },
                    ChatItem(profile: .villain, chat: "Heh heh heh. Pity. Then suffer the consequences!"),
                    ChatItem(profile: .princess, endChat: true, chat: "Noooooo! Don't let him take meeeeeee!!!!") {
                        self.fadeDimOverlay()
                        delegate.despawnPrincessCapture(at: spawnPoint, completion: {})
                    },
                    ChatItem(profile: .hero, imgPos: .left, pause: 8, startNewChat: true, chat: "That was creepy. Marlin, I did NOT sign up for this.......", handler: nil),
                    ChatItem(profile: .trainer, chat: "PUZL Boy this is now your reality. Take responsibility for your future. YOU have the power to change it!"),
                    ChatItem(profile: .hero, imgPos: .left, chat: "I know, I know. My mom always says, \"The power is yours!\" Ok... so what does Marzipan want with the princess?"),
                    ChatItem(profile: .trainer, chat: "Magmoor—one of the most powerful Mystics from my realm. I do not know what he intends to do with the princess, although we should assume the worst."),
                    ChatItem(profile: .hero, imgPos: .left, chat: "He's not gonna sacrifice her is he?!?! Because that's just not cool."),
                    ChatItem(profile: .trainer, chat: "I almost did not recognize him in that grotesque form. He used to be so handsome.") {
                        self.chatDecisionEngine.showDecisions(index: decisionIndex, toNode: self.chatBackgroundSprite, displayOnLeft: true)
                    },
                    ChatItem(profile: .trainer, endChat: false, chat: "How would you like to proceed?", handler: nil)
                ]) {
                    let choseLeft = FIRManager.decisionsLeftButton[decisionIndex] ?? false
                    
                    self.sendChatArray(items: [
                        ChatItem(profile: .hero, imgPos: .left, startNewChat: false, chat: "\(choseLeft ? "BRING ME MAGMOOR!!!" : "Hmm. We should prepare first.")", handler: nil),
                        ChatItem(profile: .trainer, chat: "\(choseLeft ? "Alright, but we need to be EXTRA cautious." : "A wise decision. Let's keep moving...")"),
                    ]) {
                        AudioManager.shared.adjustVolume(to: 1, for: AudioManager.shared.currentTheme.overworld, fadeDuration: 3)
                        
                        delegate.despawnTrainer(to: (0, 0))
                        self.handleDialogueCompletion(level: level, completion: completion)
                    }
                }
            } //end delegate.spawnPrincessCapture() no warp animation
        case 282:
            delegate?.spawnTrainer(at: (0, 0), to: .right)

            if !dialogueWithCutscene[level]! {
                let cutscene = CutsceneMagmoor()
                
                sendChatArray(items: [
                    ChatItem(profile: .hero, imgPos: .left, chat: "They couldn't have gone far. Let's find this dude and send him back to where he came from!"),
                    ChatItem(profile: .trainer, chat: "It's not going to be that simple, PUZL Boy. Magmoor grows powerful by the minute."),
                    ChatItem(profile: .hero, imgPos: .left, chat: "Why didn't you tell me you knew this creeper?"),
                    ChatItem(profile: .trainer, chat: "Some things are better left unsaid.. Apparently, even the Elders could not keep him contained."),
                    ChatItem(profile: .hero, imgPos: .left, chat: "The Elders??")
                ]) { [weak self] in
                    self?.handleDialogueCompletion(level: level, cutscene: cutscene, completion: completion)
                }
            }
            else {
                sendChatArray(items: [
                    ChatItem(profile: .hero, imgPos: .left, chat: "I'd like to kick him in his nether realm! So... how do we get the genie back in the bottle?"),
                    ChatItem(profile: .trainer, chat: "This—this is bad. This is all very, very bad!! But..... there is a way. I just need more time..."),
                    ChatItem(profile: .hero, imgPos: .left, chat: "We're outta time! Princess needs us now!"),
                    ChatItem(profile: .trainer, chat: "YES!! Just.. let me think for one second—")
                ]) { [weak self] in
                    self?.delegate?.despawnTrainer(to: (0, 0))
                    self?.handleDialogueCompletion(level: level, completion: completion)
                }
            }
        case 298:
            let spawnPoint: K.GameboardPosition = (0, 2)
            
            guard let delegate = delegate else {
                //This allows the game to move forward in case the delegate is not set, for some reason!
                handleDialogueCompletion(level: level, completion: completion)
                return
            }
            
            delegate.spawnTrainer(at: spawnPoint, to: .left)
            
            delegate.spawnPrincessCapture(at: spawnPoint, shouldAnimateWarp: true) { [weak self] in
                guard let self = self else { return }
                
                sendChatArray(items: [
                    ChatItem(profile: .villain, chat: "Come to your senses yet?"),
                    ChatItem(profile: .hero, imgPos: .left, chat: "HEY! Leave her alone, Mylar!"),
                    ChatItem(profile: .trainer, imgPos: .left, chat: "Magmoor, let her go! You will have to answer to the kingdom of Vaeloria for your actions!"),
                    ChatItem(profile: .villain, chat: "Actions?? For what? I'm merely keeping her until the time comes..."),
                    ChatItem(profile: .hero, imgPos: .left, chat: "Until the time comes for what?? You won't harm her will you?!!"),
                    ChatItem(profile: .villain, chat: "Sacrifice her? Oh heavens, no! I'm not that cruel..."),
                    ChatItem(profile: .hero, imgPos: .left, chat: "I didn't say sacrifice—"),
                    ChatItem(profile: .trainer, imgPos: .left, chat: "Princess Olivia, are you ok?"),
                    ChatItem(profile: .princess, chat: "No. I'm scared..."),
                    ChatItem(profile: .trainer, imgPos: .left, chat: "Remember what I taught you."),
                    ChatItem(profile: .princess, endChat: true, chat: "Ok I'll try...") {
                        self.fadeDimOverlay()
                        
                        delegate.flashPrincess(at: spawnPoint, completion: {})
                    },
                    ChatItem(profile: .princess, pause: 6, startNewChat: true, chat: "I'm not strong enough... I can't do it, uncle Marlin!", handler: nil),
                    ChatItem(profile: .trainer, imgPos: .left, chat: "Yes you can, princess! You've got to keep trying. Do not give up!"),
                    ChatItem(profile: .villain, chat: "How endearing. I hate to cut the reunion short, but if you won't merge with me, we'll be on our way."),
                    ChatItem(profile: .trainer, imgPos: .left, chat: "Do not be afraid! You are braver than you think."),
                    ChatItem(profile: .princess, chat: "It's ok. I'm getting used to it."),
                    ChatItem(profile: .princess, chat: "Anyway this part's fun..... Weeeeeee!")
                ]) {
                    self.fadeDimOverlay()

                    delegate.despawnPrincessCapture(at: spawnPoint) {
                        AudioManager.shared.adjustVolume(to: 1, for: AudioManager.shared.currentTheme.overworld, fadeDuration: 3)
                        delegate.despawnTrainer(to: (0, 0))
                        self.handleDialogueCompletion(level: level, completion: completion)
                    }
                }
            }
        case 301:
            let musicFadeDuration: TimeInterval = 3
            
            delegate?.spawnTrainerWithExit(at: (0, 0), to: .right)
            
            sendChatArray(items: [
                ChatItem(profile: .hero, imgPos: .left, chat: "Hey Marl, I've got a plan."),
                ChatItem(profile: .trainer, chat: "PUZL Boy, there's something I need to tell you—"),
                ChatItem(profile: .hero, imgPos: .left, chat: "I'll distract him with this sword. Then when he's not looking, you blast him with magic."),
                ChatItem(profile: .trainer, chat: "I'm leaving."),
                ChatItem(profile: .hero, imgPos: .left, chat: "THEN while he's stunned, I'll use said sword to deliver the final blow and—"),
                ChatItem(profile: .hero, imgPos: .left, chat: ".....wait, what do you mean you're leaving?! Where are we going??"),
                ChatItem(profile: .trainer, chat: "He agreed to set the princess free. In return, I am going to merge with him."),
                ChatItem(profile: .hero, imgPos: .left, chat: "Ok but can we please stop calling it that?"),
                ChatItem(profile: .trainer, chat: "Merging of powers is completely natural for our kind. We do it everywhere. All the time. At home, in public. We do it without shame or regret. So, no."),
                ChatItem(profile: .hero, imgPos: .left, chat: "Why should we trust him?!! He's obviously the bad guy!!!"),
                ChatItem(profile: .trainer, chat: "With the princess free, we stand a better chance at defeating Magmoor once and for all."),
                ChatItem(profile: .trainer, chat: "Just keep solving puzzles like you're doing and you will be just fine.") {
                    AudioManager.shared.lowerVolume(for: AudioManager.shared.currentTheme.overworld, fadeDuration: musicFadeDuration)
                },
                ChatItem(profile: .hero, imgPos: .left, chat: "But, but... I can't do this without you!! 🥺"),
                ChatItem(profile: .trainer, chat: "Trust your instincts, PUZL Boy. I have equipped you with all the knowledge you need to succeed."),
                ChatItem(profile: .trainer, chat: "Goodbye. For now...") { [weak self] in
                    self?.hideFFButton()
                    self?.delegate?.despawnTrainerWithExit(moves: [(0, 1), (1, 1), (1, 2), (2, 2), (2, 3),
                                                                   (3, 3), (3, 4), (4, 4), (4, 5), (5, 5)])
                    AudioManager.shared.playSound(for: "sadaccent")
                },
                ChatItem(profile: .hero, imgPos: .left, chat: "Marlin!!!!")
            ]) { [weak self] in
                self?.chapterTitleSprite.setChapter(3)
                self?.chapterTitleSprite.showTitle(shouldLowerVolumeForCurrentTheme: false) {
                    self?.sendChatArray(items: [
                        ChatItem(profile: .blanktrainer, startNewChat: false, chat: "\n\nMarlin has left the party.", handler: nil)
                    ]) {
                        self?.showFFButton()
                        AudioManager.shared.raiseVolume(for: AudioManager.shared.currentTheme.overworld, fadeDuration: musicFadeDuration)

                        self?.handleDialogueCompletion(level: level, completion: completion)
                    }
                }
            }
        case 319:
            if statueTapped {
                sendChatArray(shouldSkipDim: true, items: dialogueStatue0.getDialogue()) { [weak self] in
                    self?.handleDialogueCompletion(level: level, completion: completion)
                }
            }
            else {
                sendChatArray(items: [
                    ChatItem(profile: .hero, imgPos: .left, chat: "They having a party down here??")
                ]) { [weak self] in
                    self?.handleDialogueCompletion(level: level, completion: completion)
                }
            }
        case 339:
            if statueTapped {
                sendChatArray(shouldSkipDim: true, items: dialogueStatue1.getDialogue()) { [weak self] in
                    self?.handleDialogueCompletion(level: level, completion: completion)
                }
            }
            else {
                handleDialogueCompletion(level: level, completion: completion)
            }
        case 351:
            if statueTapped {
                sendChatArray(shouldSkipDim: true, items: dialogueStatue2.getDialogue()) { [weak self] in
                    self?.handleDialogueCompletion(level: level, completion: completion)
                }
            }
            else {
                sendChatArray(items: [
                    ChatItem(profile: .hero, imgPos: .left, chat: "Is this.. \(FireIceTheme.isFire ? "sand" : "snow")?? What happens when I step in it? Maybe that Tiki knows...")
                ]) { [weak self] in
                    self?.handleDialogueCompletion(level: level, completion: completion)
                }
            }
        case 376:
            if statueTapped {
                sendChatArray(shouldSkipDim: true, items: dialogueStatue3.getDialogue()) { [weak self] in
                    self?.handleDialogueCompletion(level: level, completion: completion)
                }
            }
            else {
                handleDialogueCompletion(level: level, completion: completion)
            }
        case 401:
            if statueTapped {
                sendChatArray(shouldSkipDim: true, items: dialogueStatue4.getDialogue()) { [weak self] in
                    self?.handleDialogueCompletion(level: level, completion: completion)
                }
            }
            else {
                chapterTitleSprite.setChapter(4)
                chapterTitleSprite.showTitle { [weak self] in
                    self?.sendChatArray(items: [
                        ChatItem(profile: .hero, imgPos: .left, chat: "(Marlin, where are you?)")
                    ]) {
                        self?.handleDialogueCompletion(level: level, completion: completion)
                    }
                }
            }
        case 412:
            delegate?.inbetweenRealmEnter(levelInt: level, mergeHalfway: false, moves: [(1, 2), (1, 1), (1, 0), (2, 0),
                                                                                        (2, 1), (3, 1), (2, 1), (2, 0),
                                                                                        (1, 0), (1, 1), (1, 2), (1, 3),
                                                                                        (1, 2), (1, 1), (2, 1), (2, 0),
                                                                                        (1, 0), (1, 1), (2, 1), (2, 0),
                                                                                        (1, 0), (1, 1), (2, 1), (2, 0),
                                                                                        (1, 0), (1, 1), (2, 1), (2, 0),
                                                                                        (1, 0), (1, 1), (2, 1), (2, 0)])
            
            sendChatArray(shouldSkipDim: true, items: [
                ChatItem(profile: .princess, imgPos: .left, chat: "Are you going to let me go now or what?"),
                ChatItem(profile: .villain, chat: "Once the merge is complete........ then I will let you go."),
                ChatItem(profile: .princess, imgPos: .left, chat: "When is that going to be?"),
                ChatItem(profile: .villain, chat: "Who can say? A few hours... days... weeks..."),
                ChatItem(profile: .princess, imgPos: .left, chat: "Well, which one is it!"),
                ChatItem(profile: .villain, chat: "Tsk tsk! Patience, child. Relentless little one, aren't you?! Just like your mother."),
                ChatItem(profile: .princess, imgPos: .left, chat: "Watch what you say!! My mother is the Queen of Vaeloria. She'll have you stripped of your powers!"),
                ChatItem(profile: .villain, chat: "You are cute as a button."),
                ChatItem(profile: .trainer, imgPos: .left, chat: "Magmoor, you promised to let her go!"),
                ChatItem(profile: .villain, chat: "Isn't this nice?? Magmoor and Marlin, reunited once again. Don't you worry, dear Marlin. I always keep my promise...") { [weak self] in
                    self?.delegate?.inbetweenFlashPlayer(playerType: .hero, position: (0, 0), persistPresence: false)
                    self?.hideFFButton()
                },
                ChatItem(profile: .blankhero, chat: "\n\nGuys!! I— right here—") { [weak self] in
                    self?.showFFButton()
                },
                ChatItem(profile: .princess, imgPos: .left, chat: "Who said that?! It sounded like—"),
                ChatItem(profile: .villain, chat: "Nobody, child. Must be the wind.")
            ]) { [weak self] in
                guard let delegate = self?.delegate else {
                    //Just in case delegate is false, which it shouldn't be!!!
                    self?.handleDialogueCompletion(level: level, completion: completion)
                    return
                }
                
                delegate.inbetweenRealmExit(persistPresence: false) { [weak self] in
                    self?.sendChatArray(shouldSkipDim: true, items: [
                        ChatItem(profile: .hero, imgPos: .left, chat: "Guys!! I'm right here!!!"),
                        ChatItem(profile: .hero, imgPos: .left, chat: "Marlin!! Princess!! Can you guys hear me?!?! HEEEY!!!! Helloooo!!!"),
                        ChatItem(profile: .hero, imgPos: .left, chat: "Where are you guys???")
                    ]) {
                        self?.handleDialogueCompletion(level: level, completion: completion)
                    }
                }
            }
        case 417:
            AudioManager.shared.adjustVolume(to: 0.2, for: AudioManager.shared.currentTheme.overworld, fadeDuration: 0.5)
            
            delegate?.peekMinion(at: (3, 3), duration: 4) { [weak self] in
                AudioManager.shared.raiseVolume(for: AudioManager.shared.currentTheme.overworld, fadeDuration: 0.5)

                self?.sendChatArray(items: [
                    ChatItem(profile: .hero, imgPos: .left, chat: "What the.........?")
                ]) {
                    self?.handleDialogueCompletion(level: level, completion: completion)
                }
            }
        case 434:
            AudioManager.shared.adjustVolume(to: 0.2, for: AudioManager.shared.currentTheme.overworld, fadeDuration: 0.5)
            
            delegate?.peekMinion(at: (3, 3), duration: 4) { [weak self] in
                AudioManager.shared.raiseVolume(for: AudioManager.shared.currentTheme.overworld, fadeDuration: 0.5)

                self?.sendChatArray(items: [
                    ChatItem(profile: .hero, imgPos: .left, chat: "Uh.. no, thank you!")
                ]) {
                    self?.handleDialogueCompletion(level: level, completion: completion)
                }
            }
        case 441:
            delegate?.inbetweenRealmEnter(levelInt: level, mergeHalfway: true, moves: [(2, 1), (2, 2), (2, 3), (1, 3),
                                                                                       (2, 3), (1, 3), (2, 3), (3, 3),
                                                                                       (3, 2), (3, 1), (4, 1), (4, 2),
                                                                                       (4, 3), (4, 4), (4, 5), (4, 4),
                                                                                       (4, 3), (4, 2), (4, 1), (3, 1),
                                                                                       (2, 1), (1, 1), (1, 2), (1, 3),
                                                                                       (1, 4), (2, 4), (2, 3), (2, 2),
                                                                                       (2, 1), (3, 1), (3, 2), (3, 3),
                                                                                       (3, 4), (4, 4), (4, 3), (5, 3)])
            
            sendChatArray(shouldSkipDim: true, items: [
                ChatItem(profile: .trainer, imgPos: .left, chat: "Wait! *WHEEZE* I need.. pause for a second....."),
                ChatItem(profile: .princess, imgPos: .left, chat: "Uncle Marlin, you don't look so good."),
                ChatItem(profile: .trainer, imgPos: .left, chat: "I'm.. fine, princess.. Everything is going.. be ok....."),
                ChatItem(profile: .princess, imgPos: .left, chat: "You're hurting him! Let him go!!"),
                ChatItem(profile: .villain, chat: "Just a little bit longer. We're halfway done."),
                ChatItem(profile: .princess, imgPos: .left, chat: "I want to go home now!"),
                ChatItem(profile: .villain, chat: "No. We're not done yet. You'll have to wait.") { [weak self] in
                    self?.hideFFButton(showChatImmediately: true)
                    self?.delegate?.empowerPrincess(powerDisplayDuration: 5)
                },
                ChatItem(profile: .princess, imgPos: .left, chat: "NO. I SAID NOW!!!!") { [weak self] in
                    self?.showFFButton()
                },
                ChatItem(profile: .villain, chat: "How did you do that?!!"),
                ChatItem(profile: .princess, imgPos: .left, chat: "I don't know but this mark on my hand tickles every time it happens. 🪬"),
                ChatItem(profile: .villain, chat: "The Veil of Divine Protection.. Clever, Marlin!"),
                ChatItem(profile: .trainer, imgPos: .left, chat: "Oh, Maggy... I've always been... steps ahead...") { [weak self] in
                    self?.delegate?.inbetweenFlashPlayer(playerType: .hero, position: (0, 0), persistPresence: true)
                    self?.hideFFButton()
                },
                ChatItem(profile: .blankhero, chat: "\n\nMAGPIE, SHOW YOURSELF!!") { [weak self] in
                    self?.showFFButton()
                },
                ChatItem(profile: .princess, imgPos: .left, chat: "PUZL Boy?? Is that you?!? Help us, please!!! We're trapped in the IN-BETWEEN REALM!") { [weak self] in
                    self?.delegate?.encagePrincess()
                },
                ChatItem(profile: .villain, chat: "Careful, child! I'd behave if I were you..."),
                ChatItem(profile: .princess, imgPos: .left, chat: "Owwwww!"),
                ChatItem(profile: .trainer, imgPos: .left, chat: "Magmoor... *WHEEZE* *HACK* *PHLEGM* Don't..."),
                ChatItem(profile: .villain, chat: "It's time we pay your hero a surprise visit.")
            ]) { [weak self] in
                guard let delegate = self?.delegate else {
                    //Just in case delegate is false, which it shouldn't be!!!
                    self?.handleDialogueCompletion(level: level, completion: completion)
                    return
                }
                
                AudioManager.shared.playSound(for: "scarylaugh")
                
                delegate.inbetweenRealmExit(persistPresence: true) {
                    self?.sendChatArray(shouldSkipDim: true, items: [
                        ChatItem(profile: .hero, imgPos: .left, chat: "Princess! You can hear me! I'm coming, you guys!!"),
                        ChatItem(profile: .hero, imgPos: .left, chat: "Tiki was right. Sounds like they're right under my feet. Gotta keep moving!")
                    ]) {
                        self?.handleDialogueCompletion(level: level, completion: completion)
                    }
                }
            }
        case 451:
            guard FIRManager.bravery == nil else {
                //Short circuit Minion fight if you've already fought him and bravery was recorded!
                handleDialogueCompletion(level: level, completion: completion)
                return
            }
            
            let spawnPointMinion: K.GameboardPosition = (3, 3)
            let chatDelay: TimeInterval = 13
            let attackDuration: TimeInterval = 60
            let gameScene = superScene as? GameScene

            delegate?.spawnDaemon(at: spawnPointMinion)
            
            sendChatArray(shouldSkipDim: true, items: [
                ChatItem(profile: .hero, imgPos: .left, chat: "Oh.. you again. Alright, whaddya got for me?") { [weak self] in
                    AudioManager.shared.lowerVolume(for: AudioManager.mainThemes.overworld, fadeDuration: 5)
                    self?.hideFFButton()
                    self?.delegate?.spawnMagmoorMinion(at: spawnPointMinion, chatDelay: chatDelay)
                },
                ChatItem(profile: .statue5, endChat: true, chat: "WELCOME TO YOUR DOOM!") { [weak self] in
                    gameScene?.shakeScreen(duration: 9, shouldPlaySFX: false, completion: nil)

                    self?.showFFButton()
                },
                ChatItem(profile: .hero, imgPos: .left, pause: chatDelay, startNewChat: true, chat: "Nope! Nope! Nope! NOOOPE!!!", handler: nil),
                ChatItem(profile: .hero, imgPos: .left, endChat: true, chat: "What even are you?!?! Get away from me! I don't know anything!! MARLIN, HEEEEELP!!!!", handler: nil)
            ]) { [weak self] in
                self?.hideFFButton(showChatImmediately: true)

                //Yet again another nesting!!
                self?.delegate?.minionAttack(duration: attackDuration) {
                    //This nesting is REALLY ugly!!
                    gameScene?.shakeScreen(duration: 8, shouldPlaySFX: false, completion: nil)
                    self?.delegate?.spawnElder(minionPosition: spawnPointMinion, positions: [(0, 3), (4, 0), (4, 6)]) {
                        self?.delegate?.despawnMagmoorMinion(at: spawnPointMinion, fadeDuration: 3)
                        
                        self?.sendChatArray(shouldSkipDim: true, items: [
                            ChatItem(profile: .allelders, startNewChat: true, chat: "⚡️BEGONE, CREATURE!!!⚡️") {
                                self?.showFFButton()
                            }
                        ]) {
                            //Ugh!! Yet another UGLY nesting...
                            self?.sendChatArray(items: [
                                ChatItem(profile: .hero, imgPos: .left, startNewChat: true, chat: "Melchior and the Elders!! Holey moley, you guys are stuff of legends! 🤯", handler: nil),
                                ChatItem(profile: .melchior, chat: "MELCHIOR: Fear not, boy. The Elders have arrived."),
                                ChatItem(profile: .hero, imgPos: .left, chat: "What was that thing?!!"),
                                ChatItem(profile: .magmus, chat: "MAGMUS: Magmoor's minion feeds on your deepest fears and desires. Give in and it will weaken your spirit.. corrupt your soul.. shatter your psyche!"),
                                ChatItem(profile: .hero, imgPos: .left, chat: "Ok, I get it!!"),
                                ChatItem(profile: .merton, chat: "MERTON: 'Tis a thought fraught with fright, earth friend! Marlin, we fear has fallen victim to this twisted manifestation."),
                                ChatItem(profile: .hero, imgPos: .left, chat: "Looks like my sleep paralysis demon. Is it gonna come back for me??!"),
                                ChatItem(profile: .melchior, chat: "Most likely, yes. But lucky for you, you have our protection. We shall join you in the fight to destroy Magmoor the Fallen once and for all!"),
                                ChatItem(profile: .magmus, chat: "Fear never truly goes away, inexperienced one. Over time, you learn to cope with it."),
                                ChatItem(profile: .merton, chat: "And not a moment too soon. Quickly, let us make haste to the planet's core!!") {
                                    self?.delegate?.despawnElders(to: (0, 0), completion: {})
                                    self?.hideFFButton()
                                    AudioManager.shared.playSound(for: "titlechapter")
                                },
                                ChatItem(profile: .blankelders, chat: "\n\nThe Elders have joined the party.") {
                                    AudioManager.shared.raiseVolume(for: AudioManager.mainThemes.overworld, fadeDuration: 3)
                                    self?.showFFButton()
                                },
                                ChatItem(profile: .hero, imgPos: .left, chat: "Ah, yeah!!")
                            ]) {
                                self?.marlinBlast.removeFromParent()
                                
                                self?.handleDialogueCompletion(level: level, completion: completion)
                            }
                        } //end 3rd nesting
                    } //end delegate?.spawnElder()
                } //end delegate?.minionAttack()
            } //end outer sendChatArray()
        case 475:
            if statueTapped {
                sendChatArray(shouldSkipDim: true, items: dialogueStatue3b.getDialogue()) { [weak self] in
                    self?.handleDialogueCompletion(level: level, completion: completion)
                }
            }
            else {
                let leftButton0 = FIRManager.decisionsLeftButton[0] ?? false
                
                //Only show this dialogue the first time, i.e. PUZL Boy has or hasn't received the gift.
                if FIRManager.gotGift == nil {
                    sendChatArray(items: [
                        ChatItem(profile: .hero, imgPos: .left, chat: "Oh no. No no no no no! I'm not talking to you guys ever again!"),
                        ChatItem(profile: FIRManager.didGiveAwayFeather ? .statue3b : .statue3, chat: "Oh, come on. Don't do me like that! It's me, Trudee, the truth-telling Tiki. Come over and say hi!"),
                        ChatItem(profile: .magmus, chat: "It's okay. Go and say hi, boy. What's the worst that can happen?"),
                        ChatItem(profile: .hero, imgPos: .left, chat: "Uhh, evil scary monster?!?!"),
                        ChatItem(profile: .magmus, chat: "C'mon, it'll be good for you. Builds character, indeed."),
                        ChatItem(profile: .melchior, chat: "He's harmless.."),
                        ChatItem(profile: .merton, chat: "Right! You've already defeated him once. Don't let his grotesque visage intimidate you."),
                        ChatItem(profile: .melchior, chat: "I meant the boy!"),
                        ChatItem(profile: .merton, chat: "Oh....."),
                        ChatItem(profile: .melchior, chat: "Look, you defeated the creature once already.. with our help, of course. Despite his trickery and deception, Magmoor does not stand a chance against us!"),
                        ChatItem(profile: .hero, imgPos: .left, chat: "\(leftButton0 ? "You're right! Thanks for the pep talk." : "Welp... what have I got to lose?")")
                    ]) { [weak self] in
                        self?.handleDialogueCompletion(level: level, completion: completion)
                    }
                }
                else {
                    handleDialogueCompletion(level: level, completion: completion)
                }
            }
        default:
            isChatting = false
            completion?(nil)
        }
    }//end playDialogueAgeOfBalance()

    ///Sets up and plays dialogue for Age of Ruin setting.
    private func playDialogueAgeOfRuin(level: Int, completion: ((Cutscene?) -> Void)?) {
        switch level {
            
        case Level.partyLevel: //IMPORTANT: This case, Level.partyLevel must ALWAYS be here!!!
            handleDialogueCompletion(level: level, completion: completion)
        case 201:
            sendChatArray(items: [
                ChatItem(profile: .trainer, imgPos: .left, chat: "I do not know what you intend to do with such a little girl. Leave her be!"),
                ChatItem(profile: .villain, chat: "Just a little bit farther. We're almost there."),
                ChatItem(profile: .princess, chat: "You better hurry. I'm missing my show!"),
                ChatItem(profile: .trainer, imgPos: .left, chat: "Princess be a bit more patient."),
            ]) { [weak self] in
                self?.handleDialogueCompletion(level: level, completion: completion)
            }
        default:
            isChatting = false
            completion?(nil)
        }
    }//end playDialogueAgeOfRuin()
    
    
}//end ChatEngine
