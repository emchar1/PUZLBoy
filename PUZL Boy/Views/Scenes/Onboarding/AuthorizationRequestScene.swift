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
    
    private let edgeConstraintConstant: CGFloat = (UIDevice.isiPad ? 160 : 40) * K.ScreenDimensions.size.height / K.ScreenDimensions.sizeUI.height
    private var userInterfaceStyle: UIUserInterfaceStyle
    private var logoSprite: SKSpriteNode?
    
    private var notificationsMessage: AuthorizationSprite?
    private var idfaMessage: AuthorizationSprite?
    private var thanksMessage: AuthorizationSprite?
    
    weak var sceneDelegate: AuthorizationRequestSceneDelegate?
    

    // MARK: - Initialization
    
    init(size: CGSize, userInterfaceStyle: UIUserInterfaceStyle) {
        self.userInterfaceStyle = userInterfaceStyle

        super.init(size: size)
        
        setupSprites()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSprites() {
        backgroundColor = userInterfaceStyle == .dark ? .black : .white
        
        let logoWidth = K.ScreenDimensions.size.width - 2 * edgeConstraintConstant
        
        if let image = UIImage(named: UIDevice.isiPad ? "5PlayApps" : "5PlayAppsSM",
                               in: nil,
                               compatibleWith: UITraitCollection(userInterfaceStyle: userInterfaceStyle)) {
            
            logoSprite = SKSpriteNode(texture: SKTexture(image: image))
            logoSprite!.position = CGPoint(x: K.ScreenDimensions.size.width / 2, y: K.ScreenDimensions.size.height / 2)
            logoSprite!.size = CGSize(width: logoWidth, height: logoWidth * 1024 / 4096)
            
            addChild(logoSprite!)
        }

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
                        message: "This app can deliver personalized ads to you. To enable this feature tap OK, then Allow on the next window.")
                    
                    idfaMessage!.delegate = self
                }
            } else {
                // Fallback on earlier versions
            }
            
            if notificationsMessage != nil || idfaMessage != nil {
                backgroundColor = .black
                logoSprite?.removeFromParent()
                
                thanksMessage = AuthorizationSprite(
                    title: "Enjoy!",
                    message: "Thank you for your responses! Now please enjoy PUZL Boy. And don't forget to rate and review 😊")
                
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
                } else {
                    // Fallback on earlier versions
                }
                
                thanksMessage?.animateShow { }
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
