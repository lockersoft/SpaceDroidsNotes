//
//  OptionsMenu.swift
//  TwoDGame
//
//  Created by Jones, Dave on 4/5/16.
//  Copyright © 2016 Lockersoft. All rights reserved.
//

import SpriteKit

class OptionsMenu: SKScene {

    var easy : SKSpriteNode?
    var medium : SKSpriteNode?
    var hard : SKSpriteNode?
    var impossible : SKSpriteNode?
    var backButton : SKSpriteNode?
    
    override func didMoveToView(view: SKView) {
        easy = self.childNodeWithName("EasyOption") as! SKSpriteNode!
        medium = self.childNodeWithName("MediumOption") as! SKSpriteNode!
        hard = self.childNodeWithName("HardOption") as! SKSpriteNode!
        impossible = self.childNodeWithName("ImpossibleOption") as! SKSpriteNode!
        backButton = self.childNodeWithName("BackToMain") as! SKSpriteNode!
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            print( nodeAtPoint(location).name )
            if( nodeAtPoint(location).name == backButton!.name){
                print("Back Button pressed")
                
                let scene = MainMenu(fileNamed: "MainMenu")
                scene?.scaleMode = .AspectFill
                self.view?.presentScene(scene!, transition: SKTransition.doorsOpenHorizontalWithDuration(1))
            }
        }
    }

}
