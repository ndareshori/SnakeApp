//
//  Gameboard.swift
//  Snake
//
//  Created by Nick Dareshori on 5/8/20.
//  Copyright © 2020 Nick Dareshori. All rights reserved.
//

import Foundation
import SpriteKit

class Gameboard {
    static let shared = Gameboard()
    private var board = Array(repeating: Array(repeating: BoardPiece(position: CGPoint(x: 0, y: 0)), count: 25), count: 21)
    private var activePieces: [BoardPiece] = [BoardPiece]()
    private var walls: [SKSpriteNode] = [SKSpriteNode]()
    
    func makeBoard(scene: GameScene) {
        walls.removeAll()
        for y in 0...24 {
            for x in 0...20 {
                let xpos = 55 + (32 * x)
                let ypos = 419 + (32 * y)
                var isLight = true
                if y % 2 == 0 && x % 2 == 0{
                    isLight = true
                } else if y % 2 != 0 && x % 2 != 0{
                    isLight = true
                } else {
                    isLight = false
                }
                board[x][y] = BoardPiece(x: CGFloat(xpos), y: CGFloat(ypos), scene: scene, direction: Segment.Direction.none, isLight: isLight)
            }
        }
        print("board made")
    }
    
    func getBoard() -> [[BoardPiece]] {return board}
    
    func makeWalls(level: GameScene.levels) {
        if level == GameScene.levels.level1 {
            var x = 2
            while x < 19 {
                board[x][12].changeBoardPieceToWall()
                walls.append(board[x][12].getBoardPiece())
                x += 1
            }
            var y = 3
            while y < 22 {
                board[10][y].changeBoardPieceToWall()
                walls.append(board[10][y].getBoardPiece())
                y += 1
            }
            print("made wall")
        }
        
    }
    func getWalls() -> [SKSpriteNode] {return walls}
    
    func turnX(pos: CGPoint, currentDirection: Segment.Direction) -> (CGFloat, Bool) {
        var min = CGFloat(303.0)
        var closestX = 0
        var turnIsAhead = true
        for j in 0...20 {
            let row = findRowWithY(ypos: pos.y)
            let currentXPos = board[j][0].getX()
            if (abs(currentXPos - pos.x) < min) {
                if !board[j][row].isTurningPoint() {
                    min = abs(currentXPos - pos.x)
                    closestX = j
                    if (currentDirection == .east && pos.x <= board[j][0].getX()) || (currentDirection == .west && pos.x >= board[j][0].getX()){
                        turnIsAhead = true
                    } else {
                        turnIsAhead = false
                    }
                } else {
                    print("NOT turning at board[\(j)][\(row)], its already a turn!")
                }
                
            }
        }
        return (board[closestX][0].getX(), turnIsAhead)
    }
    
    func turnY(pos: CGPoint, currentDirection: Segment.Direction) -> (CGFloat, Bool) {
        var min = CGFloat(303.0)
        var closestY = 0
        var turnIsAhead = true
        for j in 0...24 {
            let column = findColumnWithX(xpos: pos.x)
            let currentYPos = board[0][j].getY()
            if (abs(currentYPos - pos.y) < min) {
                if !board[column][j].isTurningPoint() {
                    min = abs(currentYPos - pos.y)
                    closestY = j
                    if (currentDirection == .north && pos.y <= board[0][j].getY()) || (currentDirection == .south && pos.y >= board[0][j].getY()) {
                        turnIsAhead = true
                        } else {
                            turnIsAhead = false
                        }
                }else {
                    print("NOT turning at board[\(column)][\(j)], it's already a turn")
                }
            }
        }
        return (board[0][closestY].getY(), turnIsAhead)
    }
    
    func findPieceAtPoint(point: CGPoint) -> BoardPiece? {
        var column = -1
        var row = -1
        for x in 0...20 {
            if board[x][0].getX() == point.x {
                column = x
            }
        }
        for y in 0...24 {
            if board[0][y].getY() == point.y {
                row = y
            }
        }
        if column == -1 || row == -1 {
            return nil
        }
        return board[column][row]
    }
    
    func findRow(point: CGPoint) -> Int {
        var row = -1
     
        for y in 0...24 {
            if board[0][y].getY() == point.y {
                row = y
            }
        }
        return row
    }
    
    func findRowWithY(ypos: CGFloat) -> Int {
        var row = -1
     
        for y in 0...24 {
            if board[0][y].getY() == ypos {
                row = y
            }
        }
        return row
    }
    
    func findColumnWithX(xpos: CGFloat) -> Int {
        var column = -1
        for x in 0...20 {
            if board[x][0].getX() == xpos {
                column = x
            }
        }
        return column
    }
    
    func findColumn(point: CGPoint) -> Int {
        var column = -1
        for x in 0...20 {
            if board[x][0].getX() == point.x {
                column = x
            }
        }
        return column
    }
    
    func hideAllTurningSegments() {
        for y in 0...24 {
            for x in 0...20 {
                if !board[x][y].isBoardPieceWall() {
                    board[x][y].endTurn()
                    board[x][y].toggleTurningPoint(isTurning: false)
                }
//                else {
//                    board[x
//                }
            }
        }
    }
    
    //once the head moves over a board piece, it is added to the activePieces array
    func appendActivePiece(piece: BoardPiece) {
        activePieces.append(piece)
//        print("appended \(piece.getPos())")
        var i = 1
        while i < activePieces.count{
            if activePieces[i].isTurningPoint() && !activePieces[i].checkIfHidden(){
                if i == activePieces.count - 1 {
                    let turn = activePieces[i].getBoardPiece()
                    let cd = activePieces[i].getDirection()
                    let ld = activePieces[i - 1].getDirection()
                    if (ld == .south && cd == .east) || (ld == .west && cd == .north) {
                        turn.zRotation = CGFloat.pi
                    } else if (ld == .east && cd == .north) || (ld == .south && cd == .west) {
                        turn.zRotation = 3.0 * CGFloat.pi / 2.0
                    } else if (ld == .north && cd == .west) || (ld == .east && cd == .south) {
                        turn.zRotation = CGFloat.pi * 2.0
                    } else if (ld == .west && cd == .south) || (ld == .north && cd == .east){
                        turn.zRotation = CGFloat.pi / 2.0
                    }
                } else {
                    activePieces[i].rotate(pieceInFront: activePieces[i + 1], pieceBehind: activePieces[i - 1])
                }
            }
            i += 1
        }
    }
    
//    func removeFirstPiece() {
////        print("removed a piece")
//        activePieces.removeFirst()
//    }
    
}
