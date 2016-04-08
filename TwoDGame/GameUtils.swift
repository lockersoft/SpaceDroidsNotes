//
//  GameUtils.swift
//  TwoDGame
//
//  Created by Dave Jones on 4/1/16.
//  Copyright © 2016 Lockersoft. All rights reserved.
//

import Foundation
import SpriteKit

struct PhysicsCategory {
  static let None      : UInt32 = 0
  static let All       : UInt32 = UInt32.max
  static let Asteroid  : UInt32 = 0b1       // 1
  static let PhaserShot: UInt32 = 0b10      // 2
  static let LaserShot : UInt32 = 0b100     // 4
}

struct Mass {
  static let PhaserShot    : CGFloat = 500.0
  static let AsteroidLarge : CGFloat = 2000.0
  static let AsteroidMedium: CGFloat = 1000.0
  static let AsteroidSmall : CGFloat = 500.0
}

func asteroidExplodeAnimation( location : CGPoint) -> SKEmitterNode {
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