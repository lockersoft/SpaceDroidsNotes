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
  var asteroid3 : Asteroid!
  
  var asteroids = [Asteroid]()
  var rocket = SKSpriteNode(fileNamed: "Spaceship")
  var scoreNode = SKLabelNode()
  var score = 0
  var rotationOffset : CGFloat = 0.0
  
  // create rotation gesture recognizer
  let rotateGesture = UIRotationGestureRecognizer()
  let longTapGesture = UILongPressGestureRecognizer()
  var phaserSound = SKAction.playSoundFileNamed("scifi10.mp3", waitForCompletion: false)
  var asteroidExplosionSound = SKAction.playSoundFileNamed("blast", waitForCompletion: false)
  
  var shipRotation = 0.0
  
  override func didMoveToView(view: SKView) {
    /* Setup your scene here */
    
    self.physicsWorld.contactDelegate = self
    
    rotateGesture.addTarget(self, action: "rotateRocket:")
    self.view!.addGestureRecognizer(rotateGesture)
    
    longTapGesture.addTarget(self, action: "addAsteroid:")
    self.view!.addGestureRecognizer(longTapGesture)
    
    rocket = self.childNodeWithName("Spaceship")  as? SKSpriteNode  // add from .sks
    rocket?.zPosition = 100   // Move to top
    rocket?.physicsBody = SKPhysicsBody(circleOfRadius: rocket!.size.width / 3)
    rocket?.physicsBody!.allowsRotation = true
    rocket?.physicsBody!.categoryBitMask = PhysicsCategory.SpaceShip
    rocket?.physicsBody!.collisionBitMask = PhysicsCategory.Asteroid
    rocket?.physicsBody!.contactTestBitMask = PhysicsCategory.Asteroid
    rocket?.physicsBody!.mass = Mass.SpaceShip

    
    scoreNode = self.childNodeWithName("Score")! as! SKLabelNode
    
  //  asteroid = self.childNodeWithName("LargeAsteroid") as! Asteroid!
   // asteroid.position = CGPoint(x: 200, y: 200)
    //asteroid.initializeAsteroid( "large" )
   // asteroid.animateAsteroid()
    asteroid = Asteroid( pos: CGPoint(x:-200, y:500), size: "large" )
    asteroid2 = Asteroid(pos: CGPoint( x:200, y:500), size: "medium" )
    asteroid3 = Asteroid(pos: CGPoint( x:200, y:300), size: "small" )
    self.addChild(asteroid)
    self.addChild(asteroid2)
    self.addChild(asteroid3)
    
    asteroids.append( asteroid )
    asteroids.append( asteroid2 )
    asteroids.append( asteroid3 )
    
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
      rocket!.zRotation = -gesture.rotation + rotationOffset
    }
    if( gesture.state == .Ended ){
      rotationOffset = rocket!.zRotation
    }
  }
  
  func createPhaserShot(){
    
    // http://gamedev.stackexchange.com/questions/18340/get-position-of-point-on-circumference-of-circle-given-an-angle
    // http://www.soundjig.com/pages/soundfx/scifi.html
    
    let ninetyDegreesInRadians = CGFloat(90.0 * M_PI / 180.0)
    let phaserShot = SKSpriteNode(imageNamed: "phaserShot")
    phaserShot.name = "phaserShot"
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
    phaserShot.physicsBody!.collisionBitMask = PhysicsCategory.Asteroid  & PhysicsCategory.PhaserShot
    phaserShot.physicsBody!.contactTestBitMask = PhysicsCategory.PhaserShot | PhysicsCategory.Asteroid
    phaserShot.physicsBody!.mass = Mass.PhaserShot
    
    addChild(phaserShot)
    runAction(phaserSound)
  }
  
  
  func addAsteroid( gesture: UILongPressGestureRecognizer ){
    let location = gesture.locationInView(self.view)
    print( gesture.locationInView(self.view), terminator: "" )
    
    let asteroid = Asteroid(pos: location)
    asteroids.append(asteroid)
    self.addChild(asteroid)
  }
  
  /// 
  // UPDATE
  
  override func update(currentTime: NSTimeInterval){
    for asteroid in asteroids {
      asteroid.move()
    }
    // Find all phaserShots and remove if off screen
    for child in self.children {
      if child.name == "phaserShot" {
        if let child = child as? SKSpriteNode {
          if( child.position.x > 1000 || child.position.x < -1000){
            child.removeFromParent()
          }
          if( child.position.y > 500 || child.position.y < -500 ){
            child.removeFromParent()
          }
          
        }
      }
    }
    scoreNode.text = "Score: " + String(score)
  }
  
  func didBeginContact(contact: SKPhysicsContact) {
    
    if( contact.bodyA.categoryBitMask == PhysicsCategory.SpaceShip ||
      contact.bodyB.categoryBitMask == PhysicsCategory.SpaceShip){
        
        print("Something hit the spaceship")
        print( "A: \(contact.bodyA.node?.name), B: \(contact.bodyB.node?.name)" )
        // Remove Spaceship and Asteroid
        contact.bodyB.node?.removeFromParent()
        contact.bodyA.node?.removeFromParent()
        
        // Add a super explosion
        if( contact.bodyA.node?.name == "Spaceship"){
          self.addChild((contact.bodyB.node as! Asteroid).explode())
          self.addChild((contact.bodyB.node as! Asteroid).explode())
          self.addChild((contact.bodyB.node as! Asteroid).explode())
        } else {
          self.addChild((contact.bodyA.node as! Asteroid).explode())
          self.addChild((contact.bodyB.node as! Asteroid).explode())
          self.addChild((contact.bodyB.node as! Asteroid).explode())
        }
        runAction(asteroidExplosionSound)
        runAction(asteroidExplosionSound)
        runAction(asteroidExplosionSound)
    }
    
    
    if (
        (contact.bodyA.categoryBitMask == PhysicsCategory.Asteroid) &&
        (contact.bodyB.categoryBitMask == PhysicsCategory.PhaserShot) ||
        (contact.bodyA.categoryBitMask == PhysicsCategory.PhaserShot) &&
        (contact.bodyB.categoryBitMask == PhysicsCategory.Asteroid)
      ) {
      
      print( "A: \(contact.bodyA.node?.name), B: \(contact.bodyB.node?.name)" )
      print( contact.bodyA.categoryBitMask, contact.bodyB.categoryBitMask )

      if let bodyA = contact.bodyA.node as? SKSpriteNode,
         let bodyB = contact.bodyB.node as? SKSpriteNode {

        let contactPoint = contact.contactPoint
        
        // Remove both from scene
        bodyB.removeFromParent()
        bodyA.removeFromParent()
          
        // Explode whichever body is the asteroid
        if( bodyA.name == "phaserShot" ){
          self.addChild((bodyB as! Asteroid).explode())
          runAction(asteroidExplosionSound)
        }
        if( bodyB.name == "phaserShot" ){
          self.addChild((bodyA as! Asteroid).explode())
          runAction(asteroidExplosionSound)
        }

        // Replace with 2 smaller asteroids
        var tempAsteroid : Asteroid
          
        print( asteroid.name )
        if( bodyA.name == "Asteroidlarge" || bodyB.name == "Asteroidlarge" ){
          for _ in 0..<2  {
            tempAsteroid = Asteroid(pos: contactPoint, size: "medium")
            asteroids.append(tempAsteroid)
            self.addChild(tempAsteroid)
          }
          score += 1
        }
          
        if( bodyA.name == "Asteroidmedium" || bodyB.name == "Asteroidmedium" ){
          for _ in 0..<2  {
            tempAsteroid = Asteroid(pos: contactPoint, size: "small")
            asteroids.append(tempAsteroid)
            self.addChild(tempAsteroid)
          }
          score += 5
        }

        if( bodyA.name == "Asteroidsmall" || bodyB.name == "Asteroidsmall" ){
          score += 10
        }
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
