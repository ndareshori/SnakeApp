//
//  Segment.swift
//  Segment
//
//  Created by Nick Dareshori on 4/1/20.
//  Copyright © 2020 Nick Dareshori. All rights reserved.
//

import Foundation
import SpriteKit

class Segment {
    
    enum Direction {
        case north
        case east
        case south
        case west
        case none //Used so snake doesn't move at the start of the game before a direction input is given
    }
    
    private let size = CGFloat(32.0)
    
    private var boardPieces: [BoardPiece] = [BoardPiece]()
    private var direction = Direction.none
    private var segment: SKSpriteNode
    private var isTail = false
    private var isHead = false
    private var imageName = "snake_body"
    private var zPosition = CGFloat(1)
    private var rotation = CGFloat(0.0)
    
    init(imageName: String, pieceDirection: Direction){
        segment = SKSpriteNode(imageNamed: imageName)
        direction = pieceDirection
        self.imageName = imageName
        if imageName == "snake_head" {
            isHead = true
        }
    }
    
    //Extra constructor used for making a copy for the extra life feature
    init(imageName: String, pieceDirection: Direction, position: CGPoint, zPosition: CGFloat, rotation: CGFloat){
        segment = SKSpriteNode(imageNamed: imageName)
        direction = pieceDirection
        self.imageName = imageName
        segment.position = position
        segment.zPosition = zPosition
        segment.zRotation = rotation
        segment.scale(to: CGSize(width: size, height: size))
        if imageName == "snake_head" {
            isHead = true
            segment.zPosition = 4
        }
    }
    
    //Sets the direction of the segment
    func setDirection(newDirection: Direction) {
        direction = newDirection
    }

    //returns a direction of the segment
    func getDirection() -> Direction {return direction}

    //returns a segment
    func getSegment() -> SKSpriteNode {return segment}
    
    func isPieceHead() -> Bool {isHead}
    
    func movePiece(moveDistance: CGFloat) {
        if let piece = Gameboard.shared.findPieceAtPoint(point: segment.position) {
            if !piece.isBoardPieceWall() {
                if isPieceHead() {
//                    print("head")
//                    print(direction)
                    piece.setDirection(direction: direction)
//                    print(piece.getDirection())
                    Gameboard.shared.appendActivePiece(piece: piece)
                } else {
                    direction = piece.getDirection()
                }
                if isTail {
                    piece.hideTurn()
                    piece.toggleTurningPoint(isTurning: false)
    //                Gameboard.shared.removeFirstPiece()
                }
            }
            
        }
        if (direction == .north) { //north
            segment.position.y = segment.position.y + moveDistance
        } else if (direction == .east) { //east
                segment.position.x = segment.position.x + moveDistance
        } else if (direction == .south) { //south
                segment.position.y = segment.position.y - moveDistance
        } else if (direction == .west) { //west
                segment.position.x = segment.position.x - moveDistance
        } else {
//            print("?????????????????")
        }
    }
    
    //rotates an image of a segment
    func rotate() {
        if direction == .north {
            rotation = CGFloat.pi
            
        } else if direction == .east {
            rotation = CGFloat.pi / 2.0
            
        } else if direction == .south {
            rotation = CGFloat.pi * 2.0
            
        } else if direction == .west {
            rotation = 3.0 * CGFloat.pi / 2.0
        }
        segment.zRotation = rotation
    }
    
    //All of these are different combinations of what is required to find the correct rotation for each turning possibility. Has to look at the direction of itself as well as the direction of the piece in front of it and behind it.
//    func rotateTurningSegment(directionFront: Direction, directionBehind: Direction) {
//
//        if (directionFront == .east && direction == .east && directionBehind == .south) || //down to right, left to up
//            (directionFront == .north && direction == .north && directionBehind == .west) || (directionFront == .east && direction == .north && directionBehind == .west) || (directionFront == .north && direction == .east && directionBehind == .south) || (directionFront == .south && direction == .east && directionBehind == .south) || (directionFront == .west && direction == .north && directionBehind == .west){
//
//            segment.zRotation = CGFloat.pi
////            changeImage(newImage: 2)
//
//        } else if (directionFront == .west && direction == .west && directionBehind == .north) ||
//            (directionFront == .south && direction == .south && directionBehind == .east) || (directionFront == .west && direction == .south && directionBehind == .east) || (directionFront == .south && direction == .west && directionBehind == .north) || (directionFront == .north && direction == .west && directionBehind == .north) || (directionFront == .east && direction == .south && directionBehind == .east){
//            segment.zRotation = CGFloat.pi * 2.0
////            changeImage(newImage: 2)
//
//        } else if (directionFront == .north && direction == .north && directionBehind == .east) ||
//            (directionFront == .west && direction == .west && directionBehind == .south) || (directionFront == .west && direction == .north && directionBehind == .east) || (directionFront == .north && direction == .west && directionBehind == .south) || (directionFront == .south && direction == .west && directionBehind == .south) || (directionFront == .east && direction == .north && directionBehind == .east){
//            segment.zRotation = 3.0 * CGFloat.pi / 2.0
////            changeImage(newImage: 2)
//
//        } else if (directionFront == .south && direction == .south && directionBehind == .west) ||
//            (directionFront == .east && direction == .east && directionBehind == .north) || (directionFront == .east && direction == .south && directionBehind == .west) || (directionFront == .south && direction == .east && directionBehind == .north) || (directionFront == .north && direction == .east && directionBehind == .north) || (directionFront == .west && direction == .south && directionBehind == .west){
//            segment.zRotation = CGFloat.pi / 2.0
////            changeImage(newImage: 2)
//        }
//
//    }
    
    /*
     0 for body, 1 for tail, 2 for turning body
     */
    func changeImage(newImage: Int) { //
        isTail = false
        if newImage == 0 {
            imageName = "snake_body"
            zPosition = 1
        } else if newImage == 1 {
            imageName = "snake_tail"
            zPosition = 3
            isTail = true
        } else if newImage == 2 {
            imageName = "snake_turning"
            zPosition = 3
        }
        segment.zPosition = zPosition
        segment.texture = SKTexture(imageNamed: imageName)
        
    }
    
    func segmentIsTail() -> Bool {return isTail}
    
    
}

//Allows a copy of the Snake array to be created for use in giving the user an extra life
extension Segment: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        print("name: \(imageName), direction: \(direction)")
        return Segment(imageName: imageName, pieceDirection: direction, position: segment.position, zPosition: zPosition, rotation: rotation)
    }
}


