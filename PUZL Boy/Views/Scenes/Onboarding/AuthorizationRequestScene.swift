//
//  AuthorizationRequestScene.swift
//  PUZL Boy
//
//  Created by Eddie Char on 5/24/24.
//

import SpriteKit
import UserNotifications
import AppTrackingTransparency

protocol AuthorizationRequestSceneDelegate: AnyObject {
    func didAuthorizeRequests(shouldFadeIn: Bool)
}

class AuthorizationRequestScene: SKScene {

    // MARK: - Properties

    private var isDarkMode: Bool
    
    private var notificationsMessage: AuthorizationSprite?
    private var idfaMessage: AuthorizationSprite?
    private var thanksMessage: AuthorizationSprite?
    
    weak var sceneDelegate: AuthorizationRequestSceneDelegate?
    

    // MARK: - Initialization
    
    init(size: CGSize, isDarkMode: Bool) {
        self.isDarkMode = isDarkMode

        super.init(size: size)
        
        setupSprites()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSprites() {
        backgroundColor = isDarkMode ? .black : .white
        
        UNUserNotificationCenter.current().getNotificationSettings { [unowned self] settings in
            if settings.authorizationStatus == .notDetermined {
                notificationsMessage = AuthorizationSprite(
                    title: "Notifications",
                    message: "This game sends notifications to remind you of news and important updates. To enable tap OK, then Allow on the following pop-up window.")

                notificationsMessage!.delegate = self
            }

            if #available(iOS 14, *) {
                if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
                    idfaMessage = AuthorizationSprite(
                        title: "Personalized Ads",
                        message: "This app can also deliver personalized ads to you. To enable this feature tap OK, then Allow on the next window.")
                    
                    idfaMessage!.delegate = self
                }
            } else {
                // Fallback on earlier versions
            }
            
            if notificationsMessage != nil || idfaMessage != nil {
                backgroundColor = .black
                
                thanksMessage = AuthorizationSprite(
                    title: "Enjoy!",
                    message: "Thank you for your responses! Now please enjoy PUZL Boy, brought to you by 5Play Apps.")
                
                thanksMessage!.delegate = self

            }
            
            //Need to call this here to guarantee UserNotifications completion is called.
            layoutSprites()
        }
    }
    
    private func layoutSprites() {
        if let notificationsMessage = notificationsMessage {
            addChild(notificationsMessage)

            notificationsMessage.animateShow { }
        }
        
        if let idfaMessage = idfaMessage {
            addChild(idfaMessage)
            
            if notificationsMessage == nil {
                idfaMessage.animateShow { }
            }
        }
        
        if let thanksMessage = thanksMessage {
            addChild(thanksMessage)
        }
        
        if thanksMessage == nil {
            sceneDelegate?.didAuthorizeRequests(shouldFadeIn: false)
        }
    }
    
    
    // MARK: - Touch Functions
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }

        notificationsMessage?.touchDown(in: location)
        idfaMessage?.touchDown(in: location)
        thanksMessage?.touchDown(in: location)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }

        notificationsMessage?.didTapButton(in: location)
        notificationsMessage?.touchUp()
        
        idfaMessage?.didTapButton(in: location)
        idfaMessage?.touchUp()
        
        thanksMessage?.didTapButton(in: location)
        thanksMessage?.touchUp()
    }
    
}


// MARK: - ConfirmSpriteDelegate

extension AuthorizationRequestScene: ConfirmSpriteDelegate {
    func didTapConfirm(_ confirmSprite: ConfirmSprite) {
        switch confirmSprite {
        case let authorizationSprite where authorizationSprite == notificationsMessage:
            authorizationSprite.animateHide { [unowned self] in
                LifeSpawnerModel.shared.requestNotifications()
                
                if let idfaMessage = idfaMessage {
                    idfaMessage.animateShow { }
                }
                else {
                    thanksMessage?.animateShow { }
                }
            }
        case let authorizationSprite where authorizationSprite == idfaMessage:
            authorizationSprite.animateHide { [unowned self] in
                if #available(iOS 14, *) {
                    AdMobManager.shared.requestIDFAPermission()
                    
                    thanksMessage?.animateShow { }
                } else {
                    // Fallback on earlier versions
                }
            }
        case let authorizationSprite where authorizationSprite == thanksMessage:
            authorizationSprite.animateHide { [unowned self] in
                sceneDelegate?.didAuthorizeRequests(shouldFadeIn: true)
            }
        default:
            break
        }
    }
    
    func didTapCancel(_ confirmSprite: ConfirmSprite) {
        print("NotificationsRequestScene::ConfirmSprite.cancel() - this should't execute!")
    }
    
}
