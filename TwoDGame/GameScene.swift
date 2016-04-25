
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
  //  var nodesToRemove = [SKSpriteNode]()   // array to hold nodes that need to be removed
  
  var rocket = SKSpriteNode(fileNamed: "Spaceship")
  var scoreNode = SKLabelNode()
  var score = 0
  var rotationOffset : CGFloat = 0.0
  
  var shipLives = 2
  var maxLives = 5
  var livesNodes = [SKNode]()        // array to hold "lives" ship icon
  var gameOver = false
  
  var xMax : CGFloat = 0.0
  var yMax : CGFloat = 0.0
  var xMin : CGFloat = 0.0
  var yMin : CGFloat = 0.0
  
  // create rotation gesture recognizer
  let rotateGesture = UIRotationGestureRecognizer()
  let longTapGesture = UILongPressGestureRecognizer()
  var phaserSound = SKAction.playSoundFileNamed("scifi10.mp3", waitForCompletion: false)
  var asteroidExplosionSound = SKAction.playSoundFileNamed("blast", waitForCompletion: false)
  
  var shipRotation = 0.0
  
  
  ///
  //  Main Play Scene
  //
  
  override func didMoveToView(view: SKView) {
    /* Setup your scene here */
    
    self.physicsWorld.contactDelegate = self
    xMax = self.scene!.frame.size.height / 2
    yMax = self.scene!.frame.size.width / 2
    xMin = -xMax
    yMin = -yMax
    
    for i in 0..<maxLives {
      let tempNode = self.childNodeWithName("Life\(i)")!
      tempNode.hidden = true
      livesNodes.append( tempNode )
    }
    
    rotateGesture.addTarget(self, action: "rotateRocket:")
    self.view!.addGestureRecognizer(rotateGesture)
    
    longTapGesture.addTarget(self, action: "addAsteroid:")
    self.view!.addGestureRecognizer(longTapGesture)
    
    displayShip()
    
    scoreNode = self.childNodeWithName("Score")! as! SKLabelNode
    
    // asteroid = self.childNodeWithName("LargeAsteroid") as! Asteroid!
    // asteroid.position = CGPoint(x: 200, y: 200)
    // asteroid.initializeAsteroid( "large" )
    // asteroid.animateAsteroid()
    asteroid = Asteroid( pos: CGPoint( x:-200, y:500), size: "large" )
    asteroid2 = Asteroid(pos: CGPoint( x:200, y:500), size: "medium" )
    asteroid3 = Asteroid(pos: CGPoint( x:200, y:300), size: "small" )
    self.addChild(asteroid)
    self.addChild(asteroid2)
    self.addChild(asteroid3)
    
    asteroids.append( asteroid )
    asteroids.append( asteroid2 )
    asteroids.append( asteroid3 )
    
    for _ in 0..<10 {
      let tempAsteroid = Asteroid( pos: randomCGPoint(xMax, maxY: yMax))
      asteroids.append(tempAsteroid)
      self.addChild(tempAsteroid)
    }
    
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
    
    resetShipLivesDisplay()
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
  
  func displayShip(){
    rocket = SKSpriteNode(imageNamed: "Spaceship")
    rocket!.zPosition = 100   // Move to top
    rocket!.position = CGPoint(x: 0,y: 0)
    rocket!.setScale( 0.4 )
    rocket!.physicsBody = SKPhysicsBody(circleOfRadius: rocket!.size.width / 3)
    rocket!.physicsBody!.allowsRotation = true
    rocket!.physicsBody!.categoryBitMask = PhysicsCategory.SpaceShip
    rocket!.physicsBody!.collisionBitMask = PhysicsCategory.None        // Make it invulnerable temporarily
    rocket!.physicsBody!.contactTestBitMask = PhysicsCategory.None
    rocket!.physicsBody!.mass = Mass.SpaceShip
    
    rocket!.runAction( SKAction.sequence(
      [SKAction.waitForDuration(10.0),
        SKAction.runBlock({
          self.rocket!.physicsBody!.collisionBitMask = PhysicsCategory.Asteroid      // Make it vulnerable again
          self.rocket!.physicsBody!.contactTestBitMask = PhysicsCategory.Asteroid
        })
      ]))
    self.addChild( rocket! )
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
    phaserShot.xScale = 0.1
    phaserShot.yScale = 0.1
    
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
  
  func finishGame(){
    gameOver = true
    let goNode = self.childNodeWithName("gameOver") as? SKLabelNode  // add from .sks
    goNode?.setScale( 0.1 )
    //   let moveAction = SKAction.moveTo(CGPoint(x: 0,y: 0), duration: 5.0)
    //   let rotateAction = SKAction.fadeInWithDuration(5.0)
    let goAction = SKAction(named: "GameOver")!
    goNode!.runAction( SKAction.sequence([goAction, SKAction.waitForDuration(2), SKAction.removeFromParent()] ))
  }
  
  /// Mark: UPDATE
  // UPDATE
  
  override func update(currentTime: NSTimeInterval){
    if( (Asteroid.count() == 0 || shipLives <= 0 ) && !gameOver){
      finishGame()
    }
    
    // Move all the asteroids
    for asteroid in asteroids {
      asteroid.move()
    }
    // Find all phaserShots and remove it IF off screen
    for child in self.children {
      if child.name == "phaserShot" {
        if let child = child as? SKSpriteNode {
          if( child.position.x > xMax || child.position.x < xMin){
            child.removeFromParent()
          }
          if( child.position.y > yMax || child.position.y < yMin){
            child.removeFromParent()
          }
          
        }
      } else if( child.name == "Asteroidlarge" ||   // Check off screen and wrap
        child.name == "Asteroidmedium" ||
        child.name == "Asteroidsmall") {
          
          //   print( child.position.x, child.position.y )
          // Put the asteroid at the other side of the screen so it "wraps" around
          if( child.position.y > yMax ){
            child.position.y = yMin
          } else if( child.position.y < yMin){
            child.position.y = yMax
          }
          if( child.position.x > xMax ){
            child.position.x = xMin
          } else if( child.position.x < xMin ){
            child.position.x = xMax
          }
      }
    }
    
    scoreNode.text = "Score: " + String(score)
  }
  
  func shipExplode( location : CGPoint) -> SKEmitterNode {
    var burstNode : SKEmitterNode = SKEmitterNode()
    if let burstPath = NSBundle.mainBundle().pathForResource(
      "ShipExplosion", ofType: "sks") {
        
        burstNode = NSKeyedUnarchiver.unarchiveObjectWithFile(burstPath)
          as! SKEmitterNode
        burstNode.position = location
        burstNode.name = "ShipExplosion"
        burstNode.runAction(SKAction.sequence(
          [ asteroidExplosionSound,
            SKAction.waitForDuration(0.5),
            SKAction.fadeAlphaTo(0.0, duration: 0.3),
            SKAction.removeFromParent(),
            SKAction.waitForDuration(5.0)
          ]))
    }
    shipLives -= 1
    resetShipLivesDisplay()
    if( shipLives <= 0 ){
      shipLives = 0
      finishGame()
    } else {
      displayShip()
    }
    return burstNode
  }
  
  func resetShipLivesDisplay(){
    for i in 0..<shipLives {
      livesNodes[i].hidden = false
    }
    for i in shipLives..<maxLives {
      livesNodes[i].hidden = true
    }
  }
  
  func didBeginContact(contact: SKPhysicsContact) {
    
    // Handle an asteroid hitting the main player spaceship
    if( contact.bodyA.categoryBitMask == PhysicsCategory.SpaceShip ||
      contact.bodyB.categoryBitMask == PhysicsCategory.SpaceShip){
        
        print("Something hit the spaceship")
        print( "A: \(contact.bodyA.node?.name), B: \(contact.bodyB.node?.name)" )
        // Remove Spaceship and Asteroid
        //     nodesToRemove.append(contact.bodyA.node! as! SKSpriteNode)
        //     nodesToRemove.append(contact.bodyB.node! as! SKSpriteNode)
        contact.bodyA.node!.removeFromParent()
        contact.bodyB.node!.removeFromParent()
        
        // Add a super explosion
        self.addChild(shipExplode(contact.contactPoint))
        runAction(asteroidExplosionSound)
    }
    
    // Handle a phasershot hitting an asteroid
    if (
      ((contact.bodyA.categoryBitMask == PhysicsCategory.Asteroid) &&
        (contact.bodyB.categoryBitMask == PhysicsCategory.PhaserShot)) ||
        ((contact.bodyA.categoryBitMask == PhysicsCategory.PhaserShot) &&
          (contact.bodyB.categoryBitMask == PhysicsCategory.Asteroid))
      ) {
        
        print( "A: \(contact.bodyA.node?.name), B: \(contact.bodyB.node?.name)" )
        print( contact.bodyA.categoryBitMask, contact.bodyB.categoryBitMask )
        
        if let bodyA = contact.bodyA.node as? SKSpriteNode,
          let bodyB = contact.bodyB.node as? SKSpriteNode {
            
            let contactPoint = contact.contactPoint
            
            // Explode whichever body is the asteroid
            if( bodyA.name == "phaserShot" ){
              self.addChild((bodyB as! Asteroid).explode())
              // Remove the asteroid from the list of asteroids
              
              runAction(asteroidExplosionSound)
            }
            if( bodyB.name == "phaserShot" ){
              self.addChild((bodyA as! Asteroid).explode())
              runAction(asteroidExplosionSound)
            }
            
            bodyA.removeFromParent()
            bodyB.removeFromParent()
            
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
      if( gameOver ){
        // Go back to main Play Scene
        let scene = MainMenu(fileNamed: "MainMenu")
        scene?.scaleMode = .AspectFill
        self.view?.presentScene(scene!, transition: SKTransition.doorsOpenHorizontalWithDuration(1))
      }
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
