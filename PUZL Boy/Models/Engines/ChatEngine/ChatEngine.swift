//
//  ChatEngine.swift
//  PUZL Boy
//
//  Created by Eddie Char on 12/23/22.
//

import SpriteKit

protocol ChatEngineDelegate: AnyObject {
    func illuminatePanel(at position: K.GameboardPosition, useOverlay: Bool)
    func deilluminatePanel(at position: K.GameboardPosition, useOverlay: Bool)
    func illuminateDisplayNode(for displayType: DisplaySprite.DisplayStatusName)
    func deilluminateDisplayNode(for displayType: DisplaySprite.DisplayStatusName)
    func illuminateMinorButton(for button: PauseResetEngine.MinorButton)
    func deilluminateMinorButton(for button: PauseResetEngine.MinorButton)
    func spawnPrincessCapture(at position: K.GameboardPosition, shouldAnimateWarp: Bool, completion: @escaping () -> Void)
    func despawnPrincessCapture(at position: K.GameboardPosition, completion: @escaping () -> Void)
    func flashPrincess(at position: K.GameboardPosition, completion: @escaping () -> Void)
    func inbetweenRealmEnter(levelInt: Int)
    func inbetweenRealmExit(completion: @escaping () -> Void)
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
    private var chatSpeed: TimeInterval
    private var chatText: String = ""
    private var chatIndex: Int = 0

    private(set) var isChatting: Bool = false
    private var isAnimating: Bool = false
    private var allowNewChat: Bool = true
    private var shouldClose: Bool = true
    private var closeChatIsRunning: Bool = false
    

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
            decision0: ("Prepare First", "Pursue Him"),
            decision1: ("Vans", "Nike"),
            decision2: ("Magmoor", "Marlin"),
            decision3: ("Left", "Right"))
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

    private func fastForward() {
        if chatSpeed > 0 && chatIndex < chatText.count {
            chatSpeed = 0
        }
        else {
            dispatchWorkItem.cancel()
            closeChat()
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
                     chat: items[currentIndex].chat) { [unowned self] in
                items[currentIndex].handler?()

                //Recursion!! Also the [unowned self] prevents a retain cycle here...
                sendChatArray(items: items, currentIndex: currentIndex + 1, completion: completion)
            }
        }
    }
    
    private func sendChat(profile: ChatItem.ChatProfile, imgPos: ChatItem.ImagePosition, pause: TimeInterval?, startNewChat: Bool, endChat: Bool, shouldSkipDim: Bool, chat: String, completion: (() -> ())? = nil) {
        //Only allow a new chat if current chat isn't happening
        guard allowNewChat else { return }
        
        let statueFillColor = UIColor.systemGreen.darkenColor(factor: 4)
        
        textSprite.text = ""
        textSprite.updateShadow()
        timer.invalidate()
        chatText = chat
        chatIndex = 0
        allowNewChat = false //prevents interruption of current chat, which could lead to crashing due to index out of bounds
        shouldClose = endChat
        currentProfile = profile
        self.completion = completion
        
        switch profile {
        case .hero:
            avatarSprite.texture = SKTexture(imageNamed: "puzlboy")
            chatBackgroundSprite.fillColor = .orange
        case .trainer:
            avatarSprite.texture = SKTexture(imageNamed: "trainer")
            chatBackgroundSprite.fillColor = .blue
        case .princess:
            avatarSprite.texture = SKTexture(imageNamed: "princess")
            chatBackgroundSprite.fillColor = .magenta
        case .princessCursed:
            avatarSprite.texture = SKTexture(imageNamed: "princessCursed")
            chatBackgroundSprite.fillColor = .magenta
        case .princess2:
            avatarSprite.texture = SKTexture(imageNamed: "princess2")
            chatBackgroundSprite.fillColor = .magenta
        case .villain:
            avatarSprite.texture = SKTexture(imageNamed: "villain")
            chatBackgroundSprite.fillColor = .red
        case .blankvillain:
            avatarSprite.texture = nil
            chatBackgroundSprite.fillColor = .red
        case .blankprincess:
            avatarSprite.texture = nil
            chatBackgroundSprite.fillColor = .magenta
        case .blanktrainer:
            avatarSprite.texture = nil
            chatBackgroundSprite.fillColor = .blue
        case .statue0:
            avatarSprite.texture = SKTexture(imageNamed: "chatStatue0")
            chatBackgroundSprite.fillColor = statueFillColor
        case .statue1:
            avatarSprite.texture = SKTexture(imageNamed: "chatStatue1")
            chatBackgroundSprite.fillColor = statueFillColor
        case .statue2:
            avatarSprite.texture = SKTexture(imageNamed: "chatStatue2")
            chatBackgroundSprite.fillColor = statueFillColor
        case .statue3:
            avatarSprite.texture = SKTexture(imageNamed: "chatStatue3")
            chatBackgroundSprite.fillColor = statueFillColor
        }
        
        if profile == .blankvillain || profile == .blankprincess || profile == .blanktrainer {
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
            ])) { [unowned self] in
                if startNewChat {
                    playChatOpenNotification()
                }
                
                timer = Timer.scheduledTimer(timeInterval: chatSpeed, target: self, selector: #selector(animateText(_:)), userInfo: nil, repeats: true)
            }
        }
        else {
            //Leave out the wait
            chatBackgroundSprite.run(animateBackgroundSprite) { [unowned self] in
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
        if chatSpeed > 0 && chatIndex < chatText.count {
            let chatChar = chatText[chatText.index(chatText.startIndex, offsetBy: chatIndex)]
            
            textSprite.text! += "\(chatChar)"
            textSprite.updateShadow()
            
            chatIndex += 1
        }
        else if chatSpeed <= 0 && chatIndex < chatText.count {
            textSprite.text = chatText
            textSprite.updateShadow()
            
            chatIndex = chatText.count
        }
        else if chatIndex >= chatText.count {
            timer.invalidate()
            
            //Set it here so you can cancel it if needed.
            dispatchWorkItem = DispatchWorkItem(block: { [unowned self] in
                closeChat()
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (chatSpeed > 0 ? 5.0 : max(5.0, Double(chatText.count) / 10)), execute: dispatchWorkItem)
        }
    }
    
    private func playChatOpenNotification() {
        switch currentProfile {
        case .hero:                                 
            AudioManager.shared.playSound(for: "chatopen")
        case .trainer, .blanktrainer:
            AudioManager.shared.playSound(for: "chatopentrainer")
        case .princess, .princessCursed, .princess2, .blankprincess:
            AudioManager.shared.playSound(for: "chatopenprincess")
        case .villain, .blankvillain:               
            AudioManager.shared.playSound(for: "chatopenvillain")
        case .statue0, .statue1, .statue2, .statue3:
            AudioManager.shared.playSound(for: "chatopenstatue")
        }
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
        ])) { [unowned self] in
            allowNewChat = true
            closeChatIsRunning = false
            chatSpeed = chatSpeedOrig
            
            self.completion?()
        }
    }
}


// MARK: - ChatDecisionEngine Delegate

extension ChatEngine: ChatDecisionEngineDelegate {
    func decisionWasMade(index: Int, order: ChatDecisionEngine.ButtonOrder) {
        FIRManager.updateFirestoreRecordDecision(index: index, buttonOrder: order)
        
        //Don't forget to update the StatueDialogue object!! (Otherwise it will ask the question again in the same line of questioning).
        switch index {
        case 0:     dialogueStatue0.setShouldSkipFirstQuestion(true)
        case 1:     dialogueStatue1.setShouldSkipFirstQuestion(true)
        case 2:     dialogueStatue2.setShouldSkipFirstQuestion(true)
        case 3:     dialogueStatue3.setShouldSkipFirstQuestion(true)
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

        //DARK REALM Dialogue
        dialoguePlayed[Level.partyLevel] = false //Level: -1
        dialoguePlayed[-100] = false
        dialoguePlayed[-150] = false
        dialoguePlayed[-200] = false
        dialoguePlayed[-250] = false
        dialoguePlayed[-300] = false

        
        //PUZZLE REALM Dialogue
        
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
        dialoguePlayed[152] = false
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

        
        
        
        
        // FIXME: - Test only
        dialoguePlayed[210] = false
        dialoguePlayed[211] = false
        dialoguePlayed[212] = false
        dialoguePlayed[213] = false
        
        
        
        
        
        // STATUES DIALOGUE
        
        dialogueStatue0 = StatueDialogue(dialogue: [ //Lv. 319
            ChatItem(profile: .hero, imgPos: .left, chat: "What the heck is this??"),
            ChatItem(profile: .statue0, chat: "We are ancient relics known as Tikis. Think of us as friendly guides to help you along the way."),
            ChatItem(profile: .hero, imgPos: .left, chat: "It talks!"),
            ChatItem(profile: .statue0, chat: "Some of us may ask you an important question that can alter the course of your journey, so be sure to answer truthfully and honestly."),
            ChatItem(profile: .hero, imgPos: .left, chat: "There's more of you??"),
            ChatItem(profile: .statue0, chat: "Yes! We're scattered throughout the PUZZLE REALM. Ask us anything!"),
            
            ChatItem(profile: .hero, imgPos: .left, chat: "Where is Marlin and when is he coming back?"),
            ChatItem(profile: .statue0, chat: "The answer to that question is............ a difficult one to predict!"),
            
            ChatItem(profile: .hero, imgPos: .left, chat: "Is Princess Olivia safe? Where is Magmoor keeping her?"),
            ChatItem(profile: .statue0, chat: "Let me look into that for you............ I don't know!"),
            ChatItem(profile: .hero, imgPos: .left, chat: "You're not very helpful."),

            //Single responses
            ChatItem(profile: .statue0, chat: "Here's something helpful: don't forget to Rate and Review this game on the AppStore!"),
            ChatItem(profile: .statue0, chat: "Stuck? Take a break. Come back when your mind is refreshed 💆🏻‍♂️"),
            ChatItem(profile: .statue0, chat: "Princess Olivia.. I heard she possesses very powerful magic. Though it's just a rumor."),
            ChatItem(profile: .statue0, chat: "You won't find her standing around here. Get moving!"),
            ChatItem(profile: .statue0, chat: "Tick tock. Time's a wasting!"),
        ], indices: [6, 2, 3, 1, 1, 1, 1, 1], shouldSkipFirstQuestion: false)
        
        dialogueStatue1 = StatueDialogue(dialogue: [
            //Story branching decision question
            ChatItem(profile: .statue1, chat: "I've got an important question for you to answer.") { [unowned self] in
                chatDecisionEngine.showDecisions(index: 1, toNode: chatBackgroundSprite, displayOnLeft: true)
            },
            ChatItem(profile: .statue1, chat: "Which shoes do you prefer?"),
            ChatItem(profile: .hero, imgPos: .left, chat: "It's a no brainer!"),
            
            ChatItem(profile: .statue1, chat: "There are things in this world you don't know the half of!"),
            ChatItem(profile: .statue1, chat: "People are happier when they are in love."),
            ChatItem(profile: .statue1, chat: "Don't tempt me with a good time!"),
        ], indices: [3, 1, 1, 1], shouldSkipFirstQuestion: FIRManager.decisions[1] != nil)
        
        dialogueStatue2 = StatueDialogue(dialogue: [ //Lv. 351
            //Story branching decision question
            ChatItem(profile: .statue2, chat: "I've got a question for you. Who's gonna with this war?") { [unowned self] in
                chatDecisionEngine.showDecisions(index: 2, toNode: chatBackgroundSprite)
            },
            ChatItem(profile: .hero, imgPos: .left, chat: "Duh, it's so obvious."),
            ChatItem(profile: .statue2, chat: "Interesting. I'll make note of it!"),
            
            ChatItem(profile: .hero, imgPos: .left, chat: "What is \(FireIceTheme.isFire ? "sand" : "snow")?"),
            ChatItem(profile: .statue2, chat: "Ah yes, \(FireIceTheme.isFire ? "sand" : "snow")."),
            ChatItem(profile: .hero, imgPos: .left, chat: "Thanks for nothing."),
            
            ChatItem(profile: .statue2, chat: "Taylor Swift is the greatest songwriter of all time.")
        ], indices: [3, 3, 1], shouldSkipFirstQuestion: FIRManager.decisions[2] != nil)

        dialogueStatue3 = StatueDialogue(dialogue: [ //Lv. 376
            //Story branching decision question
            ChatItem(profile: .statue3, chat: "I've got a question for you. Left or Right?") { [unowned self] in
                chatDecisionEngine.showDecisions(index: 3, toNode: chatBackgroundSprite, displayOnLeft: true)
            },
            ChatItem(profile: .statue3, chat: "Left or Right?"),
            ChatItem(profile: .hero, imgPos: .left, chat: "Duh, it's so obvious."),
            
            ChatItem(profile: .statue3, chat: "Don't listen to the last guy. He's full of it!"),
            ChatItem(profile: .statue3, chat: "I, on the other hand, tell the absolute truth!"),
            ChatItem(profile: .statue3, chat: "AMA... ask me anything!"),
        ], indices: [3, 1, 1, 1], shouldSkipFirstQuestion: FIRManager.decisions[3] != nil)
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

        switch level {
            
        //DARK REALM
        case Level.partyLevel: //Level: -1
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
            ]) { [unowned self] in
                handleDialogueCompletion(level: level, completion: completion)
            }
        case -100:
            AudioManager.shared.playSound(for: "magicheartbeatloop1", fadeIn: 3)

            sendChatArray(items: [
                ChatItem(profile: .blankvillain, chat: "\n\n...turn back now, before it's too late..."),
                ChatItem(profile: .trainer, imgPos: .left, chat: "Who are you!"),
                ChatItem(profile: .blankvillain, chat: "\n\n...the question is, where are we?..."),
                ChatItem(profile: .trainer, imgPos: .left, chat: "We are in the DARK REALM where evil cannot reach. What business do you have here?!"),
                ChatItem(profile: .blankvillain, chat: "\n\n...all will be revealed soon...") { [unowned self] in
                    superScene?.addChild(marlinBlast)
                    marlinBlast.animateBlast(playSound: true)
                },
                ChatItem(profile: .trainer, imgPos: .left, chat: "⚡️REVEAL YOURSELF!!!⚡️") {
                    AudioManager.shared.playSound(for: "littlegirllaugh")
                },
                ChatItem(profile: .blankvillain, chat: "\n\n...heh heh heh heh...")
            ]) { [unowned self] in
                AudioManager.shared.stopSound(for: "magicheartbeatloop1", fadeDuration: 5)
                AudioManager.shared.stopSound(for: "littlegirllaugh", fadeDuration: 5)

                chatBackgroundSprite.run(SKAction.wait(forDuration: 3)) { [unowned self] in
                    marlinBlast.removeFromParent()
                    
                    handleDialogueCompletion(level: level, completion: completion)
                }
            }
        case -150:
            AudioManager.shared.playSound(for: "magicheartbeatloop1", fadeIn: 3)
            
            sendChatArray(items: [
                ChatItem(profile: .blankvillain, chat: "\n\n...Marlin..."),
                ChatItem(profile: .trainer, imgPos: .left, chat: "Geez! Would you stop doing that?? It's most unsettling!"),
                ChatItem(profile: .blankvillain, chat: "\n\n...you're going to regret your decision..."),
                ChatItem(profile: .trainer, imgPos: .left, chat: "You will be the one to regret it if you don't tell me where the princess is!!"),
                ChatItem(profile: .blankvillain, chat: "\n\n...she is home now..."),
                ChatItem(profile: .trainer, imgPos: .left, chat: "Where is she?!! Is she unharmed??"),
                ChatItem(profile: .blankvillain, chat: "\n\n...see for yourself...") { [unowned self] in
                    AudioManager.shared.playSoundThenStop(for: "littlegirllaugh", playForDuration: 1, fadeOut: 3)
                    AudioManager.shared.playSoundThenStop(for: "movetile1", fadeIn: 1, playForDuration: 0.77, fadeOut: 2, delay: 1)
                    AudioManager.shared.stopSound(for: "magicheartbeatloop1", fadeDuration: 4)

                    //Disable fastForwardSprite for dramatic effect.
                    fastForwardSprite.removeFromParent()
                },
                ChatItem(profile: .princessCursed, chat: "i am fine. don't worry about me. now leave us.") { [unowned self] in
                    //Need to add this back to parent, because you removed it above.
                    chatBackgroundSprite.addChild(fastForwardSprite)
                },
                ChatItem(profile: .blankvillain, chat: "\n\n...see??? she's perfectly fine..."),
                ChatItem(profile: .trainer, imgPos: .left, chat: "Listen!! I don't think you know who you're dealing with but enough with the games! Now, show me who you are!!") { [unowned self] in
                    superScene?.addChild(marlinBlast)
                    superScene?.addChild(magmoorScary)

                    marlinBlast.animateBlast(playSound: false)
                    magmoorScary.flashImage(delay: 0.25)

                    AudioManager.shared.playSound(for: "magicheartbeatloop2")
                },
                ChatItem(profile: .trainer, imgPos: .left, chat: "⚡️MAGIC SPELL!!!⚡️"),
                ChatItem(profile: .villain, chat: "MYSTERIOUS FIGURE: I'll be seeing ya shortly."),
                ChatItem(profile: .trainer, imgPos: .left, chat: "Was that?? ............no. It can't be.")
            ]) { [unowned self] in
                AudioManager.shared.stopSound(for: "magicheartbeatloop2", fadeDuration: 5)
                
                chatBackgroundSprite.run(SKAction.wait(forDuration: 3)) { [unowned self] in
                    marlinBlast.removeFromParent()
                    magmoorScary.removeFromParent()
                    
                    handleDialogueCompletion(level: level, completion: completion)
                }
            }
        case -200:
            sendChatArray(items: [
                ChatItem(profile: .trainer, imgPos: .left, chat: "Hello..........? Are you there??"),
                //Needs like a 5 second pause here.
                ChatItem(profile: .trainer, imgPos: .left, chat: "................................") { [unowned self] in
                    //Disable fastForwardSprite for dramatic effect.
                    fastForwardSprite.removeFromParent()
                },
                ChatItem(profile: .trainer, imgPos: .left, chat: "Hmmm..")
            ]) { [unowned self] in
                //Need to add this back to parent, because you removed it above.
                chatBackgroundSprite.addChild(fastForwardSprite)
                
                chatBackgroundSprite.run(SKAction.wait(forDuration: 3)) { [unowned self] in
                    handleDialogueCompletion(level: level, completion: completion)
                }
            }
        case -250:
            AudioManager.shared.playSound(for: "magicheartbeatloop1", fadeIn: 3)
            
            let originalBrightness: CGFloat = UIScreen.main.brightness
            
            if originalBrightness < 0.25 {
                UIScreen.main.brightness = 0.25
            }
            else if originalBrightness < 0.5 {
                UIScreen.main.brightness = 0.5
            }
            
            superScene?.addChild(magmoorScary)

            sendChatArray(items: [
                ChatItem(profile: .villain, chat: "MYSTERIOUS FIGURE: You'll never find her. You can keep trying, but it will all be in vain. Give up now...") { [unowned self] in
                    magmoorScary.slowReveal(baseAlpha: 0.1)
                },
                ChatItem(profile: .trainer, imgPos: .left, chat: "YOU!!! I should have known! The whole time I'm thinking, \"No way he came crawling back into my life.\" And here you are... lurking in the shadows.") { [unowned self] in
                    AudioManager.shared.playSound(for: "scarymusicbox", fadeIn: 10)

                    magmoorScary.slowReveal(baseAlpha: 0.2)
                },
                ChatItem(profile: .villain, chat: "Surprised much? You need me. You're the yin to my yang."),
                ChatItem(profile: .villain, chat: "We're bounded by fate as elder Mystic, Machinegunkelly revealed during the Trial of Mages.") { [unowned self] in
                    magmoorScary.slowReveal(baseAlpha: 0.3)
                },
                ChatItem(profile: .trainer, imgPos: .left, chat: "That was over 500 years ago. Give us the child and leave this world!!") { [unowned self] in
                    magmoorScary.slowReveal(baseAlpha: 0.4)
                },
                ChatItem(profile: .villain, chat: "We would have made a great duo: the strongest Mystics in all the realms. But you chose a different path ..............why did you leave me?") { [unowned self] in
                    magmoorScary.slowReveal(baseAlpha: 0.5)
                },
                ChatItem(profile: .trainer, imgPos: .left, chat: "..............I did what I had to."),
                ChatItem(profile: .villain, chat: "Ah, yes. The self-serving \"Marlin the Magnificent.\" Always thinking he's right. Hmpf! Your loss.. such a shame.. you'll soon regret it....."),
                ChatItem(profile: .trainer, imgPos: .left, chat: "It's my loss.....")
            ]) { [unowned self] in
                AudioManager.shared.stopSound(for: "scarymusicbox", fadeDuration: 5)
                AudioManager.shared.stopSound(for: "magicheartbeatloop1", fadeDuration: 5)
                
                chatBackgroundSprite.run(SKAction.wait(forDuration: 3)) { [unowned self] in
                    handleDialogueCompletion(level: level) { [unowned self] _ in
                        magmoorScary.resetAlpha()
                        magmoorScary.removeFromParent()
                        
                        UIScreen.main.brightness = originalBrightness
                        
                        completion?(nil)
                    }
                }
            }
        case -300:
            AudioManager.shared.playSound(for: "magicheartbeatloop1", fadeIn: 3)
            AudioManager.shared.playSound(for: "scarymusicbox", fadeIn: 3)

            sendChatArray(items: [
                ChatItem(profile: .trainer, imgPos: .left, chat: "So you're saying if I merge powers with you, you'll let the princess go?"),
                ChatItem(profile: .villain, chat: "The princess will be free to do whatever she wants."),
                ChatItem(profile: .princess, chat: "Yay! More Netflix!"),
                ChatItem(profile: .villain, chat: "So what will it be, dear Marlin? C'mon. Merge with me. You know you want to."),
                ChatItem(profile: .trainer, imgPos: .left, chat: "..........deal. *Sigh* This is all my fault. I never should have brought him here. I'll go with you, but first let me tell him."),
                ChatItem(profile: .villain, chat: "Fine. But make it quick. I have a universe to rule."),
                ChatItem(profile: .trainer, imgPos: .left, chat: "Just do not harm the girl. Promise me."),
                ChatItem(profile: .villain, chat: "Yes, but remember.. you belong to me now."),
                ChatItem(profile: .trainer, imgPos: .left, chat: "(I hope he'll forgive me for this...)")
            ]) { [unowned self] in
                AudioManager.shared.stopSound(for: "scarymusicbox", fadeDuration: 5)
                AudioManager.shared.stopSound(for: "magicheartbeatloop1", fadeDuration: 5)

                chatBackgroundSprite.run(SKAction.wait(forDuration: 3)) { [unowned self] in
                    handleDialogueCompletion(level: level, completion: completion)
                }
            }
            
        //PUZZLE REALM
        case 1:
            sendChatArray(items: [
                ChatItem(profile: .hero, imgPos: .left, chat: "PUZL BOY: ...then one of the dragons swooped down and carried her away! It. Was. Harrowing. So... where are we? And who are you??"),
                ChatItem(profile: .trainer, chat: "OLD MAN: We must hurry! I suspect she is being taken to the dragon's lair. I have transported you to the PUZZLE REALM, our gateway to the lair."),
                ChatItem(profile: .hero, imgPos:.left, chat: "Cool. I'm PUZL Boy. But you can call me...... PUZL Boy!"),
                ChatItem(profile: .trainer, chat: "MARLIN: Right.. I'm Marlin, your guide. Now listen up!"),
                ChatItem(profile: .trainer, chat: "The dragon's lair is buried deep inside Earth's core, and the only way to reach it is by solving puzzles."),
                ChatItem(profile: .trainer, chat: "There are 500 levels in total you will have to complete, each with increasing difficulty."),
                ChatItem(profile: .trainer, chat: "The goal for each level is to make it through the gate in under a certain number of moves.") { [unowned self] in
                    delegate?.illuminatePanel(at: (0, 1), useOverlay: false)
                    delegate?.illuminatePanel(at: (1, 0), useOverlay: false)
                    delegate?.illuminatePanel(at: (1, 2), useOverlay: false)
                    delegate?.illuminatePanel(at: (2, 1), useOverlay: false)
                },
                ChatItem(profile: .trainer, chat: "You can move to any available panel on your left, right, above, and below. Simply tap the panel to move there. Diagonal moves are not allowed.") { [unowned self] in
                    delegate?.deilluminatePanel(at: (0, 1), useOverlay: false)
                    delegate?.deilluminatePanel(at: (1, 0), useOverlay: false)
                    delegate?.deilluminatePanel(at: (1, 2), useOverlay: false)
                    delegate?.deilluminatePanel(at: (2, 1), useOverlay: false)
                    delegate?.illuminateDisplayNode(for: .moves)
                },
                ChatItem(profile: .trainer, chat: "If your move count hits 0, it's game over buddy! Your move count can be found in the upper left corner next to the boot. 👢") { [unowned self] in
                    delegate?.deilluminateDisplayNode(for: .moves)
                    delegate?.illuminatePanel(at: (1, 2), useOverlay: true)
                    delegate?.illuminatePanel(at: (2, 2), useOverlay: false)
                },
                ChatItem(profile: .trainer, chat: "See the gate? It's sealed shut. To open it, collect all the gems in the level. Simple, right?"),
                ChatItem(profile: .hero, imgPos: .left, chat: "Right. Let's go save the princess!")
            ]) { [unowned self] in
                delegate?.deilluminatePanel(at: (1, 2), useOverlay: true)
                delegate?.deilluminatePanel(at: (2, 2), useOverlay: false)

                handleDialogueCompletion(level: level, completion: completion)
            }
        case 13:
            delegate?.illuminatePanel(at: (0, 1), useOverlay: true)
            delegate?.illuminatePanel(at: (0, 2), useOverlay: true)
            delegate?.illuminatePanel(at: (1, 2), useOverlay: true)
            
            sendChatArray(items: [
                ChatItem(profile: .trainer, chat: "Easy right? Levels get progressively harder the farther you go. Looks like that gem is trapped between those boulders.") { [unowned self] in
                    delegate?.illuminatePanel(at: (2, 1), useOverlay: true)
                },
                ChatItem(profile: .trainer, chat: "Not to worry! See that hammer over there? Use it to break through."),
                ChatItem(profile: .hero, imgPos: .left, chat: "Yeah I put 2+2 together."),
                ChatItem(profile: .trainer, chat: "Well. Not everyone is as bright as you, PUZL Boy."),
                ChatItem(profile: .trainer, chat: "Collect hammers as you go. They'll break after one use so be mindful of that.") { [unowned self] in
                    delegate?.illuminateDisplayNode(for: .hammers)
                },
                ChatItem(profile: .trainer, chat: "Your inventory count can be found in the upper right."),
                ChatItem(profile: .hero, imgPos: .left, chat: "I got this, dude!") { [unowned self] in
                    delegate?.deilluminateDisplayNode(for: .hammers)
                    delegate?.deilluminatePanel(at: (0, 1), useOverlay: true)
                    delegate?.deilluminatePanel(at: (0, 2), useOverlay: true)
                    delegate?.deilluminatePanel(at: (1, 2), useOverlay: true)
                    delegate?.deilluminatePanel(at: (2, 1), useOverlay: true)
                }
            ]) { [unowned self] in
                handleDialogueCompletion(level: level, completion: completion)
            }
        case 19:
            delegate?.illuminatePanel(at: (0, 1), useOverlay: false)
            delegate?.illuminatePanel(at: (2, 1), useOverlay: false)
            
            sendChatArray(items: [
                ChatItem(profile: .trainer, chat: "Watch out for poisonous marsh! Stepping on one of the crimson colored panels will drag you down, costing you 2 moves."),
                ChatItem(profile: .trainer, chat: "However, sometimes stepping in poisonous marsh is unavoidable."),
                ChatItem(profile: .hero, imgPos: .left, chat: "Man... and I just got these new kicks!")
            ]) { [unowned self] in
                delegate?.deilluminatePanel(at: (0, 1), useOverlay: false)
                delegate?.deilluminatePanel(at: (2, 1), useOverlay: false)

                handleDialogueCompletion(level: level, completion: completion)
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
            ]) { [unowned self] in
                delegate?.deilluminatePanel(at: (0, 1), useOverlay: true)
                delegate?.deilluminatePanel(at: (1, 2), useOverlay: true)
        
                handleDialogueCompletion(level: level, completion: completion)
            }
        case 51:
            delegate?.illuminatePanel(at: (1, 1), useOverlay: true)
            
            sendChatArray(items: [
                ChatItem(profile: .hero, imgPos: .left, chat: "That's him! That's the dragon that took the princess! 😡"),
                ChatItem(profile: .trainer, chat: "Relax... That's one of many dragons you'll encounter on your journey. But don't get too close or he'll attack, costing you 1 health point."),
                ChatItem(profile: .hero, imgPos: .left, chat: "He looks kinda small and underwhelming to me..."),
                ChatItem(profile: .trainer, chat: "Hey, this is a solo project with zero budget, whaddya want from me?! As I was saying...") { [unowned self] in
                    delegate?.illuminateDisplayNode(for: .health)
                },
                ChatItem(profile: .trainer, chat: "Once your health drops to 0, it's lights out! Your health can be found in the upper left next to the heart. 💖") { [unowned self] in
                    delegate?.deilluminateDisplayNode(for: .health)
                    delegate?.illuminateDisplayNode(for: .swords)
                },
                ChatItem(profile: .trainer, chat: "Don't believe me? Go ahead. Try and pet him, I dare you! But you won't be able to defeat him without a sword. 🗡"),
                ChatItem(profile: .hero, imgPos: .left, chat: "Yeah, ok old man. Lemme guess, I can only use the sword once before it breaks?") { [unowned self] in
                    delegate?.deilluminateDisplayNode(for: .swords)
                },
                ChatItem(profile: .trainer, chat: "You got it. Atta boy! 🫰🏼"),
                ChatItem(profile: .hero, imgPos: .left, chat: "😵‍💫 Woof woof— Stop that!")
            ]) { [unowned self] in
                handleDialogueCompletion(level: level, completion: completion)
            }
        case 76:
            delegate?.illuminatePanel(at: (0, 1), useOverlay: false)
            delegate?.illuminatePanel(at: (0, 2), useOverlay: false)
            delegate?.illuminatePanel(at: (1, 2), useOverlay: false)
            delegate?.illuminatePanel(at: (0, 1), useOverlay: true)
            delegate?.illuminatePanel(at: (1, 2), useOverlay: true)
            
            sendChatArray(items: [
                ChatItem(profile: .trainer, chat: "Ice, ice, baby! Step on this and you'll slide until you hit an obstacle."),
                ChatItem(profile: .trainer, chat: "The nice thing though is that it'll only cost you 1 move as long as you're sliding continuously."),
                ChatItem(profile: .hero, imgPos: .left, chat: "The cold never bothered me anyway."),
                ChatItem(profile: .trainer, chat: "Let it go, dude.") { [unowned self] in
                    delegate?.deilluminatePanel(at: (0, 1), useOverlay: false)
                    delegate?.deilluminatePanel(at: (0, 2), useOverlay: false)
                    delegate?.deilluminatePanel(at: (1, 2), useOverlay: false)
                    delegate?.deilluminatePanel(at: (0, 1), useOverlay: true)
                    delegate?.deilluminatePanel(at: (1, 2), useOverlay: true)
                },
            ]) { [unowned self] in
                handleDialogueCompletion(level: level, completion: completion)
            }
        case PauseResetEngine.resetButtonUnlock: //Level: 100
            sendChatArray(items: [
                ChatItem(profile: .trainer, chat: "Congrats! You made it to level \(PauseResetEngine.resetButtonUnlock). There's a little surprise waiting for you at the end. Beat this and you're one step closer to indescribable fun!!! 💃🏾🪩🕺🏻"),
                ChatItem(profile: .hero, imgPos: .left, chat: "I can hardly contain my excitement.") { [unowned self] in
                    delegate?.illuminateMinorButton(for: .reset)
                },
                ChatItem(profile: .trainer, chat: "That's the spirit! Now if you ever get stuck, you can tap the Reset button to restart the level."),
                ChatItem(profile: .trainer, chat: "Be warned though, restarting a level will cost you one of your precious lives...") { [unowned self] in
                    delegate?.deilluminateMinorButton(for: .reset)
                },
                ChatItem(profile: .hero, imgPos: .left, chat: "It's all good. I've got my mom's credit card if I need to buy more. 😃")
            ]) { [unowned self] in
                GameCenterManager.shared.updateProgress(achievement: .avidReader, shouldReportImmediately: true)

                handleDialogueCompletion(level: level, completion: completion)
            }
        case 101: //NEEDS CUTSCENE chance for a funny, short cutscene introducing the mystics then a record scratch when PUZL Boy is bored.
            chapterTitleSprite.setChapter(1)
            chapterTitleSprite.showTitle { [unowned self] in
                sendChatArray(items: [
                    ChatItem(profile: .hero, imgPos: .left, chat: "Merlin! C'mon, we gotta go."),
                    ChatItem(profile: .trainer, chat: "The name's Marlin. MARLIN THE MAGNIFICENT! Not Merlin. Not dude. Not crusty old man!"),
                    ChatItem(profile: .hero, imgPos: .left, chat: "Oh! Marlin like the fish??? I hate fish by the way. The smell, the texture..."),
                    ChatItem(profile: .trainer, chat: "No. Not like the fish. Marlin like... the Magician. You see, in my world I am what is known as a Mystic."),
                    ChatItem(profile: .trainer, chat: "As a matter of fact, I come from a long line of legendary and powerful Mystics, each with our own unique powers and abilities..."),
                    ChatItem(profile: .hero, imgPos: .left, chat: "Oh, wait. You're thinking of Merlin the Magician."),
                    ChatItem(profile: .trainer, chat: "Some Mystics control the elements: fire, water, air.. Some are all-knowing, while others govern the arts and science. I happen to be a water mage."),
                    ChatItem(profile: .trainer, chat: "Let's see, there's Maxel, Mawren, and Malana, our Mystics in training who I am personally mentoring..."),
                    ChatItem(profile: .hero, imgPos: .left, chat: "Mmmkay. Got it 🥱"),
                    ChatItem(profile: .trainer, chat: "Moving on. I received a visitor while I was in the DARK REALM. He didn't say who he was, but I think he might be connected to the disappearance."),
                    ChatItem(profile: .hero, imgPos: .left, chat: "Water mage... like a fish? A marlin is a fish."),
                    ChatItem(profile: .trainer, chat: "Enough with the fish! We need to be on the lookout for the mysterious figure. Likely he holds the key to this mystery."),
                    ChatItem(profile: .hero, imgPos: .left, chat: "What's he look like?"),
                    ChatItem(profile: .trainer, chat: "Hmm. If you run into someone who looks mysterious, It's probably him.")
                ]) { [unowned self] in
                    handleDialogueCompletion(level: level, completion: completion)
                }
            }
        case 112:
            sendChatArray(items: [
                ChatItem(profile: .hero, imgPos: .left, chat: "What's so special about this little girl anyway?"),
                ChatItem(profile: .trainer, chat: "She's no ordinary little girl. She is the princess of Vaeloria, a mystical realm known for its immense magic."),
                ChatItem(profile: .trainer, chat: "Dragons are ancient and powerful creatures that inhabit the land of Vaeloria and are deeply connected to its magic."),
                ChatItem(profile: .trainer, chat: "The sudden emergence of dragons in your world suggests something bigger is at play, and this little girl... Princess Olivia... is at the center of it all."),
                ChatItem(profile: .hero, imgPos: .left, chat: "What do they want with her?"),
                ChatItem(profile: .trainer, chat: "That has yet to be determined, though I suspect something very dark is behind all this... Come. Let's not waste anymore time.")
            ]) { [unowned self] in
                handleDialogueCompletion(level: level, completion: completion)
            }
        case PauseResetEngine.hintButtonUnlock: //Level: 140
            sendChatArray(items: [
                ChatItem(profile: .hero, imgPos: .left, chat: "You good old man— Merlin.. er, Marlin. Sir?? You been awfully quiet. You're usually going on and on and on about useless info right about now."),
                ChatItem(profile: .trainer, chat: "Don't make me snap."),
                ChatItem(profile: .hero, imgPos: .left, chat: "No don't! Look, if it's the old man comments, everybody gets old. It's just an inevitability of life. I'm 16 so everyone looks old to me. You're like what... 50?"),
                ChatItem(profile: .trainer, chat: "902."),
                ChatItem(profile: .hero, imgPos: .left, chat: "NINE HUNDRED??!! What are you, like a wizard or something? \"Marlin the Fish Wizard...\""),
                ChatItem(profile: .trainer, chat: "I told you I am NOT a wizard, I am a Mystic! MYSTIC!! Yeesh, my blood pressure..."),
                ChatItem(profile: .hero, imgPos: .left, chat: "Yikes, calm down. You don't look a day over 800 to be honest."),
                ChatItem(profile: .trainer, chat: "PUZL Boy, I need you to be serious! What lies ahead will test your patience. It will make you want to throw your phone out the window. You need to be prepared!"),
                ChatItem(profile: .hero, imgPos: .left, chat: "Ok ok. I'll be ready. I already know how to use hammers and swords. Nothing can stop me!") { [unowned self] in
                    delegate?.illuminateMinorButton(for: .hint)
                },
                ChatItem(profile: .trainer, chat: "Hilarious. I'm adding another tool to your arsenal. Tap the Hints button at the start of a level to illuminate your next move. Tap again to get the next hint."),
                ChatItem(profile: .trainer, chat: "Keep tapping for as many hints as you need. Hints become disabled once you move past your last hint. The number in red is your available hints."),
                ChatItem(profile: .trainer, chat: "If you run out of hints, you can buy more in the Shop tab of the Settings menu. Questions?") { [unowned self] in
                    delegate?.deilluminateMinorButton(for: .hint)
                },
                ChatItem(profile: .hero, imgPos: .left, chat: "Wow.. you're 900 years old. What's that in human years?")
            ]) { [unowned self] in
                handleDialogueCompletion(level: level, completion: completion)
            }
        case 152:
            sendChatArray(items: [
                ChatItem(profile: .trainer, chat: "I was once a teacher for Princess Olivia. We didn't get very far in her training, but I could see she had a natural ability to harness magic."),
                ChatItem(profile: .hero, imgPos: .left, chat: "For real? Why did you stop training her?"),
                ChatItem(profile: .trainer, chat: "I had to... return home for important Mystic duties."),
                ChatItem(profile: .trainer, chat: "But before I left the princess, I placed a sigil on her hand. A protection spell. 🪬"),
                ChatItem(profile: .hero, imgPos: .left, chat: "Oh, good. So she should be safe then? Protection from what, evil or something?"),
                ChatItem(profile: .trainer, chat: "Something like that.")
            ]) { [unowned self] in
                handleDialogueCompletion(level: level, completion: completion)
            }
        case 180:
            AudioManager.shared.adjustVolume(to: 0.2, for: AudioManager.shared.currentTheme, fadeDuration: 3)
            AudioManager.shared.playSound(for: "littlegirllaugh", fadeIn: 3)
            
            sendChatArray(items: [
                ChatItem(profile: .blankprincess, chat: "\n\nIs... is anybody there???"),
                ChatItem(profile: .blankprincess, chat: "\n\nHello?????"),
                ChatItem(profile: .blankprincess, chat: "\n\nWon't anyone help me!!!"),
                ChatItem(profile: .hero, imgPos: .left, chat: "Princess, is that you??? Hang on! We're coming to get you!!!") {
                    AudioManager.shared.playSound(for: "chatopenvillain")
                },
                ChatItem(profile: .blankvillain, chat: "\n\n...heh heh heh heh heh... ") {
                    AudioManager.shared.adjustVolume(to: 1, for: AudioManager.shared.currentTheme, fadeDuration: 5)
                    AudioManager.shared.stopSound(for: "littlegirllaugh", fadeDuration: 5)
                },
                ChatItem(profile: .hero, imgPos: .left, chat: "Wh—what the... who's there?!! You heard that too, right??"),
                ChatItem(profile: .trainer, chat: "Oh sweet child! Don't worry, we're coming to get you!!"),
                ChatItem(profile: .trainer, chat: "Wait..... They're gone. Never mind. Let's go!")
            ]) { [unowned self] in
                handleDialogueCompletion(level: level, completion: completion)
            }
        case 201:
            chapterTitleSprite.setChapter(2)
            chapterTitleSprite.showTitle { [unowned self] in
                handleDialogueCompletion(level: level, completion: completion)
            }
        case 221:
            AudioManager.shared.adjustVolume(to: 0.2, for: AudioManager.shared.currentTheme, fadeDuration: 3)
            AudioManager.shared.playSound(for: "littlegirllaugh", fadeIn: 3)
            
            sendChatArray(items: [
                ChatItem(profile: .blankprincess, chat: "\nHello? Is anyone there? Can anyone hear me? Hellooo? HELLO!!!!!!"),
                ChatItem(profile: .hero, imgPos: .left, chat: "Princess?! We can hear you! Can you hear us??"),
                ChatItem(profile: .blankprincess, chat: "\nHelp me please, PUZL Boy!!! I don't know where I am!"),
                ChatItem(profile: .blankprincess, chat: "\nIt's very smoky in here and it smells like burning trees!"),
                ChatItem(profile: .blankprincess, chat: "\nOh! And this mysterious man has me! (Uh oh, he's coming back...)"),
                ChatItem(profile: .hero, imgPos: .left, chat: "Where are you!!! Can you hear me! OLIVIA!!! Burning trees... Marlin we gotta do something!") {
                    AudioManager.shared.adjustVolume(to: 1, for: AudioManager.shared.currentTheme, fadeDuration: 5)
                    AudioManager.shared.stopSound(for: "littlegirllaugh", fadeDuration: 5)
                },
                ChatItem(profile: .trainer, chat: "She can't hear us. I can't sense her presence. Whatever has a hold of her is keeping her in between realms. We must keep moving if we are to find her."),
                ChatItem(profile: .hero, imgPos: .left, chat: "Who is this mysterious man you guys are talking about?"),
                ChatItem(profile: .trainer, chat: "I... I can't say for sure. But I have a sinking feeling...")
            ]) { [unowned self] in
                handleDialogueCompletion(level: level, completion: completion)
            }
        case 251:
            sendChatArray(items: [
                ChatItem(profile: .hero, imgPos: .left, chat: "What took you so long? I was talking to myself before I realized you were still in the DARK REALM..."),
                ChatItem(profile: .trainer, chat: "PUZL Boy, I—"),
                ChatItem(profile: .hero, imgPos: .left, chat: "As I was saying, I used to have regular milk with my cereal, then I discovered oat milk and dude, it slaps!"),
                ChatItem(profile: .trainer, chat: "We need to find the princess and send her back to Vaeloria right away. Time is of the essence."),
                ChatItem(profile: .hero, imgPos: .left, chat: "Yeah, we're headed to Earth's core. Why the rush all of a sudden?"),
                ChatItem(profile: .trainer, chat: "That man... I know him."),
                ChatItem(profile: .hero, imgPos: .left, chat: "Ok. So let's go find him, beat him up, and get the princess back."),
                ChatItem(profile: .trainer, chat: "Oh, sweet summer child. If it were only that simple. Keep your head down and follow closely. You have no idea what we're up against."),
                ChatItem(profile: .hero, imgPos: .left, chat: "\"Sweet summer child??\"") { [unowned self] in
                    delegate?.illuminatePanel(at: (0, 4), useOverlay: true)
                    delegate?.illuminatePanel(at: (3, 2), useOverlay: true)
                },
                ChatItem(profile: .trainer, chat: "And one more thing... you'll notice there are green warps on the board. Stepping on a green warp will transport you to the other green warp.") { [unowned self] in
                    delegate?.deilluminatePanel(at: (0, 4), useOverlay: true)
                    delegate?.deilluminatePanel(at: (3, 2), useOverlay: true)
                },
            ]) { [unowned self] in
                handleDialogueCompletion(level: level, completion: completion)
            }
        case 276:
            guard let delegate = delegate else {
                //This allows the game to move forward in case the delegate is not set, for some reason!
                handleDialogueCompletion(level: level, completion: completion)
                return
            }
            
            let spawnPoint: K.GameboardPosition = (0, 1)
            let decisionIndex = 0
            
            delegate.spawnPrincessCapture(at: spawnPoint, shouldAnimateWarp: true) { [unowned self] in
                sendChatArray(items: [
                    ChatItem(profile: .princess, chat: "PRINCESS OLIVIA: Help meeeee PUZL Boy!!! It's dark and scary in there. And this guy's breath is really stinky!"),
                    ChatItem(profile: .hero, imgPos: .left, chat: "Gasp! It's the mysterious man!!!!!"),
                    ChatItem(profile: .trainer, imgPos: .left, chat: "Magmoor, stop this at once! It's not too late."),
                    ChatItem(profile: .villain, chat: "MAGMOOR: If you want to see your precious princess again, then let us merge powers."),
                    ChatItem(profile: .trainer, imgPos: .left, chat: "NO! You want absolute power. We Mystics share power equally; it keeps the realms in balance!"),
                    ChatItem(profile: .villain, chat: "I have been floating aimlessly in the LIMBO REALM for centuries. Why?? Because the Council saw me as the biggest threat to their unjust reign."),
                    ChatItem(profile: .villain, chat: "But my time in exile helped me to find my way. It gave me new meaning and purpose: I WAS MEANT TO RULE THEM ALL."),
                    ChatItem(profile: .trainer, imgPos: .left, chat: "You want all out war. Your actions will surely plunge the realms into total darkness. Don't let this consume you Magmoor!!"),
                    ChatItem(profile: .villain, chat: "The system is broken. The realms are headed towards eternal darkness. It requires a new world order. It needs..... cleansing."),
                    ChatItem(profile: .princess, chat: "Your teeth need cleansing!"),
                    ChatItem(profile: .trainer, imgPos: .left, chat: "MAGMOOR LISTEN TO YOURSELF!!! You've completely lost it. Give up this delusion and let the princess go!!!"),
                    ChatItem(profile: .hero, imgPos: .left, chat: "If you touch a hair on her head, it's gonna be the end for you, Mantamar!"),
                    ChatItem(profile: .villain, chat: "Open your eyes and see! Join me in the purification. We can rule the realms... together."),
                    ChatItem(profile: .trainer, imgPos: .left, chat: "NO!! We shall not join in your madness. We will fight to protect the realms!"),
                    ChatItem(profile: .villain, chat: "Pity. Then suffer the consequences."),
                    ChatItem(profile: .princess, endChat: true, chat: "Noooooo! Don't let him take meeeeeee!!!!") { [unowned self] in
                        fadeDimOverlay()
                        delegate.despawnPrincessCapture(at: spawnPoint, completion: {})
                    },
                    ChatItem(profile: .hero, imgPos: .left, pause: 8, startNewChat: true, chat: "That was creepy. Marlin, I did NOT sign up for this.......", handler: nil),
                    ChatItem(profile: .trainer, chat: "PUZL Boy this is now your reality. Take responsibility for your future. YOU have the power to change it!"),
                    ChatItem(profile: .hero, imgPos: .left, chat: "I know, I know. My mom always says, \"The power is yours!\" Ok... so what does Marzipan want with the princess?"),
                    ChatItem(profile: .trainer, chat: "Magmoor—one of the most powerful Mystics from my realm. I do not know what he intends to do with the princess, although we should assume the worst."),
                    ChatItem(profile: .hero, imgPos: .left, chat: "He's not gonna sacrifice her is he?!?! Because that's just not cool."),
                    ChatItem(profile: .trainer, chat: "I almost did not recognize him in that grotesque form. He used to be so handsome.") { [unowned self] in
                        chatDecisionEngine.showDecisions(index: decisionIndex, toNode: chatBackgroundSprite)
                    },
                    ChatItem(profile: .hero, imgPos: .left, endChat: false, chat: "Ok, so what's our next move:", handler: nil)
                ]) { [unowned self] in
                    // FIXME: - I don't like this nested sendChatArray()...
                    sendChatArray(items: [
                        ChatItem(profile: .hero, imgPos: .left, startNewChat: false, chat: "\(FIRManager.decisions[decisionIndex].isLeftButton() ? "We should prepare first." : "BRING ME MAGMOOR!!!")", handler: nil),
                        ChatItem(profile: .trainer, chat: "\(FIRManager.decisions[decisionIndex].isLeftButton() ? "A wise decision. Let's keep moving..." : "Okay but we need to be EXTRA cautious.")"),
                    ]) { [unowned self] in
                        AudioManager.shared.adjustVolume(to: 1, for: AudioManager.shared.currentTheme, fadeDuration: 3)
                        
                        handleDialogueCompletion(level: level, completion: completion)
                    }
                }
            } //end delegate.spawnPrincessCapture() no warp animation
            
            
        // TODO: - Chat Decisions
        
//        case 210:
//            let decisionIndex = 0
//            
//            sendChatArray(items: [
//                ChatItem(profile: .trainer, chat: "What's it gonna be, PUZL Boy?") { [unowned self] in
//                    chatDecisionEngine.showDecisions(index: decisionIndex, toNode: chatBackgroundSprite)
//                },
//                ChatItem(profile: .hero, imgPos: .left, endChat: false, chat: "Hmmm, let me think about it...", handler: nil)
//            ]) { [unowned self] in
//                let decision = FIRManager.decisions[decisionIndex].isLeftButton() ? chatDecisionEngine.decisionButtons[decisionIndex].left.text : chatDecisionEngine.decisionButtons[decisionIndex].right.text
//                
//                sendChatArray(items: [
//                    ChatItem(profile: .trainer, startNewChat: false, chat: "Good choice! I also like \(decision).", handler: nil)
//                ]) { [unowned self] in
//                    handleDialogueCompletion(level: level, completion: completion)
//                }
//            }
//        case 211:
//            let decisionIndex = 1
//            
//            sendChatArray(items: [
//                ChatItem(profile: .trainer, chat: "What's it gonna be, PUZL Boy?") { [unowned self] in
//                    chatDecisionEngine.showDecisions(index: decisionIndex, toNode: chatBackgroundSprite)
//                },
//                ChatItem(profile: .hero, imgPos: .left, endChat: false, chat: "Hmmm, let me think about it...", handler: nil)
//            ]) { [unowned self] in
//                let decision = FIRManager.decisions[decisionIndex].isLeftButton() ? chatDecisionEngine.decisionButtons[decisionIndex].left.text : chatDecisionEngine.decisionButtons[decisionIndex].right.text
//                
//                sendChatArray(items: [
//                    ChatItem(profile: .trainer, startNewChat: false, chat: "Good choice! I also like \(decision).", handler: nil)
//                ]) { [unowned self] in
//                    handleDialogueCompletion(level: level, completion: completion)
//                }
//            }
//        case 212:
//            let decisionIndex = 2
//            
//            sendChatArray(items: [
//                ChatItem(profile: .trainer, chat: "What's it gonna be, PUZL Boy?") { [unowned self] in
//                    chatDecisionEngine.showDecisions(index: decisionIndex, toNode: chatBackgroundSprite)
//                },
//                ChatItem(profile: .hero, imgPos: .left, endChat: false, chat: "Hmmm, let me think about it...", handler: nil)
//            ]) { [unowned self] in
//                let decision = FIRManager.decisions[decisionIndex].isLeftButton() ? chatDecisionEngine.decisionButtons[decisionIndex].left.text : chatDecisionEngine.decisionButtons[decisionIndex].right.text
//                
//                sendChatArray(items: [
//                    ChatItem(profile: .trainer, startNewChat: false, chat: "Good choice! I also like \(decision).", handler: nil)
//                ]) { [unowned self] in
//                    handleDialogueCompletion(level: level, completion: completion)
//                }
//            }
//        case 213:
//            let decisionIndex = 3
//            
//            sendChatArray(items: [
//                ChatItem(profile: .trainer, chat: "What's it gonna be, PUZL Boy?") { [unowned self] in
//                    chatDecisionEngine.showDecisions(index: decisionIndex, toNode: chatBackgroundSprite)
//                },
//                ChatItem(profile: .hero, imgPos: .left, endChat: false, chat: "Hmmm, let me think about it...", handler: nil)
//            ]) { [unowned self] in
//                let decision = FIRManager.decisions[decisionIndex].isLeftButton() ? chatDecisionEngine.decisionButtons[decisionIndex].left.text : chatDecisionEngine.decisionButtons[decisionIndex].right.text
//                
//                sendChatArray(items: [
//                    ChatItem(profile: .trainer, startNewChat: false, chat: "Good choice! I also like \(decision).", handler: nil)
//                ]) { [unowned self] in
//                    handleDialogueCompletion(level: level, completion: completion)
//                }
//            }
        case 282:
            if !dialogueWithCutscene[level]! {
                let cutscene = CutsceneMagmoor()
                
                sendChatArray(items: [
                    ChatItem(profile: .hero, imgPos: .left, chat: "They couldn't have gone far. Let's find this dude and kick him where the sun don't shine!"),
                    ChatItem(profile: .trainer, chat: "It's not going to be that simple, PUZL Boy. Magmoor grows powerful by the minute. The Elders could not keep him contained."),
                    ChatItem(profile: .hero, imgPos: .left, chat: "The Elders...?")
                ]) { [unowned self] in
                    handleDialogueCompletion(level: level, cutscene: cutscene, completion: completion)
                }
            }
            else {
                sendChatArray(items: [
                    ChatItem(profile: .hero, imgPos: .left, chat: "Ok... so how do we get the genie back in the bottle?"),
                    ChatItem(profile: .trainer, chat: "There is yet a way. I just need more time."),
                    ChatItem(profile: .hero, imgPos: .left, chat: "We haven't got any time! Princess needs us now!"),
                    ChatItem(profile: .trainer, chat: "YES! YES!! Just let me think for one second—")
                ]) { [unowned self] in
                    handleDialogueCompletion(level: level, completion: completion)
                }
            }
        case 298:
            let spawnPoint: K.GameboardPosition = (0, 1)
            
            guard let delegate = delegate else {
                //This allows the game to move forward in case the delegate is not set, for some reason!
                handleDialogueCompletion(level: level, completion: completion)
                return
            }
            
            delegate.spawnPrincessCapture(at: spawnPoint, shouldAnimateWarp: true) { [unowned self] in
                sendChatArray(items: [
                    ChatItem(profile: .villain, chat: "Come to your senses yet?"),
                    ChatItem(profile: .hero, imgPos: .left, chat: "HEY! Leave her alone, Mylar!"),
                    ChatItem(profile: .trainer, imgPos: .left, chat: "Magmoor, let her go! You will have to answer to the kingdom of Vaeloria for your actions!"),
                    ChatItem(profile: .villain, chat: "Actions?? For what? I'm merely keeping her until the time comes..."),
                    ChatItem(profile: .hero, imgPos: .left, chat: "Until the time comes for what?? You won't harm her will you?!!"),
                    ChatItem(profile: .villain, chat: "Sacrifice her? Oh heavens, no! I'm not that cruel..."),
                    ChatItem(profile: .hero, imgPos: .left, chat: "I didn't say sacrifice—"),
                    ChatItem(profile: .trainer, imgPos: .left, chat: "Princess Olivia, are you ok?"),
                    ChatItem(profile: .princess, chat: "It's not so bad in there. They have Netflix."),
                    ChatItem(profile: .trainer, imgPos: .left, chat: "Remember what I taught you."),
                    ChatItem(profile: .princess, endChat: true, chat: "Ok I'll try...") { [unowned self] in
                        fadeDimOverlay()
                        
                        delegate.flashPrincess(at: spawnPoint, completion: {})
                    },
                    ChatItem(profile: .princess, pause: 6, startNewChat: true, chat: "I'm not strong enough... I can't do it, uncle Marlin!", handler: nil),
                    ChatItem(profile: .trainer, imgPos: .left, chat: "Yes you can, princess! You have got to keep trying. Do not give up!"),
                    ChatItem(profile: .villain, chat: "Cute. I hate to cut the reunion short, but if you won't merge with me, we'll be on our way."),
                    ChatItem(profile: .trainer, imgPos: .left, chat: "Do not be afraid! You are braver than you think."),
                    ChatItem(profile: .princess, chat: "It's ok. I'm getting used to it."),
                    ChatItem(profile: .princess, chat: "Anyway this part's fun..... Weeeeeee!")
                ]) { [unowned self] in
                    fadeDimOverlay()

                    delegate.despawnPrincessCapture(at: spawnPoint) { [unowned self] in
                        AudioManager.shared.adjustVolume(to: 1, for: AudioManager.shared.currentTheme, fadeDuration: 3)
                        handleDialogueCompletion(level: level, completion: completion)
                    }
                }
            }
        case 301:
            let musicFadeDuration: TimeInterval = 3
            
            sendChatArray(items: [
                ChatItem(profile: .hero, imgPos: .left, chat: "I've got a plan."),
                ChatItem(profile: .trainer, chat: "PUZL Boy, there's something I need to tell you—"),
                ChatItem(profile: .hero, imgPos: .left, chat: "I'll distract him with this sword. Then when he's not looking, you blast away with magic."),
                ChatItem(profile: .trainer, chat: "I'm leaving."),
                ChatItem(profile: .hero, imgPos: .left, chat: "THEN while he's weakened, I'll use said sword to deliver the final blow and—"),
                ChatItem(profile: .hero, imgPos: .left, chat: ".....wait, what do you mean you're leaving?! Where are we going??") {
                    AudioManager.shared.lowerVolume(for: AudioManager.shared.currentTheme, fadeDuration: musicFadeDuration)
                },
                ChatItem(profile: .trainer, chat: "He agreed to set the princess free. In return, I am going to merge with him."),
                ChatItem(profile: .hero, imgPos: .left, chat: "Ok but can we please stop calling it that?"),
                ChatItem(profile: .trainer, chat: "Merging of powers is completely natural for our kind. We do it everywhere. All the time. At home, in public. We do it without shame or regret. So, no."),
                ChatItem(profile: .hero, imgPos: .left, chat: "Why should we trust him?!! He's obviously the bad guy!!!"),
                ChatItem(profile: .trainer, chat: "With the princess free, we stand a better chance at defeating Magmoor once and for all."),
                ChatItem(profile: .trainer, chat: "Just keep solving puzzles like you're doing and you will be just fine."),
                ChatItem(profile: .hero, imgPos: .left, chat: "But, but... I can't do this without you!! 🥺"),
                ChatItem(profile: .trainer, chat: "Trust your instincts, PUZL Boy. I have equipped you with all the knowledge you need to succeed."),
                ChatItem(profile: .hero, imgPos: .left, chat: "Marlin!!!"),
                ChatItem(profile: .trainer, chat: "Goodbye. For now...")
            ]) { [unowned self] in
                chapterTitleSprite.setChapter(3)
                chapterTitleSprite.showTitle(shouldLowerVolumeForCurrentTheme: false) { [unowned self] in
                    sendChatArray(items: [
                        ChatItem(profile: .blanktrainer, startNewChat: false, chat: "\n\nMarlin has left the party.", handler: nil)
                    ]) { [unowned self] in
                        AudioManager.shared.raiseVolume(for: AudioManager.shared.currentTheme, fadeDuration: musicFadeDuration)

                        handleDialogueCompletion(level: level, completion: completion)
                    }
                }
            }
        case 319:
            if statueTapped {
                sendChatArray(shouldSkipDim: true, items: dialogueStatue0.getDialogue()) { [unowned self] in
                    handleDialogueCompletion(level: level, completion: completion)
                }
            }
            else {
                sendChatArray(items: [
                    ChatItem(profile: .hero, imgPos: .left, chat: "🎵 Lonely. I am so lonely... 🎶")
                ]) { [unowned self] in
                    handleDialogueCompletion(level: level, completion: completion)
                }
            }
        case 339:
            if statueTapped {
                sendChatArray(shouldSkipDim: true, items: dialogueStatue1.getDialogue()) { [unowned self] in
                    handleDialogueCompletion(level: level, completion: completion)
                }
            }
            else {
                handleDialogueCompletion(level: level, completion: completion)
            }
        case 351:
            if statueTapped {
                sendChatArray(shouldSkipDim: true, items: dialogueStatue2.getDialogue()) { [unowned self] in
                    handleDialogueCompletion(level: level, completion: completion)
                }
            }
            else {
                sendChatArray(items: [
                    ChatItem(profile: .hero, imgPos: .left, chat: "\(FireIceTheme.isFire ? "Sand?? What the heck is sand?!?" : "Snow?? What the heck is snow?!?") Ahhh, I'm FREAKING OUT!!!"),
                    ChatItem(profile: .hero, imgPos: .left, chat: "Maybe that statue can help me...")
                ]) { [unowned self] in
                    handleDialogueCompletion(level: level, completion: completion)
                }
            }
        case 376:
            if statueTapped {
                sendChatArray(shouldSkipDim: true, items: dialogueStatue3.getDialogue()) { [unowned self] in
                    handleDialogueCompletion(level: level, completion: completion)
                }
            }
            else {
                handleDialogueCompletion(level: level, completion: completion)
            }
//        case 314:
//            delegate?.inbetweenRealmEnter(levelInt: level)
//            
//            sendChatArray(shouldSkipDim: true, items: [
//                ChatItem(profile: .villain, chat: "So... you're a princess."),
//                ChatItem(profile: .princess, imgPos: .left, chat: "You got that right, mister! When my mom and dad find out what you've done, you'll be sorry!"),
//                ChatItem(profile: .villain, chat: "Ohh? Do tell what they'll do."),
//                ChatItem(profile: .princess, imgPos: .left, chat: "They'll.. THEY'LL.. They'll give you a good yelling!"),
//                ChatItem(profile: .villain, chat: "Well I can yell back. I have an award for being the yellingest yeller in Yellowstone, WY."),
//                ChatItem(profile: .princess, imgPos: .left, chat: "What.. is that supposed to scare me or something?"),
//                ChatItem(profile: .villain, chat: "You tell me, young princess. Does it scare you? Does it make you cower in your britches?"),
//                ChatItem(profile: .princess, imgPos: .left, chat: "Who you callin' a britch?! First of all, I'm not afraid of you. Second, I can yell louder than you can! AAAAAHHHHH!!!"),
//                ChatItem(profile: .villain, chat: "Shriek. I'm shaking in my Louboutin boots."),
//                ChatItem(profile: .princess, imgPos: .left, chat: "You better be scared. For when I get free, I'm gonna pound you into the ground!"),
//                ChatItem(profile: .villain, chat: "Slaaaaaay! 💅🏼✨")
//            ]) { [unowned self] in
//                guard let delegate = delegate else {
//                    //Just in case delegate is false, which it shouldn't be!!!
//                    handleDialogueCompletion(level: level, completion: completion)
//                    return
//                }
//                
//                delegate.inbetweenRealmExit { [unowned self] in
//                    handleDialogueCompletion(level: level, completion: completion)
//                }
//            }
        case 401:
            chapterTitleSprite.setChapter(4)
            chapterTitleSprite.showTitle { [unowned self] in
                handleDialogueCompletion(level: level, completion: completion)
            }
        default:
            isChatting = false
            completion?(nil)
        }
    }//end playDialogue(level:statueTapped:completion:)
}//end ChatEngine
