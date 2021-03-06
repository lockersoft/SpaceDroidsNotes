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
  var asteroidSize : String = "large"
  static var asteroids = [Asteroid]()     // Class level var to store ALL asteroids created.
  
  convenience init( pos : CGPoint ) {
    self.init( pos : pos, size: "large")
  }
  
  init( pos : CGPoint, size : String ){
    chosenDirection = directions[Int(arc4random_uniform(UInt32(directions.count)))]

    self.asteroidSize = size
    let initialImageName = Int(arc4random_uniform(UInt32(15)))
    let texture = SKTexture(imageNamed: "\(size)\(initialImageName).png")
    super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
    
    self.pos = pos
    self.userData = NSMutableDictionary()
    self.userData?.setValue(size, forKeyPath: "size")

    initializeAsteroid(size)
    animateAsteroid()
    Asteroid.asteroids.append( self )
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init( coder: aDecoder )
  }
  
  func initializeAsteroid(size: String){
    self.position = pos
    textureAtlas = SKTextureAtlas(named: "\(size).atlas")
    self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    
    //for( var i=0;i<=15;i += 1) {
    for i in 0..<15 {
     let name = "\(size)\(i)"
    //  print( name, terminator: "" );
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
    self.name = "Asteroid\(size)"
  }

  /*
  func initializeAsteroid(){
    self.position = pos
    textureAtlas = SKTextureAtlas(named: "large.Atlas")
    self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    
    for( var i=0;i<=15;i++) {
      let name = "large\(i)"
 //     print( name, terminator: "" );
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
  
  */
  func animateAsteroid(){
    self.runAction(SKAction.repeatActionForever(animatePlayerAction), withKey: "AsteroidRotation" )
  }
  
  func move(){
    position.x = position.x + CGFloat(chosenDirection.0)
    position.y = position.y + CGFloat(chosenDirection.1)
  }
  
  func remove(){
    Asteroid.asteroids = Asteroid.asteroids.filter{ $0 != self }
  }
  
  func explode() -> SKEmitterNode {
 //   let centerX = (self.size.width / 2) + self.position.x
 //   let centerY = (self.size.height / 2) + self.position.y
    return self.asteroidExplodeAnimation(CGPoint( x: self.position.x, y: self.position.y))
    
  }
  
  func asteroidExplodeAnimation( location : CGPoint ) -> SKEmitterNode {
    var burstNode : SKEmitterNode = SKEmitterNode()
    if let burstPath = NSBundle.mainBundle().pathForResource(
      "AsteroidExplode", ofType: "sks") {
        
        burstNode = NSKeyedUnarchiver.unarchiveObjectWithFile(burstPath)
          as! SKEmitterNode
        burstNode.position = location
        burstNode.name = "asteroidExplode"
        burstNode.runAction(SKAction.sequence(
          [
            SKAction.waitForDuration(0.5),
            SKAction.fadeAlphaTo(0.0, duration: 0.3),
            SKAction.removeFromParent(),
            SKAction.runBlock({Asteroid.asteroids = Asteroid.asteroids.filter{ $0 != self}})  // remove asteroid from the list
          ]))
    }
    return burstNode
  }
}
