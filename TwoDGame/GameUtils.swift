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
  static let SpaceShip : UInt32 = 0b1000    // 8
}

struct Mass {
  static let PhaserShot    : CGFloat = 500.0
  static let AsteroidLarge : CGFloat = 2000.0
  static let AsteroidMedium: CGFloat = 1000.0
  static let AsteroidSmall : CGFloat = 500.0
  static let SpaceShip     : CGFloat = 750.0
}

