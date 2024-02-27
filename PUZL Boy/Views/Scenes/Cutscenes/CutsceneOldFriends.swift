//
//  CutsceneOldFriends.swift
//  PUZL Boy
//
//  Created by Eddie Char on 2/6/24.
//

import SpriteKit

class CutsceneOldFriends: Cutscene {
    
    // MARK: - Properties
    
    //Custom properties go here.
    
    
    // MARK: - Initialization
    
    override func setupScene() {
        super.setupScene()
        
        speechPlayerLeft.position += playerLeft.sprite.position
        speechPlayerRight.position += playerRight.sprite.position
        
        fadeTransitionNode.fillColor = .white

        skipSceneSprite.delegate = self
    }
    
    
    // MARK: - Animate Functions
    
    override func animateScene(completion: (() -> Void)?) {
        super.animateScene(completion: completion)
        
        let fadeDuration: TimeInterval = 2
        
        letterbox.show { [unowned self] in
            addChild(skipSceneSprite)
            skipSceneSprite.animateSprite()
        }
        
        dimOverlayNode.run(SKAction.fadeAlpha(to: 0.5, duration: 1))
         
        run(SKAction.sequence([
            SKAction.run { [unowned self] in
                animateParallax()

                animatePlayer(player: &playerLeft,
                              position: CGPoint(x: screenSize.width * 1 / 5, y: screenSize.height / 2),
                              scale: 2,
                              shouldFlipHorizontally: false,
                              shouldRotateClockwise: true)
                
                animatePlayer(player: &playerRight,
                              position: CGPoint(x: screenSize.width * 4 / 5, y: screenSize.height / 2),
                              scale: 2 * playerRight.scaleMultiplier / playerLeft.scaleMultiplier,
                              shouldFlipHorizontally: true,
                              shouldRotateClockwise: false)
            },
            SKAction.wait(forDuration: 1 * fadeDuration),
            SKAction.run { [unowned self] in
                animateFlash(fadeDuration: fadeDuration) { [unowned self] in
                    speechNarrator.setText(text: "This is scene 1... the marsh. At first, I saw the signs that Magmoor was improving. Then he started to... disprove? Deprove. Well, whatever the opposite of improve is. Unprove?", superScene: self, completion: nil)
                    playScene1()
                }
            }
        ]))
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: 8 * fadeDuration),
            SKAction.run { [unowned self] in
                animateFlash(fadeDuration: fadeDuration) { [unowned self] in
                    speechNarrator.setText(text: "This is scene 2... the ice. Anyway, he reverted back to his old ways hellbent on conquering the planets without my consent. He was utterly and udderly, like a cow's teat, ungrateful!", superScene: self, completion: nil)
                    playScene2()
                }
            }
        ]))
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: 15 * fadeDuration),
            SKAction.run { [unowned self] in
                animateFlash(fadeDuration: fadeDuration) { [unowned self] in
                    speechNarrator.setText(text: "This is scene 3... the lava. Which is why he needs to be banished to a far away place never to harm and living person or creature ever again. And it all starts with Princess Olivia.", superScene: self, completion: nil)
                    playScene3()
                }
            }
        ]))
        
        run(SKAction.wait(forDuration: 20 * fadeDuration)) { [unowned self] in
            cleanupScene(buttonTap: nil, fadeDuration: nil)
        }
        
//        let frameRate: TimeInterval = 0.06
//        let playerLeftSpeed: TimeInterval = playerLeft.scaleMultiplier / playerRight.scaleMultiplier
//        let magmoorAnimate = SKAction.animate(with: playerLeft.textures[Player.Texture.walk.rawValue], timePerFrame: frameRate * playerLeftSpeed)
//        let marlinAnimate = SKAction.animate(with: playerRight.textures[Player.Texture.walk.rawValue], timePerFrame: frameRate)
//        
//        parallaxManager.animate()
//        
//        //Queue this up for the next subscene to prevent brief pause... it works apparently!
//        parallaxManager.changeSet(set: .ice)
//        parallaxManager.animate()
//        
//        letterbox.show { [unowned self] in
//            addChild(skipSceneSprite)
//            skipSceneSprite.animateSprite()
//        }
//        
//        playerLeft.sprite.run(SKAction.repeatForever(magmoorAnimate))
//        playerRight.sprite.run(SKAction.repeatForever(marlinAnimate))
//        
//        setTextArray(items: [
//            SpeechBubbleItem(profile: speechPlayerLeft, chat: "Beep."),
//            SpeechBubbleItem(profile: speechPlayerRight, chat: "Boop.")
//        ]) { [unowned self] in
//            let fadeDuration: TimeInterval = 3
//            
//            flashScene(fadeDuration: fadeDuration) { [unowned self] in
//                parallaxManager.addSpritesToParent(scene: self, node: backgroundNode)
//                parallaxManager.changeSet(set: .lava)
//                parallaxManager.animate()
//            }
//            
//            run(SKAction.sequence([
//                SKAction.wait(forDuration: fadeDuration),
//                SKAction.run { [unowned self] in
//                    setTextArray(items: [
//                        SpeechBubbleItem(profile: speechPlayerLeft, chat: "Everything you see here you can touch") { [unowned self] in
//                            parallaxManager.addSpritesToParent(scene: self, node: backgroundNode)
//                        },
//                        SpeechBubbleItem(profile: speechPlayerRight, chat: "You can look but you cannot touch!")
//                    ]) { [unowned self] in
//                        cleanupScene(buttonTap: nil, fadeDuration: nil)
//                    }
//                }
//            ]))
//        }
    }
    
    private func animatePlayer(player: inout Player, position: CGPoint, scale: CGFloat, shouldFlipHorizontally: Bool, shouldRotateClockwise: Bool) {
        let rotationRange: CGFloat = .pi / 8
        let randomRotation: CGFloat = CGFloat.random(in: -rotationRange...rotationRange)
        let scaleIncrease: CGFloat = 1.25
        let flipHorizontally: CGFloat = shouldFlipHorizontally ? -1 : 1
        let rotateClockwise: CGFloat = shouldRotateClockwise ? -1 : 1
        let animationDuration: TimeInterval = 12

        player.sprite.position = position
        player.sprite.setScale(scale)
        player.sprite.xScale *= flipHorizontally
        player.sprite.zRotation = randomRotation
        
        player.sprite.removeAllActions()
        
        player.sprite.run(SKAction.group([
            SKAction.rotate(toAngle: rotateClockwise * rotationRange + randomRotation, duration: animationDuration),
            SKAction.scaleX(to: flipHorizontally * scale * scaleIncrease, y: scale * scaleIncrease, duration: animationDuration)
        ]))
    }
    
    private func animateParallax() {
        let scale: CGFloat = 1
        let scaleIncrease: CGFloat = 1.25
        let animationDuration: TimeInterval = 12
        
        parallaxManager.backgroundSprite.setScale(scale)
        parallaxManager.backgroundSprite.run(SKAction.scale(to: scale * scaleIncrease, duration: animationDuration))
    }
    
    private func animateFlash(fadeDuration: TimeInterval, completion: (() -> Void)?) {
        //fadeTransitionNode is initially added to backgroundNode, so remove it first to prevent app crashing due to it already having a parent node.
        fadeTransitionNode.removeAllActions()
        fadeTransitionNode.removeFromParent()

        backgroundNode.addChild(fadeTransitionNode)
        
        fadeTransitionNode.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: fadeDuration / 3),
            SKAction.run {
                completion?()
            },
            SKAction.wait(forDuration: fadeDuration / 3),
            SKAction.fadeOut(withDuration: fadeDuration / 3),
            SKAction.removeFromParent()
        ]))
    }
    
    
    // MARK: - Animation Scene Helper Functions
    
    private func playScene1() {
        parallaxManager.changeSet(set: .marsh)
        parallaxManager.addSpritesToParent(scene: self, node: backgroundNode)
        
        animateParallax()

        animatePlayer(player: &playerLeft,
                      position: CGPoint(x: screenSize.width * 1 / 5, y: screenSize.height / 2),
                      scale: 2,
                      shouldFlipHorizontally: false,
                      shouldRotateClockwise: true)
        
        animatePlayer(player: &playerRight, 
                      position: CGPoint(x: screenSize.width * 4 / 5, y: screenSize.height / 2),
                      scale: 2 * playerRight.scaleMultiplier / playerLeft.scaleMultiplier,
                      shouldFlipHorizontally: true,
                      shouldRotateClockwise: false)
    }
    
    private func playScene2() {
        parallaxManager.changeSet(set: .ice)
        parallaxManager.addSpritesToParent(scene: self, node: backgroundNode)
        
        animateParallax()

        animatePlayer(player: &playerLeft,
                      position: CGPoint(x: screenSize.width * 1 / 5, y: screenSize.height / 2),
                      scale: 2,
                      shouldFlipHorizontally: false,
                      shouldRotateClockwise: true)
        
        animatePlayer(player: &playerRight,
                      position: CGPoint(x: screenSize.width * 4 / 5, y: screenSize.height / 2),
                      scale: 2 * playerRight.scaleMultiplier / playerLeft.scaleMultiplier,
                      shouldFlipHorizontally: true,
                      shouldRotateClockwise: false)
    }
    
    private func playScene3() {
        parallaxManager.changeSet(set: .lava)
        parallaxManager.addSpritesToParent(scene: self, node: backgroundNode)
        
        animateParallax()

        animatePlayer(player: &playerLeft,
                      position: CGPoint(x: screenSize.width * 1 / 5, y: screenSize.height / 2),
                      scale: 2,
                      shouldFlipHorizontally: false,
                      shouldRotateClockwise: true)
        
        animatePlayer(player: &playerRight,
                      position: CGPoint(x: screenSize.width * 4 / 5, y: screenSize.height / 2),
                      scale: 2 * playerRight.scaleMultiplier / playerLeft.scaleMultiplier,
                      shouldFlipHorizontally: true,
                      shouldRotateClockwise: false)
    }
}


// MARK: - SkipSceneSprite Delegate

extension CutsceneOldFriends: SkipSceneSpriteDelegate {
    func buttonWasTapped() {
        //No fade duration because the protocol function does it's own .white fade transition in GameViewController.
        cleanupScene(buttonTap: .buttontap1, fadeDuration: nil)
    }
    
}
