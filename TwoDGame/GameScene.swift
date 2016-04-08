//
//  GameScene.swift
//  TwoDGame
//
//  Created by Dave Jones on 3/26/16.
//  Copyright (c) 2016 Lockersoft. All rights reserved.
//
//  TODO:  Add Options Screen
//         Add Levels
//         Add Startup screen with levels and buttons
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
  
  var asteroid : Asteroid!
  var asteroid2 : Asteroid!
  var asteroids = [Asteroid]()
  var rocket = SKNode(fileNamed: "Spaceship")
  var score = 0
  
  // create rotation gesture recognizer
  let rotateGesture = UIRotationGestureRecognizer()
  let longTapGesture = UILongPressGestureRecognizer()
  var sound = SKAction.playSoundFileNamed("scifi10.mp3", waitForCompletion: false)

  var shipRotation = 0.0
  
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
      
      self.physicsWorld.contactDelegate = self

      rotateGesture.addTarget(self, action: "rotateRocket:")
      self.view!.addGestureRecognizer(rotateGesture)
      
      longTapGesture.addTarget(self, action: "addAsteroid:")
      self.view!.addGestureRecognizer(longTapGesture)
      
      rocket = self.childNodeWithName("Spaceship")    // add from .sks 
      rocket?.zPosition = 100   // Move to top
      
      asteroid = self.childNodeWithName("LargeAsteroid") as! Asteroid!
      asteroid.initializeAsteroid()
      asteroid.animateAsteroid()
      
      asteroid2 = Asteroid(pos: CGPoint( x:200, y:500))
      self.addChild(asteroid2)
      
      asteroids.append( asteroid )
      asteroids.append( asteroid2 )
      
      let myLabel = SKLabelNode(fontNamed:"Chalkduster")
      myLabel.text = "Hello, World!"
      myLabel.fontSize = 45
      myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
      
    //    let vector = CGVector(dx: 5, dy: 5)

        var action = SKAction.scaleBy(-0.1, duration: 5.0)
        myLabel.runAction(SKAction.repeatActionForever(action))

        action = SKAction.rotateByAngle(CGFloat(M_PI), duration:2)
        myLabel.runAction(SKAction.repeatActionForever(action))

        self.addChild(myLabel)

/*      var largeRock:SKSpriteNode = SKSpriteNode()
           if let someSpriteNode:SKSpriteNode = self.childNodeWithName("LargeAsteroid") as? SKSpriteNode {
        largeRock = someSpriteNode
      }
*/
      //      let largeRock = SKSpriteNode(imageNamed: "a10000")
      //largeRock.position = CGPoint( x:500, y:500)
      //largeRock.xScale = 1.0
      //largeRock.yScale = 1.0

      //    let moveAction = SKAction.moveBy(vector, duration: 1)
      //largeRock.runAction(SKAction.repeatActionForever(moveAction))
      // largeRock.runAction(SKAction.repeatActionForever(animatePlayerAction), withKey: "largeRockSpin")
      
      //self.addChild( largeRock)
      
      
    }
  
  func rotateRocket(gesture: UIRotationGestureRecognizer) {
    
    if( gesture.state == .Changed ){
      rocket!.zRotation = -gesture.rotation
    }
  }
  
  func createPhaserShot(){
    
    // http://gamedev.stackexchange.com/questions/18340/get-position-of-point-on-circumference-of-circle-given-an-angle
    // http://www.soundjig.com/pages/soundfx/scifi.html
    
    let ninetyDegreesInRadians = CGFloat(90.0 * M_PI / 180.0)
    let phaserShot = SKSpriteNode(imageNamed: "phaserShot")
    phaserShot.zRotation = rocket!.zRotation
    phaserShot.position = CGPointMake(rocket!.position.x, rocket!.position.y)

    let xDist = (cos(phaserShot.zRotation + ninetyDegreesInRadians) * 1000 ) + phaserShot.position.x
    let yDist = (sin(phaserShot.zRotation + ninetyDegreesInRadians) * 1000 ) + phaserShot.position.y
    
    print( phaserShot.zRotation, xDist, yDist )

    let vector = CGPointMake(xDist, yDist)
    let moveAction = SKAction.moveTo(vector, duration: 2)

    phaserShot.runAction(SKAction.repeatActionForever(moveAction))

    // Add physics to asteroid
    phaserShot.physicsBody = SKPhysicsBody(circleOfRadius: phaserShot.size.width )
    phaserShot.physicsBody?.allowsRotation = true
    phaserShot.physicsBody!.categoryBitMask = PhysicsCategory.PhaserShot
    phaserShot.physicsBody!.collisionBitMask = PhysicsCategory.Asteroid
    phaserShot.physicsBody!.contactTestBitMask = PhysicsCategory.PhaserShot | PhysicsCategory.Asteroid
    phaserShot.physicsBody!.mass = Mass.PhaserShot
    
    addChild(phaserShot)
    runAction(sound)

  }
  
  
  func addAsteroid( gesture: UILongPressGestureRecognizer ){
    let location = gesture.locationInView(self.view)
    print( gesture.locationInView(self.view) )
      
    let asteroid = Asteroid(pos: location)
    asteroids.append(asteroid)
    self.addChild(asteroid)
  }

  override func update(currentTime: NSTimeInterval){
    for asteroid in asteroids {
      asteroid.move()
    }
  }
    
   func didBeginContact(contact: SKPhysicsContact) {
    _ = contact.bodyA.node as! SKSpriteNode
    let secondNode = contact.bodyB.node as! SKSpriteNode
    
    print( contact.bodyA.node?.name, contact.bodyB.node?.name )
    print( contact.bodyA.categoryBitMask, contact.bodyB.categoryBitMask )
    if (contact.bodyA.categoryBitMask == PhysicsCategory.Asteroid) &&
      (contact.bodyB.categoryBitMask == PhysicsCategory.PhaserShot) {
        
        let contactPoint = contact.contactPoint
        let contact_y = contactPoint.y
        let target_x = secondNode.position.x
        let target_y = secondNode.position.y
        let margin = secondNode.frame.size.height/2 - 25
        
        if (contact_y > (target_y - margin))
          && (contact_y < (target_y + margin)) {
            
            let burstPath = NSBundle.mainBundle().pathForResource(
              "AsteroidExplode", ofType: "sks")
            
            if burstPath != nil {
              let burstNode =
              NSKeyedUnarchiver.unarchiveObjectWithFile(burstPath!)
                as! SKEmitterNode
              burstNode.position = CGPointMake(target_x, target_y)
              secondNode.removeFromParent()
              burstNode.runAction(SKAction.sequence(
                [SKAction.waitForDuration(0.5),
                  SKAction.fadeAlphaTo(0.0, duration: 0.3),
                  SKAction.removeFromParent()
                ]))

              self.addChild(burstNode)
            }
            score++
        }
    }
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            _ = touch.locationInNode(self)
            createPhaserShot()
            /*let sprite = SKSpriteNode(imageNamed:"a10000")
            
            sprite.xScale = 1.5
            sprite.yScale = 1.5
            sprite.position = location
          */
          //   let vector = CGVector(dx: 5, dy: 5)
          
          //   let actionScale = SKAction.scaleBy(-0.1, duration: 0.5)
          // sprite.runAction(SKAction.repeatActionForever(action))
          
          //  let actionRotate = SKAction.rotateByAngle(CGFloat(M_PI), duration:0.5)
          //  sprite.runAction(SKAction.repeatActionForever(action))
          
          //   let actionMove = SKAction.moveBy(vector, duration: 1.0)
          //  sprite.runAction(SKAction.repeatActionForever(action))
          
          //  let sequence = SKAction.sequence([actionScale, actionRotate, actionMove])
          //  sprite.runAction(SKAction.repeatActionForever(sequence ))
          //   self.addChild(sprite)
          

        }
    }
   
}