//
//  GameViewController.swift
//  PUZL Boy
//
//  Created by Eddie Char on 9/27/22.
//

import UIKit
import SpriteKit
import GameplayKit
import FirebaseAuth
import MessageUI
import Network

class GameViewController: UIViewController {
    
    // MARK: - Properties
    
    override var prefersStatusBarHidden: Bool { return true }
    private var levelLoaded = false
    private var hasInternet = false
    private var monitor: NWPathMonitor!
    private let skView = SKView()
    private let fakeEnding: (title: String, message: String) = ("CONGRATULATIONS", "You have successfully completed \(Level.finalLevel) levels of mind-bending puzzles. But it's not over just yet...\n\nAs PUZL Boy and the Elders make their way to Earth's core, they must confront Magmoor in a final showdown to rescue their friends, Marlin and Princess Olivia, and prevent the Mad Mystic from unleashing the apocalyptic Age of Ruin!\n\nAre you ready to face the ultimate challenge and save the universe from total destruction?")
    
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let authorizationRequestScene = AuthorizationRequestScene(size: K.ScreenDimensions.size, userInterfaceStyle: traitCollection.userInterfaceStyle)
        authorizationRequestScene.sceneDelegate = self
        
        monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                self.hasInternet = true
            }
            else {
                self.hasInternet = false
            }
        }
        monitor.start(queue: DispatchQueue(label: "com.5play-apps.PUZL-Boy.MonitorQueue"))
        
        
        
        
        // FIXME: - DEBUG: DEFINITELY COMMENT THESE OUT BEFORE SHIPPING FINAL PRODUCT!!!
        skView.showsFPS = true
        skView.showsNodeCount = true
        
//        // FIXME: - DEBUG: Final Cutscene TEST
//        NotificationCenter.default.addObserver(self, selector: #selector(didWinGame), name: .completeGameDidWin, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(didLoseGame), name: .completeGameDidLose, object: nil)
//        
//        LevelBuilder.getLevels {
//            FIRManager.initializeFirestore() { [weak self] saveStateMode, error in
//                guard let self = self else { return }
//                
//                
//                // ver. 1 - ending fake scene to catwalk scene
//                let endingFakeScene = EndingFakeScene(size: K.ScreenDimensions.size, titleText: fakeEnding.title, messageText: fakeEnding.message)
//                skView.presentScene(endingFakeScene)
//                skView.ignoresSiblingOrder = true
//                view = skView
//                endingFakeScene.animateScene(music: "bossbattle2") { [weak self] in
//                    guard let self = self else { return }
//                    let catwalkScene = CatwalkScene(size: K.ScreenDimensions.size)
//                    catwalkScene.catwalkDelegate = self
//                    self.skView.presentScene(catwalkScene)
//                }
//
//
//                // ver. 2 - catwalk scene
//                let catwalkScene = CatwalkScene(startAtTiki: true)
//                catwalkScene.catwalkDelegate = self
//                skView.presentScene(catwalkScene)
//                skView.ignoresSiblingOrder = true
//                view = skView
//
//
//                // ver. 3 - coming soon scene
//                let comingSoonScene = ComingSoonScene(size: K.ScreenDimensions.size)
//                comingSoonScene.comingSoonDelegate = self
//                comingSoonScene.animateScene()
//                skView.presentScene(comingSoonScene)
//                skView.ignoresSiblingOrder = true
//                view = skView
//                
//                
//                // ver. 4 - final battle scene
//                let finalBattleScene = FinalBattleScene(size: K.ScreenDimensions.size)
//                finalBattleScene.animateScene()
//                skView.presentScene(finalBattleScene)
//                skView.ignoresSiblingOrder = true
//                view = skView
//                
//
//                // ver. 5 - pre battle scene
//                let preBattleCutscene = PreBattleCutscene(size: K.ScreenDimensions.size)
//                preBattleCutscene.animateScene()
//                preBattleCutscene.preBattleDelegate = self
//                skView.presentScene(preBattleCutscene)
//                skView.ignoresSiblingOrder = true
//                view = skView
//                
//                
//            } //end initializeFirestore()
//        } //end getLevels
        
        
        
        
        skView.ignoresSiblingOrder = true
        skView.presentScene(authorizationRequestScene)
        view = skView

        print("Testing device info: \(UIDevice.modelInfo), UI aspect ratio: \(K.ScreenDimensions.sizeUI.height / K.ScreenDimensions.sizeUI.width)")
    }
    
    deinit {
        print("GameViewController deinit!!!")
        
        NotificationCenter.default.removeObserver(self)
    }
    
    
}


// MARK: - AuthorizationRequestSceneDelegate

extension GameViewController: AuthorizationRequestSceneDelegate {
    func didAuthorizeRequests(shouldFadeIn: Bool) {
        var launchScene: LaunchScene? = LaunchScene(size: K.ScreenDimensions.size)
        var cutsceneIntro: CutsceneIntro?
                        
        if let launchScene = launchScene {
            launchScene.animateSprites()
            skView.presentScene(launchScene, transition: .crossFade(withDuration: shouldFadeIn ? 2 : 0.5))
        }

        AdMobManager.shared.superVC = self
        AdMobManager.shared.createAndLoadInterstitial()
        AdMobManager.shared.createAndLoadRewarded()

        //Call this once, before calling LevelBuilder.getLevels().
        FIRManager.enableDBPersistence
        
        print("UserDefaults.standard.firebaseUID: \(UserDefaults.standard.string(forKey: K.UserDefaults.firebaseUID) ?? "N/A")")
        
        NotificationCenter.default.addObserver(self, selector: #selector(sendEmail), name: .showMailCompose, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(shareURL), name: .shareURL, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didWinGame), name: .completeGameDidWin, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didLoseGame), name: .completeGameDidLose, object: nil)
        
        GameCenterManager.shared.viewController = self

        //BUGFIX #241015E01 - If not logged into game center and story intro is enabled, when asking for login info, the game crashes when attempting to add the LetterboxSprite to parent, which I think Letterbox is added during the login prompt, then added again(???) causing the multiple parent node bug. I noticed this when updating to Xcode 16, but not sure if it always existed in prior Xcode version 15.2. Maybe try calling this in the onboarding screen instead of after onboarding screen.
        GameCenterManager.shared.getUser { user in
            //Ensures everything below the guard statement only gets called ONCE!
            guard !self.levelLoaded else { return }
            
            //MUST set this here before initializing Firestore db!!!
            FIRManager.user = user
            
            //Set UserDefaults.standard.firebaseUID if it hasn't been set yet, or if for some reason it differs from its current value.
            if let uid = FIRManager.uid, uid != UserDefaults.standard.string(forKey: K.UserDefaults.firebaseUID) {
                UserDefaults.standard.set(uid, forKey: K.UserDefaults.firebaseUID)

                print("UserDefaults.standard.firebaseUID set! UID: \(uid)")
            }
            
            //Should call LevelBuilder.getLevels BEFORE calling FIRManager.initializeSaveStateFirestoreRecords
            LevelBuilder.getLevels {
                FIRManager.initializeFirestore() { saveStateModel, error in
                    //No error handling...
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + LoadingSprite.loadingDuration) {
                        if !UserDefaults.standard.bool(forKey: K.UserDefaults.shouldSkipIntro) {
                            
                            //Initialize cutsceneIntro here to give it time to load everything before launchScene finishes animating the transition!
                            cutsceneIntro = CutsceneIntro()

                            launchScene?.animateTransition(animationSequence: .running) { xOffsetsArray in
                                guard let xOffsetsArray = xOffsetsArray else { return }
                                
                                cutsceneIntro?.parallaxManager.setxPositions(xOffsetsArray: xOffsetsArray)
                                self.skView.presentScene(cutsceneIntro)
                                launchScene = nil
                                
                                cutsceneIntro?.animateScene() {
                                    self.presentTitleScene(shouldInitializeAsHero: false, transition: nil)
                                                                        
                                    //BUGFIX# 240616E01 scarymusicbox may sometimes play if you skip intro at the moment it's just about to play.
                                    cutsceneIntro?.stopAllMusic(fadeDuration: 1)

                                    cutsceneIntro = nil
                                }
                            }
                        }
                        else {
                            launchScene?.animateTransition(animationSequence: .jump) { _ in
                                self.presentTitleScene(shouldInitializeAsHero: true, transition: nil)
                                
                                launchScene = nil
                            }
                        }
                                                
                        self.levelLoaded = true
                    } //end DispatchQueue.main.asyncAfter()
                } //end FIRManager.initializeFirestore()
            } //end LevelBuilder.getLevels()
        }//end GameCenterManager.shared.getUser()
    }
    
    private func presentTitleScene(shouldInitializeAsHero: Bool, transition: SKTransition?) {
        let titleScene = TitleScene(size: K.ScreenDimensions.size, shouldInitializeAsHero: shouldInitializeAsHero)
        titleScene.titleSceneDelegate = self
        
        if let transition = transition {
            skView.presentScene(titleScene, transition: transition)
        }
        else {
            skView.presentScene(titleScene)
        }
    }
}


// MARK: - TitleSceneDelegate

extension GameViewController: TitleSceneDelegate {
    func didTapStart(levelSelectNewLevel: Int?) {
        // TODO: - Goes right to catwalk if Start Game and level is > 500.
        if levelSelectNewLevel == nil && (FIRManager.saveStateModel != nil && FIRManager.saveStateModel!.newLevel > Level.finalLevel) {
            let catwalkScene = CatwalkScene(size: K.ScreenDimensions.size)
            catwalkScene.catwalkDelegate = self
            
            skView.presentScene(catwalkScene, transition: SKTransition.fade(with: .white, duration: 3.0))
        }
        else {
            let gameScene = GameScene(size: K.ScreenDimensions.size, hasInternet: hasInternet, levelSelectNewLevel: levelSelectNewLevel)
            gameScene.gameSceneDelegate = self
            
            skView.presentScene(gameScene, transition: SKTransition.fade(with: .white, duration: 1.0))
            
            //Commenting this out 10/3/23. I can keep the monitor active 24/7 right??
//            monitor.cancel()
        }
        
        UserDefaults.standard.set(true, forKey: K.UserDefaults.hasPlayedBefore)
        
        
        
        
//        // FIXME: - For use with build# 1.28(30). (Normally, use above, commented out code.)
//        let catwalkScene = CatwalkScene(size: K.ScreenDimensions.size)
//        catwalkScene.catwalkDelegate = self
//        skView.presentScene(catwalkScene, transition: SKTransition.fade(with: .white, duration: 3.0))
//        let finalBattleScene = FinalBattleScene(size: K.ScreenDimensions.size)
//        finalBattleScene.animateScene()
//        skView.presentScene(finalBattleScene, transition: SKTransition.fade(with: .white, duration: 3.0))
    }
    
    func didTapLevelSelect() {
        //Implementation NOT needed
    }
    
    func didTapCredits() {
        let creditsScene = CreditsScene(size: K.ScreenDimensions.size)
        creditsScene.creditsSceneDelegate = self
        
        skView.presentScene(creditsScene, transition: SKTransition.doorsOpenVertical(withDuration: 1.0))
    }
}


// MARK: - CreditsSceneDelegate

extension GameViewController: CreditsSceneDelegate {
    func goBackTapped() {
        //NEEDS to have a transition, otherwise the state won't save, trust me.
        presentTitleScene(shouldInitializeAsHero: false, transition: SKTransition.fade(with: .white, duration: 0))
    }
}


// MARK: - GameSceneDelegate

extension GameViewController: GameSceneDelegate {
    func confirmQuitTapped() {
        //NEEDS to have a transition, otherwise the state won't save, trust me. 2/7/24 Tried it w/o the transition and it still works??? Must have to do with the cleanupScene() function I wrote in GameScene.swift
        presentTitleScene(shouldInitializeAsHero: false, transition: SKTransition.fade(with: .white, duration: 0))
    }
    
    func presentCatwalkScene() {
        let endingFakeScene = EndingFakeScene(size: K.ScreenDimensions.size, titleText: fakeEnding.title, messageText: fakeEnding.message)
        skView.presentScene(endingFakeScene, transition: SKTransition.fade(with: .white, duration: 0))
        
        endingFakeScene.animateScene(music: "bossbattle2") { [weak self] in
            let catwalkScene = CatwalkScene(size: K.ScreenDimensions.size)
            catwalkScene.catwalkDelegate = self
            
            self?.skView.presentScene(catwalkScene, transition: SKTransition.fade(with: .black, duration: 0))
        }
    }
    
    func presentChatDialogueCutscene(level: Int, cutscene: Cutscene) {
        let gameScene = GameScene(size: K.ScreenDimensions.size, hasInternet: hasInternet, levelSelectNewLevel: level)
        gameScene.gameSceneDelegate = self
        gameScene.chatEngine.setDialogueWithCutscene(level: level, to: true) //IMPORTANT: MUST do this for levels with a chat dialogue cutscene!
        
        skView.presentScene(cutscene, transition: SKTransition.fade(with: .white, duration: 2.0))
        
        cutscene.animateScene() { [weak self] in
            self?.skView.presentScene(gameScene, transition: SKTransition.fade(with: .white, duration: 1.0))
        }
    }
}


// MARK: - CatwalkSceneDelegate

extension GameViewController: CatwalkSceneDelegate {
    func catwalkSceneDidFinish(_ cutscene: CatwalkScene, didStartAtTiki: Bool) {
//        let comingSoonScene = ComingSoonScene(size: K.ScreenDimensions.size)
//        comingSoonScene.comingSoonDelegate = self
//        comingSoonScene.animateScene()
//        skView.presentScene(comingSoonScene, transition: SKTransition.fade(with: .black, duration: 0.2))
        
        
        
        
        
        if didStartAtTiki {
            let finalBattleScene = FinalBattleScene(size: K.ScreenDimensions.size)
            finalBattleScene.animateScene()
            skView.presentScene(finalBattleScene, transition: SKTransition.fade(with: .black, duration: 3))
        }
        else {
            let preBattleCutscene = PreBattleCutscene(size: K.ScreenDimensions.size)
            preBattleCutscene.animateScene()
            preBattleCutscene.preBattleDelegate = self
            skView.presentScene(preBattleCutscene, transition: SKTransition.fade(with: .black, duration: 3))
        }
        
        
        
        
        
//        // TODO: - Save n shit
//        FIRManager.resetAgeOfRuinProperties(ageOfRuinIsActive: true)
//        
//        presentTitleScene(shouldInitializeAsHero: false, transition: SKTransition.fade(with: .white, duration: 0))
    }
}


// MARK: - PreBattleCutsceneDelegate

extension GameViewController: PreBattleCutsceneDelegate {
    func preBattleCutsceneDidFinish(_ cutscene: PreBattleCutscene) {
        let finalBattleScene = FinalBattleScene(size: K.ScreenDimensions.size)
        finalBattleScene.animateScene()
        skView.presentScene(finalBattleScene, transition: SKTransition.fade(with: .black, duration: 0))
    }
}


// MARK: - ComingSoonSceneDelegate

extension GameViewController: ComingSoonSceneDelegate {
    func comingSoonSceneDidFinish() {
        FIRManager.resetAgeOfRuinProperties(ageOfRuinIsActive: true)
        
        presentTitleScene(shouldInitializeAsHero: false, transition: SKTransition.fade(with: .white, duration: 0))
    }
}


// MARK: - Notification Observer Pattern Executer (NOPE)

extension GameViewController {
    @objc private func didWinGame(_ sender: Any) {
        didCompleteGameObjcHelper(didWin: true)
    }
    
    @objc private func didLoseGame(_ sender: Any) {
        didCompleteGameObjcHelper(didWin: false)
    }
    
    // FIXME: - For use with build# 1.28(30).
    private func didCompleteGameObjcHelper(didWin: Bool) {
        guard let finalBattleScene = skView.scene as? FinalBattleScene else { return }
        
        finalBattleScene.cleanupScene(didWin: didWin) { [weak self] in
            guard let self = self else { return }
            
            let finalBattle2WinScene = FinalBattle2WinLoseScene(size: K.ScreenDimensions.size)
            finalBattle2WinScene.winLoseDelegate = self
            finalBattle2WinScene.animateScene(didWin: didWin)
            
            skView.presentScene(finalBattle2WinScene, transition: SKTransition.fade(with: .black, duration: 0))
        }
    }
}


// MARK: - FinalBattle2WinLoseSceneDelegate {

// FIXME: - For use with build# 1.28(30).
extension GameViewController: FinalBattle2WinLoseSceneDelegate {
    func didTapTryAgain() {
//        let finalBattleScene = FinalBattleScene(size: K.ScreenDimensions.size)
//        finalBattleScene.animateScene()
//        skView.presentScene(finalBattleScene, transition: SKTransition.fade(with: .black, duration: 3))
        
        
        
        let catwalkScene = CatwalkScene(startAtTiki: true)
        catwalkScene.catwalkDelegate = self
        skView.presentScene(catwalkScene)
    }
    
    func didTapQuit() {
        presentTitleScene(shouldInitializeAsHero: false, transition: SKTransition.fade(with: .white, duration: 0))
    }
}


// MARK: - MFMailComposeViewControllerDelegate

extension GameViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if result == .sent {
            UserDefaults.standard.set(Date(), forKey: K.UserDefaults.feedbackSubmitDate)
            NotificationCenter.default.post(name: .didSendEmailFeedback, object: nil)
        }
        
        controller.dismiss(animated: true)
    }
    
    @objc private func sendEmail(_ sender: Any) {
        guard MFMailComposeViewController.canSendMail() else { return }
        
        let os = ProcessInfo.processInfo.operatingSystemVersion
        
        var deviceStats = "PUZL Boy version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A") "
        deviceStats += "(\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "N/A"))<br>"
        deviceStats += "Device: \(UIDevice.modelInfo.name)<br>"
        deviceStats += "OS version: \(os.majorVersion).\(os.minorVersion).\(os.patchVersion)<br>"
        deviceStats += "Language: \(Locale.current.languageCode ?? "N/A")<br>"
        deviceStats += "UID: \(FIRManager.uid ?? "N/A")"

        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setToRecipients(["puzlboy@5playapps.com"])
        mail.setSubject("In-Game Feedback")
        mail.setMessageBody("<br><br><br><br>\(deviceStats)", isHTML: true)
        
        present(mail, animated: true)
    }
}


// MARK: - Share URL

extension GameViewController {
    @objc private func shareURL(_ sender: Any) {
        let textMessage = "Hey! Have you checked this game out yet? PUZL Boy - it's super fun! https://5playapps.com"
        let activityViewController = UIActivityViewController(activityItems: [textMessage], applicationActivities: nil)
        
        present(activityViewController, animated: true)
        
        //IMPORTANT!! Required for iPad, else program crashes
        if let popOver = activityViewController.popoverPresentationController {
            popOver.sourceView = self.view
            popOver.sourceRect = CGRect(
                origin: CGPoint(x: K.ScreenDimensions.sizeUI.width / 2 + 140, y: K.ScreenDimensions.sizeUI.height / 2 + 140),
                size: .zero)
        }
    }
}
