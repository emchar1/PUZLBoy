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
    private var photosensitivityMessage: AuthorizationSprite?
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

        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            guard let self = self else { return }
            
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
                
                photosensitivityMessage = AuthorizationSprite(
                    title: "Photosensitivity Warning",
                    message: "Some flashing lights sequences or patterns may affect photosensitive individuals. Please use with caution.",
                    confirm: "I Understand")
                
                photosensitivityMessage!.delegate = self
            }
            
            if photosensitivityMessage != nil {
                thanksMessage = AuthorizationSprite(
                    title: "Enjoy!",
                    message: "Thank you for your responses! Enjoy playing PUZL Boy. And please don't forget to rate and review 😊",
                    confirm: "Play")
                
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
        
        if let photosensitivityMessage = photosensitivityMessage {
            addChild(photosensitivityMessage)
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
        photosensitivityMessage?.touchDown(in: location)
        thanksMessage?.touchDown(in: location)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }

        notificationsMessage?.didTapButton(in: location)
        notificationsMessage?.touchUp()
        
        idfaMessage?.didTapButton(in: location)
        idfaMessage?.touchUp()
        
        photosensitivityMessage?.didTapButton(in: location)
        photosensitivityMessage?.touchUp()
        
        thanksMessage?.didTapButton(in: location)
        thanksMessage?.touchUp()
    }
    
}


// MARK: - ConfirmSpriteDelegate

extension AuthorizationRequestScene: ConfirmSpriteDelegate {
    func didTapConfirm(_ confirmSprite: ConfirmSprite) {
        switch confirmSprite {
        case let authorizationSprite where authorizationSprite == notificationsMessage:
            authorizationSprite.animateHide { [weak self] in
                LifeSpawnerModel.shared.requestNotifications()
                
                if let idfaMessage = self?.idfaMessage {
                    idfaMessage.animateShow { }
                }
                else {
                    self?.photosensitivityMessage?.animateShow { }
                }
            }
        case let authorizationSprite where authorizationSprite == idfaMessage:
            authorizationSprite.animateHide { [weak self] in
                if #available(iOS 14, *) {
                    AdMobManager.shared.requestIDFAPermission()
                } else {
                    // Fallback on earlier versions
                }
                
                self?.photosensitivityMessage?.animateShow { }
            }
        case let authorizationSprite where authorizationSprite == photosensitivityMessage:
            authorizationSprite.animateHide { [weak self] in
                self?.thanksMessage?.animateShow { }
            }
        case let authorizationSprite where authorizationSprite == thanksMessage:
            authorizationSprite.animateHide { [weak self] in
                self?.sceneDelegate?.didAuthorizeRequests(shouldFadeIn: true)
            }
        default:
            break
        }
    }
    
    func didTapCancel(_ confirmSprite: ConfirmSprite) {
        print("NotificationsRequestScene::ConfirmSprite.cancel() - this should't execute!")
    }
    
}
