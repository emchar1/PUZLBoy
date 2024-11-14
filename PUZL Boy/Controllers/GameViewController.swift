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
            
//            print("Monitor update - hasInternet: \(self.hasInternet)")
        }
        monitor.start(queue: DispatchQueue(label: "Monitor"))

        
        
        
        // FIXME: - DEBUG: DEFINITELY COMMENT THESE OUT BEFORE SHIPPING FINAL PRODUCT!!!
        skView.showsFPS = true
        skView.showsNodeCount = true
        
//        // FIXME: - DEBUG: Go straight to Cutscene. DELETE BEFORE SHIPPING!
//        let cutsceneTest = CutsceneOldFriends()
//        cutsceneTest.animateScene(completion: nil)
//        skView.ignoresSiblingOrder = true
//        skView.presentScene(cutsceneTest)
//        view = skView
        
//        // FIXME: - DEBUG: Final Cutscene TEST
//        FIRManager.initializeFirestore() { [weak self] saveStateMode, error in
//            let endingFake = EndingFakeScene(size: K.ScreenDimensions.size)
//            self?.skView.presentScene(endingFake)
//
//            endingFake.animateScene {
//                let catwalk = CatwalkScene(size: K.ScreenDimensions.size)
//                self?.skView.presentScene(catwalk)
//            }
//
//            self?.skView.ignoresSiblingOrder = true
//            self?.view = self?.skView
//        }
        
        
        
        skView.ignoresSiblingOrder = true
        skView.presentScene(authorizationRequestScene)
        view = skView

        print("Testing device info: \(UIDevice.modelInfo), UI aspect ratio: \(K.ScreenDimensions.sizeUI.height / K.ScreenDimensions.sizeUI.width)")
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
                                    self.presentTitleScene(shouldInitializeAsHero: false)
                                                                        
                                    //BUGFIX# 240616E01 scarymusicbox may sometimes play if you skip intro at the moment it's just about to play.
                                    cutsceneIntro?.stopAllMusic(fadeDuration: 1)

                                    cutsceneIntro = nil
                                }
                            }
                        }
                        else {
                            launchScene?.animateTransition(animationSequence: .jump) { _ in
                                self.presentTitleScene(shouldInitializeAsHero: true)
                                
                                launchScene = nil
                            }
                        }
                                                
                        self.levelLoaded = true
                    }
                }
            }
        }//end GameCenterManager.shared.getUser()
    }
    
    private func presentTitleScene(shouldInitializeAsHero: Bool) {
        let titleScene = TitleScene(size: K.ScreenDimensions.size, shouldInitializeAsHero: shouldInitializeAsHero)
        titleScene.titleSceneDelegate = self
        
        skView.presentScene(titleScene)
    }
}


// MARK: - TitleSceneDelegate

extension GameViewController: TitleSceneDelegate {
    func didTapStart(levelSelectNewLevel: Int?) {
        let gameScene = GameScene(size: K.ScreenDimensions.size, hasInternet: hasInternet, levelSelectNewLevel: levelSelectNewLevel)
        gameScene.gameSceneDelegate = self
        
        skView.presentScene(gameScene, transition: SKTransition.fade(with: .white, duration: 1.0))

        //Commenting this out 10/3/23. I can keep the monitor active 24/7 right??
//        monitor.cancel()
        
        UserDefaults.standard.set(true, forKey: K.UserDefaults.hasPlayedBefore)
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
        let titleScene = TitleScene(size: K.ScreenDimensions.size, shouldInitializeAsHero: false)
        titleScene.titleSceneDelegate = self
        
        //NEEDS to have a transition, otherwise the state won't save, trust me.
        skView.presentScene(titleScene, transition: SKTransition.fade(with: .white, duration: 0))
    }
}


// MARK: - GameSceneDelegate

extension GameViewController: GameSceneDelegate {
    func confirmQuitTapped() {
        let titleScene = TitleScene(size: K.ScreenDimensions.size, shouldInitializeAsHero: false)
        titleScene.titleSceneDelegate = self
        
        //NEEDS to have a transition, otherwise the state won't save, trust me. 2/7/24 Tried it w/o the transition and it still works??? Must have to do with the cleanupScene() function I wrote in GameScene.swift
        skView.presentScene(titleScene, transition: SKTransition.fade(with: .white, duration: 0))
    }
    
    func presentCatwalkScene() {
        let endingFakeScene = EndingFakeScene(size: K.ScreenDimensions.size)
        skView.presentScene(endingFakeScene, transition: SKTransition.fade(with: .white, duration: 0))
        
        endingFakeScene.animateScene { [weak self] in
            let catwalkScene = CatwalkScene(size: K.ScreenDimensions.size)
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
