//
//  MainMenu.swift
//  TwoDGame
//
//  Created by Dave Jones on 4/2/16.
//  Copyright © 2016 Lockersoft. All rights reserved.
//

import Foundation
import SpriteKit

class MainMenu: SKScene {
  
  var playButton : SKSpriteNode?
  var optionsButton : SKSpriteNode?
  var sound = SKAction.playSoundFileNamed("scifi10.mp3", waitForCompletion: false)

  override func didMoveToView(view: SKView) {
    print( view.bounds.size )
    playButton = self.childNodeWithName("PlayGame") as! SKSpriteNode!
    optionsButton = self.childNodeWithName("Options") as! SKSpriteNode!
  }

  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    for touch in touches {
      let location = touch.locationInNode(self)
      //  self.addChild(asteroidExplodeAnimation(touch.locationInView(self.view)))
      runAction(sound)

      print( nodeAtPoint(location).name, terminator: "" )
      if( nodeAtPoint(location).name == playButton!.name){
        print("Play Button pressed", terminator: "")
        runAction(sound)
        
        let scene = GameScene(fileNamed: "GameScene")
        scene?.scaleMode = .AspectFill
        self.view?.presentScene(scene!, transition: SKTransition.doorsOpenHorizontalWithDuration(1))
      }
            
      if( nodeAtPoint(location).name == optionsButton!.name ) {
        let scene = OptionsMenu(fileNamed: "OptionsMenu")
        print("Options Button pressed", terminator: "")
        scene?.scaleMode = .AspectFill
        runAction(sound)

        self.view?.presentScene(scene!, transition: SKTransition.doorsOpenHorizontalWithDuration(1))
      }
    }
  }
}
