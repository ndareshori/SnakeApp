//
//  Snake.swift
//  Snake
//
//  Created by Nick Dareshori on 4/6/20.
//  Copyright © 2020 Nick Dareshori. All rights reserved.
//
import Foundation
import SpriteKit

class Snake {
    
    
    private let size = CGFloat(32.0)
        //Distance that the snake moves after each update
    private let moveDistance = CGFloat(4.0)
    //Array of segment objects
    private var snake: [Segment] = [Segment]()

    //Represents how many segments are added to the snake after it eats
    private var numToIncrement = 1
    //Use this so that if user makes two moves before frame updates, only the first one is registered
    //Direction of the head of the snake
    var tailPos = 0
    
    var distanceToTurn = CGFloat(0.0)
    var distanceToBackTurn = CGFloat(0.0)
    var newTurnReady = false
    var newDirection = Segment.Direction.none
    var newTurnIsAhead = true
    
    //Need to keep track of what direction the head of the snake was going before the game was paused so that a turning segment isn't placed if the snake goes the same direction it was going before the game was paused
    private var directionBeforePause = Segment.Direction.none


    func setHead(scene: GameScene) {
        let head = Segment(imageName: "snake_head", pieceDirection: .none)
        
//        if GameScene.levels == GameScene.levels.classic {
//            head.getSegment().position = Gameboard.shared.getBoard()[10][12].getPos()
//        } else {
//            head.getSegment().position = Gameboard.shared.getBoard()[2][22].getPos()
//        }
        head.getSegment().position = Gameboard.shared.getBoard()[2][22].getPos()

        head.getSegment().scale(to: CGSize(width: size, height: size))
        head.getSegment().zPosition = 4
        snake.append(head)
        scene.addChild(head.getSegment())
//        head.setDirection(newDirection: .south)
//        addSegment(scene: scene)
//        addSegment(scene: scene)
    }

    //Adds the assigned number of segments from the bottom of the tail
    func addSegment(scene: GameScene) {
        var i = 0
        while i < numToIncrement {
            let last = snake[snake.count - 1]
            snake.append(Segment(imageName: "snake_body", pieceDirection: last.getDirection()))
            let new = snake[snake.count - 1]
            
            if last.getDirection() == .north {
                new.getSegment().position = CGPoint(x: last.getSegment().position.x, y: last.getSegment().position.y - size)
            } else if last.getDirection() == .east {
                new.getSegment().position = CGPoint(x: last.getSegment().position.x - size, y: last.getSegment().position.y)
            } else if last.getDirection() == .south {
                new.getSegment().position = CGPoint(x: last.getSegment().position.x, y: last.getSegment().position.y + size)
            } else if last.getDirection() == .west {
                new.getSegment().position = CGPoint(x: last.getSegment().position.x + size, y: last.getSegment().position.y)
            } 
            new.getSegment().scale(to: CGSize(width: size, height: size))
            new.getSegment().zPosition = 1
            scene.addChild(new.getSegment())
            i += 1
        }
    }
    
    func getTail() -> Segment {
        return snake.last!
    }
    

    //updates the position of the head first, then each piece after that moves up the chain by one piece
    func update(scene: GameScene) {
        if snake[0].getDirection() != .none {
            if !newTurnReady {
                for seg in snake {
                    seg.movePiece(moveDistance: moveDistance)
                }
            } else if newTurnReady {
                if !newTurnIsAhead {
                    distanceToTurn *= -1
                }
                for seg in snake {
                    if distanceToTurn != 0 {
                        seg.movePiece(moveDistance: distanceToTurn)
                        snake[0].setDirection(newDirection: newDirection)
                    } else {
                        snake[0].setDirection(newDirection: newDirection)
                        seg.movePiece(moveDistance: moveDistance)
                        
                    }
                }
                newTurnReady = false
            } else {
                
            }
            var i = 1
            snake[0].rotate()
            while i < snake.count {
                
                snake[i].rotate()
                
                if i == snake.count - 1 {
                    snake[i].changeImage(newImage: 1)
                    tailPos = i
                    if i != 1 {
                        snake[i - 1].changeImage(newImage: 0)
                    }
                }
                i += 1
            }
//            findTurningPoints()
            
//             if snake.count > 2 {
            //                turningPiece!.startTurnHere(newDirection: newDirection, scene: scene)
            //            } else {
            //                snake[0].setDirection(newDirection: newDirection)
            //            }
//            if let turn = Gameboard.shared.findPieceAtPoint(point: getTail().getSegment().position){
//                if turn.isTurningPoint() {
//                    turn.endTurn()
//                }
//            }
            
        }
//        else {
//            if snake.count > 4 {
//                var i = tailPos
//                let tailDirection = snake[i].getDirection()
//                if i != snake.count - 1 {
//                    snake[i].changeImage(newImage: 0)
//                }
//                while i < snake.count {
//                    snake[i].setDirection(newDirection: tailDirection)
//                    snake[i].rotate()
//
//                    if i == snake.count - 1 {
//                        snake[i].changeImage(newImage: 1)
//                    }
//                    i += 1
//                }
//            }
//        }
    }
    
    //Finds the segments where the snake is turning and sends them to the rotateTurningSegment method of the Segment class in order to find which way to rotate them.
//    func findTurningPoints() {
//        var i = 1
//        while i < snake.count - 1{
//            if (snake[i - 1].getDirection() != snake[i + 1].getDirection() && snake[i-1].getDirection() == snake[i].getDirection()) || (snake[i - 1].getDirection() != snake[i].getDirection() && snake[i-1].getDirection() != snake[i+1].getDirection() && snake[i].getDirection() != snake[i+1].getDirection()) || (snake[i-1].getDirection() == snake[i+1].getDirection() && snake[i+1].getDirection() != snake[i].getDirection()) {
//                
//                snake[i].rotateTurningSegment(directionFront: snake[i - 1].getDirection(), directionBehind: snake[i + 1].getDirection())
//            } else {
//                snake[i].changeImage(newImage: 0)
//            }
//            i += 1
//        }
//    }
    
    func moveBeforePause() {
        let direction = snake[0].getDirection()
        if direction != .none {
            directionBeforePause = direction
        }
        let head = snake[0].getSegment()
        if direction == .east || direction == .west{
            let turnX = Gameboard.shared.turnX(pos: head.position, currentDirection: snake[0].getDirection())
//            turningPoint = CGPoint(x: turnX, y: head.position.y)
            distanceToTurn = abs(turnX.0 - head.position.x)
            if !turnX.1 {
                newTurnIsAhead = false
            } else {
                newTurnIsAhead = true
            }
        }
        else {
            let turnY = Gameboard.shared.turnY(pos: head.position, currentDirection: snake[0].getDirection())
//            turningPoint = CGPoint(x: head.position.x, y: turnY)
            distanceToTurn = abs(turnY.0 - head.position.y)
            if !turnY.1 {
                newTurnIsAhead = false
            } else {
                newTurnIsAhead = true
            }
        }
        if !newTurnIsAhead {
            distanceToTurn *= -1
            print("pause move behind")
        } else {
            print("pause move ahead")
        }
        for seg in snake {
            seg.movePiece(moveDistance: distanceToTurn)
        }
//        print("pause-moved head to \(snake[0].getSegment().position)")
    }
    
    //Empties the snake array and deletes all segments from the game board
    func clearSnake() {
        for segment in snake {
            segment.getSegment().removeFromParent()
        }
        snake.removeAll()
        Gameboard.shared.hideAllTurningSegments()
        
    }

//    func addTurn(turnDirection: Segment.Direction) {
//        queue.enqueue(element: turnDirection)
//    }
    
    //BLOCK MOVEMENT
//    func turnSnake() {
//        if let newDirection = queue.dequeue() {
//            print("Newdirection: \(newDirection)")
//            snake[0].setDirection(newDirection: newDirection)
//        }
//    }
    
    func smoothTurn(direction: Segment.Direction) {
        let oldDirection = snake[0].getDirection()
        var turningPoint = CGPoint(x: 0, y: 0)
        let head = snake[0].getSegment()
        
        
        if snake[0].getDirection() == .none{
            if snake.count == 1 {
                snake[0].setDirection(newDirection: direction)
                turningPoint = snake[0].getSegment().position
            }
            else {
                if directionBeforePause != direction {
                    registerNewTurn(oldDirection: oldDirection, newDirection: direction, turnPosition: head.position)
                    directionBeforePause = .none
                }
                snake[0].setDirection(newDirection: direction)
            }
        } else {
            if direction == .north || direction == .south{
                let turnX = Gameboard.shared.turnX(pos: head.position, currentDirection: snake[0].getDirection())
                if turnX.1 {
                    newTurnIsAhead = true
                } else {
                    newTurnIsAhead = false
                }
                turningPoint = CGPoint(x: turnX.0, y: head.position.y)
                distanceToTurn = abs(turnX.0 - head.position.x)

            }
            else {
                let turnY = Gameboard.shared.turnY(pos: head.position, currentDirection: snake[0].getDirection())
                if turnY.1 {
                    newTurnIsAhead = true
                } else {
                    newTurnIsAhead = false
                }
                turningPoint = CGPoint(x: head.position.x, y: turnY.0)
                distanceToTurn = abs(turnY.0 - head.position.y)

            }
            registerNewTurn(oldDirection: oldDirection, newDirection: direction, turnPosition: turningPoint)
        }
        
    }
    
    func registerNewTurn(oldDirection: Segment.Direction, newDirection: Segment.Direction, turnPosition: CGPoint) {
        let turningPiece = Gameboard.shared.findPieceAtPoint(point: turnPosition)
        if snake.count > 1 {
            turningPiece!.startTurnHere(direction: newDirection)
        }
        newTurnReady = true
        self.newDirection = newDirection
        
        
//        self.newDirection = newDirection
//        self.oldDirection = oldDirection
        
//        Gameboard.shared.turningPointQueue.enqueue(piece: turningPiece, newDirection: newDirection)
        
    }
    
//        if direction == .north || direction == .south{
//            let turnX = Gameboard.shared.turnX(pos: head.position.x)
//            if (snake[0].getDirection() == .north && turnX < head.position.y) || (snake[0].getDirection() == .south && turnX > head.position.y){
//                snake[0].setDirection(newDirection: direction)
//                head.position.x = turnX
//            } else {
//                posQueue.enqueue(element: CGPoint(x: turnX, y: head.position.y))
//                queue.enqueue(element: direction)
//            }
//        }
//        else {
//
//            let turnY = Gameboard.shared.turnY(pos: head.position.y)
//            if (snake[0].getDirection() == .east && turnY < head.position.x) || (snake[0].getDirection() == .west && turnY > head.position.x){
//                snake[0].setDirection(newDirection: direction)
//                head.position.y = turnY
//            } else {
//                posQueue.enqueue(element: CGPoint(x: head.position.x, y: turnY))
//                print("enqueued: \(CGPoint(x: head.position.x, y: turnY))")
//                queue.enqueue(element: direction)
//            }
//
//
//
//        }
//    }
    
    
//
    //Returns the snake array of segment objects
    func getSnake() -> [Segment]{return snake}
    
    //For debugging
    func printSnake() {
        var i = 0
        while i < snake.count {
            print("snake[\(i)] = \(snake[i].getSegment().position)")
            i += 1
        }
    }
}
