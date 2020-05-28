//
//  Food.swift
//  Snake
//
//  Created by Nick Dareshori on 4/2/20.
//  Copyright © 2020 Nick Dareshori. All rights reserved.
//
import SpriteKit
import Foundation
import GameplayKit

class Food {
    private var food = SKSpriteNode(imageNamed: "newRealApple")
    private var size = CGFloat(32.0)
    private var smallBoard = true
    
    //Assigns the food a new position on the map that is in bounds for the currently assigned board size
    func dropFood(scene: GameScene)  {
        var xCoord = scene.frame.maxX - 23 - CGFloat(32 * Int.random(in: 1...21))
        var yCoord = CGFloat(1155)
        
        yCoord = 1187 - CGFloat(32 * Int.random(in: 0...24))
        
        //Use this to make sure that the food doesn't spawn directly on top of the snake at the start of the game once user restarts game after dying
        while xCoord == scene.frame.midX && yCoord == scene.frame.midY + 192 {
            
            yCoord = 1187 - CGFloat(32 * Int.random(in: 0...24))
            xCoord = scene.frame.maxX - 23 - CGFloat(32 * Int.random(in: 1...21))
        }
        
        food.position = CGPoint(x: xCoord, y: yCoord)
        print("food dropped at: \(xCoord), \(yCoord)")
    }
    
    //Initializes the food object
    func setFood(scene: GameScene) {
        food.position = CGPoint(x: scene.frame.maxX - 23 - CGFloat(32 * 13), y: 1187 - 32 * 4)
        food.scale(to: CGSize(width: size, height: size))
        food.zPosition = 2
        scene.addChild(food)
    }
    
    //Returns the food node
    func getFood() -> SKSpriteNode {return food}
}
