
//
//  BoardPiece.swift
//  Snake
//
//  Created by Nick Dareshori on 5/9/20.
//  Copyright © 2020 Nick Dareshori. All rights reserved.
//

import Foundation
import SpriteKit

class BoardPiece {
//    private var column = 0
//    private var row = 0
    private var x = CGFloat(0.0)
    private var y = CGFloat(0.0)
    private var position = CGPoint(x: 0, y: 0)
    private var turningPoint = false
    private var boardPiece: SKSpriteNode
    private var direction = Segment.Direction.none
    private var size = 32
    private var hidden = false
    private var isWall = false
    private var isLight = false
    
    
    
    
    init(position: CGPoint) {
        self.position = position
        self.x = position.x
        self.y = position.y
        boardPiece = SKSpriteNode(imageNamed: "snake_turning")
        turningPoint = false
//        boardPiece = SKSpriteNode(imageNamed: "snake_turning")
//        boardPiece.position = position
    }
    
    init(x: CGFloat, y: CGFloat, scene: GameScene, direction: Segment.Direction, isLight: Bool) {
        self.position = CGPoint(x: x, y: y)
        self.x = x
        self.y = y
        self.isLight = isLight
        if isLight {
            boardPiece = SKSpriteNode(imageNamed: "snake_turning_light")
        } else {
            boardPiece = SKSpriteNode(imageNamed: "snake_turning_dark")
        }
        boardPiece.position = position
        boardPiece.scale(to: CGSize(width: CGFloat(size), height: CGFloat(size)))
        boardPiece.zPosition = 2
        boardPiece.isHidden = true
        scene.addChild(boardPiece)
        self.direction = direction
        turningPoint = false
        
    }
    
    func getX() -> CGFloat {return x}
    func getY() -> CGFloat {return y}
    func getPos() -> CGPoint {return position}
    
    func startTurnHere(direction: Segment.Direction) {
        boardPiece.isHidden = false
        hidden = false
        turningPoint = true
        self.direction = direction
        if direction == .north {
            boardPiece.zRotation = CGFloat.pi    // -
                                           // D -
            
        } else if direction == .east {
            boardPiece.zRotation = CGFloat.pi / 2.0 // D -
                                              // -
            
        } else if direction == .south {
            boardPiece.zRotation = CGFloat.pi * 2.0 // - D
                                              //   -
            
        } else if direction == .west {              //   -
            boardPiece.zRotation = 3.0 * CGFloat.pi / 2.0 // - D
        }
    }
    
    func changeBoardPieceToWall() {
        isWall = true
        boardPiece.texture = SKTexture(imageNamed: "brick")
        boardPiece.isHidden = false
    }
    
    func changeWallPieceToNormal() {
        isWall = false
        if isLight {
            boardPiece.texture = SKTexture(imageNamed: "snake_turning_light")
        } else {
            boardPiece.texture = SKTexture(imageNamed: "snake_turning_dark")
        }
    }
    
    func isBoardPieceWall() -> Bool {return isWall}
    
    

    func endTurn() {
        hideTurn()
        turningPoint = false
        setDirection(direction: Segment.Direction.none)
    }
    
    func hideTurn() {
        boardPiece.isHidden = true
        hidden = true
    }
    
    func isTurningPoint() -> Bool {return turningPoint}
    
    func toggleTurningPoint(isTurning: Bool) {
        if !isTurning {
            turningPoint = false
        } else {
            turningPoint = true
        }
    }
    
    func checkIfHidden() -> Bool {return hidden}
    
    func getDirection() -> Segment.Direction {return direction}
    
    func getBoardPiece() -> SKSpriteNode {return boardPiece}
    
    func setDirection(direction: Segment.Direction) {
        self.direction = direction
    }
    
    func rotate(pieceInFront: BoardPiece, pieceBehind: BoardPiece) {
            
        let directionFront = pieceInFront.getDirection()
        let directionBehind = pieceBehind.getDirection()
        
        if (directionFront == .east && direction == .east && directionBehind == .south) || //down to right, left to up
            (directionFront == .north && direction == .north && directionBehind == .west) || (directionFront == .east && direction == .north && directionBehind == .west) || (directionFront == .north && direction == .east && directionBehind == .south) || (directionFront == .south && direction == .east && directionBehind == .south) || (directionFront == .west && direction == .north && directionBehind == .west){
            
            boardPiece.zRotation = CGFloat.pi
//            changeImage(newImage: 2)
            
        } else if (directionFront == .west && direction == .west && directionBehind == .north) ||
            (directionFront == .south && direction == .south && directionBehind == .east) || (directionFront == .west && direction == .south && directionBehind == .east) || (directionFront == .south && direction == .west && directionBehind == .north) || (directionFront == .north && direction == .west && directionBehind == .north) || (directionFront == .east && direction == .south && directionBehind == .east){
            boardPiece.zRotation = CGFloat.pi * 2.0
//            changeImage(newImage: 2)

        } else if (directionFront == .north && direction == .north && directionBehind == .east) ||
            (directionFront == .west && direction == .west && directionBehind == .south) || (directionFront == .west && direction == .north && directionBehind == .east) || (directionFront == .north && direction == .west && directionBehind == .south) || (directionFront == .south && direction == .west && directionBehind == .south) || (directionFront == .east && direction == .north && directionBehind == .east){
            boardPiece.zRotation = 3.0 * CGFloat.pi / 2.0
//            changeImage(newImage: 2)
            
        } else if (directionFront == .south && direction == .south && directionBehind == .west) ||
            (directionFront == .east && direction == .east && directionBehind == .north) || (directionFront == .east && direction == .south && directionBehind == .west) || (directionFront == .south && direction == .east && directionBehind == .north) || (directionFront == .north && direction == .east && directionBehind == .north) || (directionFront == .west && direction == .south && directionBehind == .west){
            boardPiece.zRotation = CGFloat.pi / 2.0
//            changeImage(newImage: 2)
        }
            
    }
        
        
}
