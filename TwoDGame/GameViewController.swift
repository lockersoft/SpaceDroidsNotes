//
//  GameViewController.swift
//  TwoDGame
//
//  Created by Dave Jones on 3/26/16.
//  Copyright (c) 2016 Lockersoft. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

  
  var scene = MainMenu(fileNamed: "MainMenu")
  
  override func viewDidLoad() {
    super.viewDidLoad()

    if let scene = MainMenu(fileNamed:"MainMenu") {
      // Configure the view.
      let skView = self.view as! SKView
      skView.showsFPS = true
      skView.showsNodeCount = true
      skView.showsPhysics = true
            
      /* Sprite Kit applies additional optimizations to improve rendering performance */
      skView.ignoresSiblingOrder = true
          
      /* Set the scale mode to scale to fit the window */
      scene.scaleMode = .AspectFill

     // scene.size = skView.bounds.size //UIScreen.mainScreen().bounds.size
      skView.presentScene(scene)
    }
  }

  
  
  override func shouldAutorotate() -> Bool {
    return true
  }

  override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
    if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
      return .AllButUpsideDown
    } else {
      return .All
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Release any cached data, images, etc that aren't in use.
  }

  override func prefersStatusBarHidden() -> Bool {
    return true
  }
}
