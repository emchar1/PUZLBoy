//
//  ResetViewSprite.swift
//  PUZL Boy
//
//  Created by Eddie Char on 3/16/23.
//

//import SpriteKit
//
//class ResetViewSprite: SKNode {
//    let circleLayer: CAShapeLayer!
//
//    override init() {
//        circleLayer = CAShapeLayer()
//
//        super.init()
//
//
//        let circlePath = UIBezierPath(arcCenter: PauseResetEngine.position,
//                                      radius: PauseResetEngine.buttonSize / 2,
//                                      startAngle: 0,
//                                      endAngle: CGFloat(Double.pi * 2),
//                                      clockwise: true)
//        let circleLayerTrack = CAShapeLayer()
//        circleLayerTrack.path = circlePath.cgPath
//        circleLayerTrack.fillColor = UIColor.clear.cgColor
//        circleLayerTrack.strokeColor = (UIColor.systemGray).cgColor
//        circleLayerTrack.lineWidth = 8.0
//        circleLayerTrack.lineCap = .round
//        circleLayerTrack.strokeEnd = 1.0
//
//        circleLayer.path = circlePath.cgPath
//        circleLayer.fillColor = UIColor.clear.cgColor
//        circleLayer.strokeColor = (UIColor.systemGreen).cgColor
//        circleLayer.lineWidth = 8.0
//        circleLayer.lineCap = .round
//        circleLayer.strokeEnd = 0
//
//        addChild(<#T##node: SKNode##SKNode#>)
//
//        layer.addSublayer(circleLayerTrack)
//        layer.addSublayer(circleLayer)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    func animateCircle(duration: TimeInterval, fromValue: TimeInterval = 0, toValue: TimeInterval) {
//        let animation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.strokeEnd))
//        animation.duration = duration
//        animation.fromValue = fromValue
//        animation.toValue = toValue
//        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
//
//        circleLayer.strokeEnd = toValue
//        circleLayer.add(animation, forKey: "animateCircle")
//    }
//}


import SpriteKit

class ResetViewSprite: SKScene {
    let strokeSizeFactor: CGFloat = 2.0
    var strokeShader: SKShader!
    var strokeLengthUniform: SKUniform!
    var _strokeLengthFloat: Float = 0.0
    var strokeLengthKey: String!
    var strokeLengthFloat: Float {
        get {
            return _strokeLengthFloat
        }
        set(newStrokeLengthFloat) {
            _strokeLengthFloat = newStrokeLengthFloat
            strokeLengthUniform.floatValue = newStrokeLengthFloat
        }
    }
    
    func shaderWithFilename(_ filename: String?, fileExtension: String?, uniforms: [SKUniform]) -> SKShader {
        let path = Bundle.main.path(forResource: filename, ofType: fileExtension)
        let source = try! NSString(contentsOfFile: path!, encoding: String.Encoding.utf8.rawValue)
        let shader = SKShader(source: source as String, uniforms: uniforms)
        
        return shader
    }
    
    override func didMove(to view: SKView) {
        strokeLengthKey = "u_current_percentage"
        strokeLengthUniform = SKUniform(name: strokeLengthKey, float: 0.0)
        
        let uniforms: [SKUniform] = [strokeLengthUniform]
        strokeShader = shaderWithFilename("animateStroke", fileExtension: "fsh", uniforms: uniforms)
        strokeLengthFloat = 0.0
        
        let cameraNode = SKCameraNode()
        self.camera = cameraNode
        
        let strokeHeight = CGFloat(200) * strokeSizeFactor
        let path1 = CGMutablePath()
        path1.move(to: .zero)
        path1.addLine(to: CGPoint(x: 0, y: strokeHeight))
        
        // prior to a fix in iOS 10.2, bug #27989113  "SKShader/SKShapeNode: u_path_length is not set unless shouldUseLocalStrokeBuffers() is true"
        // add a few points to work around this bug in iOS 10-10.1 ->
        // for i in 0...15 {
        //    path1.addLine(to: CGPoint(x: 0, y: strokeHeight + CGFloat(0.001) * CGFloat(i)))
        // }
        
        path1.closeSubpath()
        
        let strokeWidth = 17.0 * strokeSizeFactor
        let path2 = CGMutablePath()
        path2.move(to: .zero)
        path2.addLine(to: CGPoint(x: 0, y: strokeHeight))
        path2.closeSubpath()
        
        let backgroundShapeNode = SKShapeNode(path: path2)
        backgroundShapeNode.lineWidth = strokeWidth
        backgroundShapeNode.zPosition = 5.0
        backgroundShapeNode.lineCap = .round
        backgroundShapeNode.strokeColor = SKColor.darkGray
        addChild(backgroundShapeNode)
        
        let shapeNode = SKShapeNode(path: path1)
        shapeNode.lineWidth = strokeWidth
        shapeNode.lineCap = .round
        backgroundShapeNode.addChild(shapeNode)
        shapeNode.addChild(cameraNode)
        shapeNode.strokeShader = strokeShader
        backgroundShapeNode.calculateAccumulatedFrame()
        
        cameraNode.position = CGPoint(x: backgroundShapeNode.frame.size.width / 2.0, y: backgroundShapeNode.frame.size.height / 2.0)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // the increment chosen determines how fast the path is stroked. Note this maps to "u_current_percentage" within animateStroke.fsh
        strokeLengthFloat += 0.01
        
        if strokeLengthFloat > 1.0 {
            strokeLengthFloat = 0.0
        }
    }
    
    
}
