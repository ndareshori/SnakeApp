//
//  GameViewController.swift
//  Snake
//
//  Created by Nick Dareshori on 4/1/20.
//  Copyright © 2020 Nick Dareshori. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import GameKit
//import SceneSizer

class GameViewController: UIViewController {

    var controls = GameScene.controlMode.keys
    var userSelectedLevel = GameScene.levels.classic
    
    override func viewDidLoad() {
        super.viewDidLoad()
//            if let view = self.view as! SKView? {
//
//                // Load a GameScene with the size of the view
//                let scene = GameScene(size: view.frame.size)
//
//                // Set the scale mode to scale to fit the window
//                scene.scaleMode = .aspectFit
//
//                // Present the scene
//                view.presentScene(scene)
//
//
//                view.ignoresSiblingOrder = true
//                view.showsFPS = true
//                view.showsNodeCount = true
//
//            }
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = GameScene(fileNamed: "GameScene") {
//                scene.size = SceneSizer.calculateSceneSize(initialSize: view.bounds.size, desiredWidth: 768, desiredHeight: 1024)

                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFit

                // Present the scene
                scene.viewController = self
                scene.controls = controls
                scene.userSelectedLevel = userSelectedLevel
                view.presentScene(scene)

                view.showsFPS = true
            }



            view.ignoresSiblingOrder = true
        }
       
        
    }
    func returnToMenu() {
        self.dismiss(animated: true, completion: nil)
    }
    
    

    override var shouldAutorotate: Bool {
        return true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let skView = self.view as! SKView
        if let scene = skView.scene {
            var size = scene.size
            let newHeight = skView.bounds.size.height / skView.bounds.width * size.width
            if newHeight > size.height {
                scene.anchorPoint = CGPoint(x: 0, y: (newHeight - scene.size.height) / 2.0 / newHeight)
                size.height = newHeight
                scene.size = size
            }
//            skView.frame.height
        }
    }

    
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
