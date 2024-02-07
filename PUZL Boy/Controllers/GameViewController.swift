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
        
        var launchScene: LaunchScene? = LaunchScene(size: K.ScreenDimensions.size)
        var cutsceneIntro: CutsceneIntro?
        
        monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                self.hasInternet = true
            }
            else {
                self.hasInternet = false
            }
        }
        monitor.start(queue: DispatchQueue(label: "Monitor"))

        // FIXME: - DEFINITELY COMMENT THESE OUT BEFORE SHIPPING FINAL PRODUCT!!!
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        skView.ignoresSiblingOrder = true
        skView.presentScene(launchScene)
        view = skView

        AdMobManager.shared.superVC = self
        AdMobManager.shared.createAndLoadInterstitial()
        AdMobManager.shared.createAndLoadRewarded()

        //Call this once, before calling LevelBuilder.getLevels().
        FIRManager.enableDBPersistence
        
        NotificationCenter.default.addObserver(self, selector: #selector(sendEmail), name: .showMailCompose, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(shareURL), name: .shareURL, object: nil)

        GameCenterManager.shared.viewController = self
        GameCenterManager.shared.getUser { user in
            //Ensures everything below the guard statement only gets called ONCE!
            guard !self.levelLoaded else { return }
            
            //Should call LevelBuilder.getLevels BEFORE calling FIRManager.initializeSaveStateFirestoreRecords
            LevelBuilder.getLevels {
                FIRManager.initializeFirestore(user: user) { saveStateModel, error in
                    //No error handling...
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + LoadingSprite.loadingDuration) {
                        if !UserDefaults.standard.bool(forKey: K.UserDefaults.shouldSkipIntro) {
                            cutsceneIntro = CutsceneIntro(size: K.ScreenDimensions.size, xOffsetsArray: nil)

                            launchScene?.animateTransition(animationSequence: .running) { xOffsetsArray in
                                guard let xOffsetsArray = xOffsetsArray else { return }
                                
                                cutsceneIntro?.parallaxManager.setxPositions(xOffsetsArray: xOffsetsArray)
                                self.skView.presentScene(cutsceneIntro)
                                launchScene = nil
                                
                                cutsceneIntro?.animateScene() {
                                    self.presentTitleScene()
                                    
                                    cutsceneIntro = nil
                                }
                            }
                        }
                        else {
                            launchScene?.animateTransition(animationSequence: .jump) { _ in
                                self.presentTitleScene()
                                
                                launchScene = nil
                            }
                        }
                                                
                        self.levelLoaded = true
                    }
                }
            }
        }//end GameCenterManager.shared.getUser()
        
        print("Testing device info: \(UIDevice.modelInfo), UI aspect ratio: \(K.ScreenDimensions.sizeUI.height / K.ScreenDimensions.sizeUI.width)")
    }//end viewDidLoad()
    
    private func presentTitleScene() {
        let titleScene = TitleScene(size: K.ScreenDimensions.size)
        titleScene.titleSceneDelegate = self
        
        skView.presentScene(titleScene)
    }
    
    //Disable shake to reset for now...
//    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
//        if motion == .motionShake {
//            guard let skView = view as? SKView, let scene = skView.scene as? GameScene else { return }
//            
//            scene.shake()
//        }
//    }
}


// MARK: - TitleSceneDelegate

extension GameViewController: TitleSceneDelegate {
    func didTapStart(levelSelectNewLevel: Int?) {
        let gameScene = GameScene(size: K.ScreenDimensions.size, hasInternet: hasInternet, levelSelectNewLevel: levelSelectNewLevel)
        gameScene.gameSceneDelegate = self
        
        skView.presentScene(gameScene, transition: SKTransition.fade(with: .white, duration: 1.0))

        //Commenting this out 10/3/23. I can keep the monitor active 24/7 right??
//        monitor.cancel()
    }
    
    func didTapLevelSelect() {
        //Implementation NOT needed
    }
    
    // TODO: - CreditsScene
    func didTapCredits() {
        let creditsScene = CreditsScene(size: K.ScreenDimensions.size)
        creditsScene.creditsSceneDelegate = self
        
        skView.presentScene(creditsScene, transition: SKTransition.doorsOpenVertical(withDuration: 1.0))
    }
}


// MARK: - CreditsSceneDelegate

extension GameViewController: CreditsSceneDelegate {
    func goBackTapped() {
        let titleScene = TitleScene(size: K.ScreenDimensions.size)
        titleScene.titleSceneDelegate = self
        
        //NEEDS to have a transition, otherwise the state won't save, trust me.
        skView.presentScene(titleScene, transition: SKTransition.fade(with: .white, duration: 0))
    }
}


// MARK: - GameSceneDelegate

extension GameViewController: GameSceneDelegate {
    func confirmQuitTapped() {
        let titleScene = TitleScene(size: K.ScreenDimensions.size)
        titleScene.titleSceneDelegate = self
        
        //NEEDS to have a transition, otherwise the state won't save, trust me.
        skView.presentScene(titleScene, transition: SKTransition.fade(with: .white, duration: 0))
    }
    
    func showChatDialogueCutscene(level: Int) {
        let gameScene = GameScene(size: K.ScreenDimensions.size, hasInternet: hasInternet, levelSelectNewLevel: level)
        gameScene.gameSceneDelegate = self
        gameScene.chatEngine.setDialoguePlayed(level: level, to: true) //IMPORTANT: MUST do this for levels with a chat dialogue cutscene!

        let cutscene = CutsceneOldFriends(size: K.ScreenDimensions.size)
        skView.presentScene(cutscene, transition: SKTransition.fade(with: .white, duration: 1.0))
        cutscene.animateScene() { [unowned self] in
            skView.presentScene(gameScene, transition: SKTransition.fade(with: .white, duration: 1.0))
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
        deviceStats += "UID: \(FIRManager.user?.uid ?? "N/A")"

        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setToRecipients(["puzlboygame@gmail.com"])
        mail.setSubject("In-Game Feedback")
        mail.setMessageBody("<br><br><br><br>\(deviceStats)", isHTML: true)
        
        present(mail, animated: true)
    }
}


// MARK: - Share URL

extension GameViewController {
    @objc private func shareURL(_ sender: Any) {
        let productURL = "https://www.puzlboy.com"
        let activityViewController = UIActivityViewController(activityItems: [productURL], applicationActivities: nil)
        
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
