//
//  Asteroid.swift
//  TwoDGame
//
//  Created by Dave Jones on 3/29/16.
//  Copyright © 2016 Lockersoft. All rights reserved.
//

import SpriteKit

class Asteroid: SKSpriteNode {
  
  var textureAtlas = SKTextureAtlas()
  var playerAnimation = [SKTexture]()
  var animatePlayerAction = SKAction()
  var pos = CGPoint(x: 0, y: 0)
  var directions = [(0,1), (0,-1), (1, 0), (-1, 0), (-1, -1), (1, 1), (1, -1),(-1,0), (-1,1)]
  var chosenDirection = (0,1)
  
  init( pos : CGPoint ) {
    self.pos = pos
    // Choose a random direction for the asteroid to move
    chosenDirection = directions[Int(arc4random_uniform(UInt32(directions.count)))]
    
    // let texture = SKTexture(imageNamed: "aLarge0.png")
    let initialImageName = Int(arc4random_uniform(UInt32(15)))
    let texture = SKTexture(imageNamed: "aLarge\(initialImageName).png")
    super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
    initializeAsteroid()
    animateAsteroid()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init( coder: aDecoder )
  }
  
  func initializeAsteroid(){
    self.position = pos
    textureAtlas = SKTextureAtlas(named: "largeAsteroid.Atlas")
    self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    
    for( var i=0;i<=15;i++) {
      let name = "aLarge\(i)"
      print( name, terminator: "" );
      playerAnimation.append(SKTexture(imageNamed: name))
    }
    
    animatePlayerAction = SKAction.animateWithTextures(playerAnimation,
      timePerFrame: 0.08, resize: true, restore: true )
    
    // Add physics to asteroid
    self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.width / 5)
    self.physicsBody!.allowsRotation = true
    self.physicsBody!.categoryBitMask = PhysicsCategory.Asteroid
    self.physicsBody!.collisionBitMask = PhysicsCategory.All
    self.physicsBody!.mass = Mass.AsteroidLarge
    self.name = "Asteroid"
  }
  
  func animateAsteroid(){
    self.runAction(SKAction.repeatActionForever(animatePlayerAction), withKey: "AsteroidRotation" )
  }
  
  func move(){
    position.x = position.x + CGFloat(chosenDirection.0)
    position.y = position.y + CGFloat(chosenDirection.1)
  }
  
  func explode() -> SKEmitterNode {
    let centerX = (self.size.width / 2) + self.position.x
    let centerY = (self.size.height / 2) + self.position.y
    return self.asteroidExplodeAnimation(CGPoint( x: centerX, y: centerY))
    
  }
  
  func asteroidExplodeAnimation( location : CGPoint ) -> SKEmitterNode {
    var burstNode : SKEmitterNode = SKEmitterNode()
    if let burstPath = NSBundle.mainBundle().pathForResource(
      "AsteroidExplode", ofType: "sks") {
        
        burstNode = NSKeyedUnarchiver.unarchiveObjectWithFile(burstPath)
          as! SKEmitterNode
        burstNode.position = location
        burstNode.runAction(SKAction.sequence(
          [SKAction.waitForDuration(0.5),
            SKAction.fadeAlphaTo(0.0, duration: 0.3),
            SKAction.removeFromParent()
          ]))
    }
    return burstNode
  }
}
