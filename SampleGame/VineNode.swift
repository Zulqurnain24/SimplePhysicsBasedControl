
import UIKit
import SpriteKit
import AVFoundation

public struct GameConfiguration {
    static let VineDataFile = "VineData.plist"
    static let CanCutMultipleVinesAtOnce = false
}

struct ImageName {
    static let VineTexture = "VineTexture"
    static let VineHolder = "VineHolder"
    static let Prize = "knob"
    static let PrizeMask = "KnobMask"
}

struct PhysicsCategory {
    static let VineHolder: UInt32 = 2
    static let Vine: UInt32 = 4
    static let Prize: UInt32 = 8
}

struct Layer {
    static let Vine: CGFloat = 1
    static let Prize: CGFloat = 2
}

class VineNode: SKNode {
  var player: AVAudioPlayer?
  private var prize: SKSpriteNode!
  private var prizeDefaultPosition: CGPoint!
  private let length: Int
  private let anchorPoint: CGPoint
  private var vineSegments: [SKNode] = []
  
  public init(length: Int, anchorPoint: CGPoint, name: String) {
    self.length = length
    self.anchorPoint = anchorPoint
    
    super.init()
    
    self.name = name
  }
  
  required init?(coder aDecoder: NSCoder) {
    length = aDecoder.decodeInteger(forKey: "length")
    anchorPoint = aDecoder.decodeCGPoint(forKey: "anchorPoint")
    
    super.init(coder: aDecoder)
  }
  
  fileprivate func setUpPrize( width:CGFloat, height:CGFloat) {
        prize = SKSpriteNode(imageNamed: ImageName.Prize)
        prize.position = CGPoint(x: width * 0.5, y: height * 0.7)
        prize.zPosition = Layer.Prize
        prize.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: ImageName.Prize), size: prize.size)
        prize.physicsBody?.categoryBitMask = PhysicsCategory.Prize
        prize.physicsBody?.collisionBitMask = 0
        prize.physicsBody?.density = 0.5
        
        addChild(prize)
  }
   
  public func setPrize(location:CGPoint) {
        prize.position = location
  }
    
  func addToScene(_ scene: SKScene) {
    // add vine to scene
    zPosition = Layer.Vine
    scene.addChild(self)
    
    // create vine holder
    let vineHolder = SKSpriteNode(imageNamed: ImageName.VineHolder)
    vineHolder.position = anchorPoint
    vineHolder.zPosition = 1
    
    addChild(vineHolder)
    
    vineHolder.physicsBody = SKPhysicsBody(circleOfRadius: vineHolder.size.width / 2)
    vineHolder.physicsBody?.isDynamic = false
    vineHolder.physicsBody?.categoryBitMask = PhysicsCategory.VineHolder
    vineHolder.physicsBody?.collisionBitMask = 0
    
    // add each of the vine parts
    for i in 0..<length {
      let vineSegment = SKSpriteNode(imageNamed: ImageName.VineTexture)
      let offset = vineSegment.size.height * CGFloat(i + 1)
      vineSegment.position = CGPoint(x: anchorPoint.x, y: anchorPoint.y - offset)
      vineSegment.name = name
      
      vineSegments.append(vineSegment)
      addChild(vineSegment)
      
      vineSegment.physicsBody = SKPhysicsBody(rectangleOf: vineSegment.size)
      vineSegment.physicsBody?.categoryBitMask = PhysicsCategory.Vine
      vineSegment.physicsBody?.collisionBitMask = PhysicsCategory.VineHolder
    }
    
    // set up joint for vine holder
    let joint = SKPhysicsJointPin.joint(withBodyA: vineHolder.physicsBody!,
                                        bodyB: vineSegments[0].physicsBody!,
                                        anchor: CGPoint(x: vineHolder.frame.midX, y: vineHolder.frame.midY))
    scene.physicsWorld.add(joint)
    
    // set up joints between vine parts
    for i in 1..<length {
      let nodeA = vineSegments[i - 1]
      let nodeB = vineSegments[i]
      let joint = SKPhysicsJointPin.joint(withBodyA: nodeA.physicsBody!, bodyB: nodeB.physicsBody!,
                                          anchor: CGPoint(x: nodeA.frame.midX, y: nodeA.frame.minY))
      
      scene.physicsWorld.add(joint)
    }
    
    setUpPrize( width:20.0, height:20.0)
    attachToPrize(prize)
    prizeDefaultPosition = prize.position;
  }
  
  public func setPrizeToDefaultPosition() {
        prize.position = prizeDefaultPosition
  }
    
  func playSoundLampTickSound() {
        guard let url = Bundle.main.url(forResource: "switch_sound", withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)

            player = try AVAudioPlayer(contentsOf: url)

            guard let player = player else { return }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
  }
    
  func attachToPrize(_ prize: SKSpriteNode) {
    // align last segment of vine with prize
    let lastNode = vineSegments.last!
    lastNode.position = CGPoint(x: prize.position.x, y: prize.position.y + prize.size.height * 0.1)
    
    // set up connecting joint
    let joint = SKPhysicsJointPin.joint(withBodyA: lastNode.physicsBody!,
                                        bodyB: prize.physicsBody!, anchor: lastNode.position)
    
    prize.scene?.physicsWorld.add(joint)
  }
}

