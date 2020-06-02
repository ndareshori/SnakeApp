//
//  GameScene.swift
//  Snake
//
//  Created by Nick Dareshori on 4/1/20.
//  Copyright © 2020 Nick Dareshori. All rights reserved.
//
/*
 Todo:
 Difficulty option, different speeds
 Make options on main menu text black
 
 Options on game screen
 */

import SpriteKit
import GameKit
import GameplayKit
import UIKit

extension UIView {
       var snapshot: UIImage? {
           UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
           defer { UIGraphicsEndImageContext() }
           drawHierarchy(in: bounds, afterScreenUpdates: true)
           return UIGraphicsGetImageFromCurrentImageContext()
       }
}


class GameScene: SKScene {
    
    
    //Initializers for arrow keys
    private var up = SKSpriteNode(imageNamed: "arrow")
    private var down = SKSpriteNode(imageNamed: "arrow")
    private var left = SKSpriteNode(imageNamed: "arrow")
    private var right = SKSpriteNode(imageNamed: "arrow")
    private var keys = [SKSpriteNode]()
    
    private var background: SKSpriteNode?
    
    //Initializers for swipe gestures
    private let swipeRightRec = UISwipeGestureRecognizer()
    private let swipeLeftRec = UISwipeGestureRecognizer()
    private let swipeUpRec = UISwipeGestureRecognizer()
    private let swipeDownRec = UISwipeGestureRecognizer()
    
    private var panRec: UIPanGestureRecognizer!
    private var lastSwipeBeginningPoint: CGPoint?
    
    //boolean passed through the segue, if true user will use arrow controls. if false they will use swipe gestures
    enum controlMode {
        case keys
        case swipe
        case joystick
    }
    var controls = controlMode.keys
    
    enum levels {
        case classic
        case level1
    }
    var userSelectedLevel = levels.level1
    
    //Assetts
    private var runningScoreLabel : SKLabelNode?
    private var runningScorePanel : SKSpriteNode?
    
    private var gameBG : SKSpriteNode?
    private var arrowBG : SKSpriteNode?
    
    private var verticalPanel : SKSpriteNode?
    private var finalScoreLabel : SKLabelNode?
    private var highScoreLabel : SKLabelNode?
    private var mainMenuButton : SKSpriteNode?
    private var playAgainButton : SKSpriteNode?
    
    private var pauseButton : SKSpriteNode?
    private var pauseMenu : SKSpriteNode?
    private var pauseMenuResumeGameButton : SKSpriteNode?
    private var pauseMenuRestartGameButton : SKSpriteNode?
    private var pauseMenuExitGameButton : SKSpriteNode?
    private var viewButton : SKSpriteNode?
    private var closeViewButton : SKSpriteNode?
    
    private var extraLifePanel: SKSpriteNode?
    private var useExtraLife: SKSpriteNode?
    private var dontUseExtraLife: SKSpriteNode?
    
    private var extraLifeRightButton: SKSpriteNode?
    private var extraLifeLeftButton: SKSpriteNode?
    private var extraLifeConfirmButton: SKSpriteNode?
    
    private var shareButton : SKSpriteNode?
    //Used to handle the game functions, i.e pausing or ending the game
    //Object of the Snake class made up of an array of Segment objects
    private var snake = Snake()
    //Object of the score class
    var score = Score()
    private var game = Game()
    //Object of the Food class
    private var food = Food()
    //VC object used to unwind the segue
    var viewController: GameViewController?
    
    private var copies = SnakeCopies()
    //Minimum Y value, set to 400 on default but will be changed to 0 if the user is using swipe controls
    private let minY = 400
    private let maxY = 1207
    private let fps = 60
    
    
    
    var image: UIImage?
    
    private let base = SKSpriteNode(imageNamed: "joystickBase")
    private let ball = SKSpriteNode(imageNamed: "joystickButton")
        
    private var extraLifeUsed = false
    
    private var vibrate = Vibrations()
    var stickActive = false
    
    private var badDirectionAfterPause = Segment.Direction.none
    
        
    //Called when the scene loads, initializes all the nodes and plays the in game music
    override func didMove(to view: SKView) {
        Gameboard.shared.makeBoard(scene: self)
        if userSelectedLevel != levels.classic {
            Gameboard.shared.makeWalls(level: userSelectedLevel)
        }
        print("Did move called")
        
//        // Set (0, 0) as the centre of the screen
//        scene?.anchorPoint = CGPoint(x: 0.0, y: 0.0)

        // Create the frame
//        let frameEdge = SKPhysicsBody(edgeLoopFrom: frame)
//        self.physicsBody = frameEdge
        
        //Paused the game when the user gets a call
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(pauseAfterNotif), name: UIApplication.willResignActiveNotification, object: nil)
        
    
        
        MusicPlayer.shared.stopBackgroundMusic()
        MusicPlayer.shared.startBackgroundMusic(songInt: 1)
        
        pauseButton = self.childNode(withName: "pauseButton") as? SKSpriteNode
        pauseButton?.position = CGPoint(x: frame.maxX - 62, y: frame.maxY - 50)
        pauseButton?.name = "pauseButton"
        pauseMenu = self.childNode(withName: "pauseMenu") as? SKSpriteNode
        pauseMenuResumeGameButton = self.pauseMenu?.childNode(withName: "pauseMenuResumeGameButton") as? SKSpriteNode
        pauseMenuResumeGameButton?.name = "pauseMenuResumeGameButton"
        pauseMenuRestartGameButton = self.pauseMenu?.childNode(withName: "pauseMenuRestartGameButton") as? SKSpriteNode
        pauseMenuRestartGameButton?.name = "pauseMenuRestartGameButton"
        pauseMenuExitGameButton = self.pauseMenu?.childNode(withName: "pauseMenuExitGameButton") as? SKSpriteNode
        pauseMenuExitGameButton?.name = "pauseMenuExitGameButton"
        
        
        verticalPanel = self.childNode(withName: "verticalPanel") as? SKSpriteNode
        finalScoreLabel = self.verticalPanel?.childNode(withName: "finalScoreLabel") as? SKLabelNode
        highScoreLabel = self.verticalPanel?.childNode(withName: "highScoreLabel") as? SKLabelNode
        playAgainButton = self.childNode(withName: "playAgainButton") as? SKSpriteNode
        playAgainButton?.name = "playAgainButton"
        
        mainMenuButton = self.childNode(withName: "mainMenuButton") as? SKSpriteNode
        mainMenuButton?.name = "mainMenuButton"
        
        extraLifePanel = self.childNode(withName: "extraLifePanel") as? SKSpriteNode
        dontUseExtraLife = self.extraLifePanel?.childNode(withName: "dontUseExtraLife") as? SKSpriteNode
        useExtraLife = self.extraLifePanel?.childNode(withName: "useExtraLife") as? SKSpriteNode
        
        extraLifeLeftButton = self.childNode(withName: "extraLifeLeftButton") as? SKSpriteNode
        extraLifeRightButton = self.childNode(withName: "extraLifeRightButton") as? SKSpriteNode
        extraLifeConfirmButton = self.childNode(withName: "extraLifeConfirmButton") as? SKSpriteNode
        
        gameBG = self.childNode(withName: "gameBG") as? SKSpriteNode
//        arrowBG = self.childNode(withName: "arrowBG") as? SKSpriteNode
        runningScorePanel = self.childNode(withName: "runningScorePanel") as? SKSpriteNode
        runningScoreLabel = self.childNode(withName: "runningScoreLabel") as? SKLabelNode
        runningScoreLabel?.text = "Score: \(score.getScore())" //used to set initial score label to display a score of 0
        
        shareButton = self.childNode(withName: "shareButton") as? SKSpriteNode
        shareButton?.name = "shareButton"
        
        viewButton = self.childNode(withName: "viewButton") as? SKSpriteNode
        viewButton?.name = "viewButton"
        
        closeViewButton = self.childNode(withName: "closeViewButton") as? SKSpriteNode
        closeViewButton?.name = "closeViewButton"
        
        
        
        if controls == .keys {
            up.position = CGPoint(x: frame.midX, y: frame.minY + 325)
            up.scale(to: CGSize(width: 175, height: 175))
            up.zRotation = CGFloat.pi / 2.0
            up.zPosition = 1
            addChild(up)
            keys.append(up)
            
            right.position = CGPoint(x: frame.midX + 150, y: frame.minY + 200)
            right.scale(to: CGSize(width: 175, height: 175))
            right.name = "right"
            addChild(right)
            keys.append(right)

            down.position = CGPoint(x: frame.midX, y: frame.minY + 75)
            down.scale(to: CGSize(width: 175, height: 175))
            down.zRotation = 3 * CGFloat.pi / 2.0
            down.name = "down"
            addChild(down)
            keys.append(down)

            left.position = CGPoint(x: frame.midX - 150, y: frame.minY + 200)
            left.scale(to: CGSize(width: 175, height: 175))
            left.zRotation = CGFloat.pi
            left.name = "left"
            addChild(left)
            keys.append(left)

            

        } else if controls == .swipe {
            
            // Create the gesture recognizer for panning
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanFrom))
            // Add the gesture recognizer to the scene's view
            self.view!.addGestureRecognizer(panGestureRecognizer)
         } else if controls == .joystick {
            base.position = CGPoint(x: frame.midX, y: 200)
            base.zPosition = 1
            base.scale(to: CGSize(width: 350, height: 350))
            ball.zPosition = 2
            ball.scale(to: CGSize(width: 150, height: 150))
            ball.position = base.position
            addChild(base)
            addChild(ball)
        }

        food.setFood(scene: self)
        snake.setHead(scene: self)

        self.view?.preferredFramesPerSecond = fps
        
//        if game.isGamePaused {
//            game.resumeGameFromPause()
//        }

    }
    
    
    
    //Hides/unhides all the views when the game ends
    func toggleViews() {
        verticalPanel?.isHidden = !verticalPanel!.isHidden
        playAgainButton?.isHidden = !playAgainButton!.isHidden
        runningScorePanel?.isHidden = !runningScorePanel!.isHidden
        runningScoreLabel?.isHidden = !runningScoreLabel!.isHidden
        shareButton?.isHidden = !shareButton!.isHidden
    }
    
    //Tracks what node is touched
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            
            let touchPosition = touch.location(in: self)
            let touchNode = self.atPoint(touchPosition)
            if controls == .keys {
                print("touchpos: \(touchPosition)")
                if touchPosition.y < 600 && !game.isGamePaused{
                    let currentDirection = snake.getSnake()[0].getDirection()
                    let touchResult = findClosestKey(touch: touchPosition)
                    if touchResult.0 || currentDirection == .none{
                        if touchResult.1 == up {
                            changeDirection(direction: .north)
                        } else if touchResult.1 == right {
                            changeDirection(direction: .east)
                        } else if touchResult.1 == down {
                            changeDirection(direction: .south)
                        } else if touchResult.1 == left {
                            changeDirection(direction: .west)
                        }
                    } else {
                        if ((currentDirection == .east || currentDirection == .west) && (touchResult.1 == up || touchResult.2 == up)) {
                            changeDirection(direction: .north)
                        } else if ((currentDirection == .north || currentDirection == .south) && (touchResult.1 == right || touchResult.2 == right)) {
                            changeDirection(direction: .east)
                        } else if ((currentDirection == .east || currentDirection == .west) && (touchResult.1 == down || touchResult.2 == down)) {
                            changeDirection(direction: .south)
                        } else if ((currentDirection == .north || currentDirection == .south) && (touchResult.1 == left || touchResult.2 == left)) {
                            changeDirection(direction: .west)
                        }
                    }
                }
            }
           
            
//            else
            if touchNode.name == "playAgainButton" {
                startNewGame()
            } else if touchNode.name == "mainMenuButton" {
                MusicPlayer.shared.playSoundEffect(soundType: .button)
                returnToMenu()
            } else if touchNode == pauseButton {
                MusicPlayer.shared.playSoundEffect(soundType: .button)
                pauseGame()
            } else if touchNode.name == "pauseMenuResumeGameButton" {
                MusicPlayer.shared.playSoundEffect(soundType: .button)
                resumeGameFromPause()
            } else if touchNode.name == "pauseMenuRestartGameButton" {
                resumeGameFromPause()
                cancelExtraLife()
                startNewGame()
            } else if touchNode.name == "pauseMenuExitGameButton" {
                MusicPlayer.shared.playSoundEffect(soundType: .button)
                resumeGameFromPause()
                gameOver()
                returnToMenu()
            } else if touchNode.name == "shareButton" {
                MusicPlayer.shared.playSoundEffect(soundType: .button)
                shareScore()
            } else if touchNode.name == "viewButton" {
                MusicPlayer.shared.playSoundEffect(soundType: .button)
                toggleViews()
                closeViewButton?.isHidden = false
            } else if touchNode.name == "closeViewButton" {
                MusicPlayer.shared.playSoundEffect(soundType: .button)
                toggleViews()
                closeViewButton?.isHidden = true
            } else if touchNode == dontUseExtraLife {
                cancelExtraLife()
                MusicPlayer.shared.playSoundEffect(soundType: .button)
            } else if touchNode == useExtraLife {
                activateExtraLife()
                MusicPlayer.shared.playSoundEffect(soundType: .button)
            } else if touchNode == extraLifeLeftButton {
                MusicPlayer.shared.playSoundEffect(soundType: .button)
                snake.moveViews(scene: self, side: 0)
            } else if touchNode == extraLifeRightButton {
                MusicPlayer.shared.playSoundEffect(soundType: .button)
                snake.moveViews(scene: self, side: 1)
            } else if touchNode == extraLifeConfirmButton {
                MusicPlayer.shared.playSoundEffect(soundType: .button)
                resumeWithExtraLife()
            }
            if touchNode == base || touchNode == ball {
                stickActive = true
            } else {
                stickActive = false
            }
        }
    }
        
    //Uses the pythagorean theorem to determine to closest arrow key to wherever the user touched on the bottom portion of the screen, if the touch position is in the middle of two buttons, it returns both buttons
    func findClosestKey(touch: CGPoint) -> (Bool, SKSpriteNode, SKSpriteNode) {
        var closestDistance = CGFloat(99999999999)
        var secondClosestDistance = CGFloat(9999999999999)
        var closestKey = up
        var secondClosestKey = right
        var isTouchSpecific = true
        
//        print("")
        for key in keys {
            let distanceFromKey = pow(abs(key.position.x - touch.x), 2) + pow(abs(key.position.y - touch.y), 2)
//            print("for key: \(key.name ?? "up") the distance is \(distanceFromKey)")
            if distanceFromKey < closestDistance {
                secondClosestKey = closestKey
                closestKey = key
                secondClosestDistance = closestDistance
                closestDistance = distanceFromKey
            } else if distanceFromKey < secondClosestDistance {
                secondClosestKey = key
                secondClosestDistance = distanceFromKey
            }
        }
//        print("closest is \(closestKey.name ?? "up"): \(closestDistance)")
//        print("second closest is \(secondClosestKey.name ?? "up"): \(secondClosestDistance)")
        if abs(closestDistance - secondClosestDistance) < CGFloat(12000) {
            isTouchSpecific = false
        }
        return (isTouchSpecific, closestKey, secondClosestKey)
    }
    
    func changeDirection(direction: Segment.Direction) {
        
        //BLOCK MOVEMENT
//        let lastDirection = getLastDirection()
//
//        if !game.getPauseStatus() {
//            if lastDirection == .north {
//                if direction != .north && direction != .south {
//                    snake.queue.enqueue(element: direction)
//                    vibrate.vibrate()
//                }
//            } else if lastDirection == .east {
//                if direction != .east && direction != .west {
//                    snake.queue.enqueue(element: direction)
//                    vibrate.vibrate()
//                }
//            } else if lastDirection == .south {
//                if direction != .north && direction != .south {
//                    snake.queue.enqueue(element: direction)
//                    vibrate.vibrate()
//                }
//            } else if lastDirection == .west {
//                if direction != .east && direction != .west {
//                    snake.queue.enqueue(element: direction)
//                    vibrate.vibrate()
//                }
//            } else if lastDirection == .none {
//                if direction != badDirectionAfterPause {
//                    snake.queue.enqueue(element: direction)
//                    vibrate.vibrate()
//                }
//            }
//        }
        let lastDirection = getLastDirection()
        print("LAST DIRECT: \(lastDirection)")
        
        if !game.getPauseStatus() {
            if lastDirection == .north {
                if direction != .north && direction != .south {
                    snake.smoothTurn(direction: direction)
                    vibrate.vibrate()
                }
            } else if lastDirection == .east {
                if direction != .east && direction != .west {
                    snake.smoothTurn(direction: direction)
                    vibrate.vibrate()
                }
            } else if lastDirection == .south {
                if direction != .north && direction != .south {
                    snake.smoothTurn(direction: direction)
                    vibrate.vibrate()
                }
            } else if lastDirection == .west {
                if direction != .east && direction != .west {
                    snake.smoothTurn(direction: direction)
                    vibrate.vibrate()
                }
            } else if lastDirection == .none {
                if direction != badDirectionAfterPause {
                    snake.smoothTurn(direction: direction)
                    vibrate.vibrate()
                } else {
                    print("welp")
                }
            }
        }
    }
    
    func getLastDirection() -> Segment.Direction {
        let currentDirection = snake.getSnake()[0].getDirection()
//        let lastSend = snake.queue.getLast()
//        if lastSend != nil {
//            return lastSend!
//        } else {
//            return currentDirection
//        }
        return currentDirection
    }
    
    @objc func handlePanFrom(_ recognizer: UIPanGestureRecognizer) {
        if recognizer.state != .cancelled {
            let translation = recognizer.translation(in: recognizer.view)

            
            let xDif = translation.x
            let yDif = translation.y
            
            
            if abs(xDif) > abs(yDif) + 15 {
                if xDif > 0 {
                    changeDirection(direction: .east)
                    recognizer.setTranslation(CGPoint(x: 0, y: 0), in: self.view)
                } else {
                    changeDirection(direction: .west)
                    recognizer.setTranslation(CGPoint(x: 0, y: 0), in: self.view)
                }
            } else if abs(yDif) > abs(xDif) + 15 {
                if yDif > 0 {
                    changeDirection(direction: .south)
                    recognizer.setTranslation(CGPoint(x: 0, y: 0), in: self.view)
                } else {
                    changeDirection(direction: .north)
                    recognizer.setTranslation(CGPoint(x: 0, y: 0), in: self.view)
                }
            }
        }
    }
            
            
//            let xDif = translation.x
//            let yDif = translation.y
//            let checkDifX = xDif - x1
//            let checkDifY = yDif - y1
//
//            if abs(checkDifX) > abs(checkDifY) + 20{
//                if checkDifX > 0 {
//                    changeDirection(direction: .east)
//                    x1 = xDif
//                    y1 = yDif
//                    print("\(checkDifX), \(checkDifY)")
//                } else {
//                    changeDirection(direction: .west)
//                    x1 = xDif
//                    y1 = yDif
//                    print("\(checkDifX), \(checkDifY)")
//                }
//            } else if abs(checkDifY) > abs(checkDifX) + 20{
//                if checkDifY > 0 {
//                    changeDirection(direction: .south)
//                    x1 = xDif
//                    y1 = yDif
//                    print("\(checkDifX), \(checkDifY)")
//                } else {
//                    changeDirection(direction: .north)
//                    x1 = xDif
//                    y1 = yDif
//                    print("\(checkDifX), \(checkDifY)")
//                }
//            }
            
        
    
    @objc func pauseAfterNotif() {
//        if snake.getSnake()[0].getSegment().position.y >= 1251 {
//            pauseGame()
//        }
        if !game.getPauseStatus() {
            pauseGame()
            print("notif detected")
        }
    }
    
    //Segues back to the main menu and plays the menu song
    func returnToMenu() {
        MusicPlayer.shared.stopBackgroundMusic()
        MusicPlayer.shared.startBackgroundMusic(songInt: 0)
        viewController?.returnToMenu()
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            let location = touch.location(in: self)

            if stickActive == true {
                let v = CGVector(dx: location.x - base.position.x, dy: location.y - base.position.y)
                let angle = atan2(v.dy, v.dx)

                let degrees = angle * CGFloat(180.0 / Double.pi) + 180
                let length: CGFloat = base.frame.size.height / 2 - 20

                let xDist: CGFloat = sin(angle - 1.57079633) * length
                let yDist: CGFloat = cos(angle - 1.57079633) * length

                ball.position = CGPoint(x: base.position.x - xDist, y: base.position.y + yDist)

                if base.frame.contains(location) {
                    ball.position = location
                } else {
                    ball.position = CGPoint(x: base.position.x - xDist, y: base.position.y + yDist)
                }
                
                if degrees > 45 && degrees < 135 {
                    if ball.position.y < 125 {
                        changeDirection(direction: .south)
                    }
                } else if degrees > 135 && degrees < 225 {
                    if ball.position.x > 450 {
                        changeDirection(direction: .east)
                    }
                } else if degrees > 225 && degrees < 315 {
                    if ball.position.y > 275 {
                        changeDirection(direction: .north)
                    }
                } else if degrees > 315 || degrees < 45 {
                    if ball.position.x < 300 {
                        changeDirection(direction: .west)
                    }
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if stickActive {
//            let move: SKAction = SKAction.move(to: base.position, duration: 0.2)
//            move.timingMode = .easeOut
//
//            ball.run(move)
//        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    

    
    //Pauses/Unpauses the game by setting a boolean to true and then toggles the paused menus
    func pauseGame() {
        if !game.getPauseStatus(){
            snake.moveBeforePause()
            print("GameScene pause function called")
            game.pauseGame()
            togglePauseViews()
        } else {
            print("***Tried to pause the game but it was already paused!***")
        }
    }
    func resumeGameFromPause() {
        if game.getPauseStatus() {
//            if !snake.queue.isEmpty() {
//                snake.queue.clearAllElements()
//            }
            togglePauseViews()
            game.resumeGameFromPause()
            let head = snake.getSnake()[0]
            FindOppositeDirectionBeforePause(directionBeforePause: head.getDirection())
            head.setDirection(newDirection: .none)
        } else {
            print("***Tried to resume the game but it was not paused!***")
        }
    }
    func FindOppositeDirectionBeforePause(directionBeforePause: Segment.Direction) {
        if directionBeforePause == .north {
            badDirectionAfterPause = .south
        } else if directionBeforePause == .east {
            badDirectionAfterPause = .west
        } else if directionBeforePause == .south {
            badDirectionAfterPause = .north
        } else if directionBeforePause == .west {
            badDirectionAfterPause = .east
        }
    }
    
    func togglePauseViews() {
        pauseMenu?.isHidden = !pauseMenu!.isHidden
        pauseButton?.isHidden = !pauseButton!.isHidden
    }
    
    
    // Called before each frame is rendered
    // Checks to see if there has been a game ending-collision, if there hasn't it calls the update method of the
    // snake class, if there has it ends the game
    override func update(_ currentTime: TimeInterval) {
       
        if (!game.getPauseStatus()) {
            if !checkCollisions() {
                snake.update(scene: self)
            } else {
                print("collission detected, game over!")
                gameOver()
            }
        }
           
    }
    
    //Ends the game and displays final scores
    func gameOver() {
        snake.printSnake()
        pauseButton?.isHidden = true
        image = (view?.snapshot)!
        game.pauseGame()
        
        if !extraLifeUsed {
            extraLifePanel?.isHidden = false
            useExtraLife?.isHidden = false
            dontUseExtraLife?.isHidden = false
        } else {
            cancelExtraLife()
        }
    }
    
    func cancelExtraLife() {
        let userScore = score.getScore()
        let userHighscore = score.getHighScore()
        if userScore > userHighscore {
//            Fireworks.start(view: self.view!)
        }
        finalScoreLabel?.text = "Score: \(userScore)"
        score.calculateHighScore()
        highScoreLabel?.text = "Highscore: \(score.getHighScore())"
        toggleViews()
        extraLifePanel?.isHidden = true
        useExtraLife?.isHidden = true
        dontUseExtraLife?.isHidden = true
    }
    
    func activateExtraLife() {
        print("swear to god")
        copies.bprint()
        snake.showCopies(scene: self)
        snake.clearSnake()
        extraLifePanel?.isHidden = true
        useExtraLife?.isHidden = true
        dontUseExtraLife?.isHidden = true
        
        extraLifeConfirmButton?.isHidden = false
        extraLifeRightButton?.isHidden = false
        extraLifeLeftButton?.isHidden = false
        
        
    }
    
    func resumeWithExtraLife() {
        snake.resumeWithExtraLife(scene: self)
        extraLifeConfirmButton?.isHidden = true
        extraLifeRightButton?.isHidden = true
        extraLifeLeftButton?.isHidden = true
        pauseButton?.isHidden = false
        game.resumeGameFromPause()
        let head = snake.getSnake()[0]
        FindOppositeDirectionBeforePause(directionBeforePause: head.getDirection())
        head.setDirection(newDirection: .none)
    }
    
    //Starts a new game and resets everything to their default values
    func startNewGame() {
        snake.clearSnake()
        copies.clearAll()
        pauseButton?.isHidden = false
        score.resetScore()
        runningScoreLabel?.text = "Score: \(score.getScore())"
        snake.setHead(scene: self)
        tryDropFood()
//        setFramerate(framerate: 6)
        toggleViews()
        game.resumeGameFromPause()
        MusicPlayer.shared.playSoundEffect(soundType: .start)
        
    }
    
    func tryDropFood() {
        food.dropFood(scene: self)
        let body = snake.getSnake()
        var isFoodOverTailOrWall = true
        while isFoodOverTailOrWall {
            isFoodOverTailOrWall = false
            var i = 0
            while i < body.count {
                if isCollided(o1: food.getFood(), o2: body[i].getSegment()) {
                    isFoodOverTailOrWall = true
                    food.dropFood(scene: self)
                }
                i += 1
            }
            
            let walls = Gameboard.shared.getWalls()
            for wall in walls {
                if isCollided(o1: food.getFood(), o2: wall) {
                    isFoodOverTailOrWall = true
                    food.dropFood(scene: self)
                }
            }
            
            
        }
    }
    
    
        //checks to see if two image nodes have collided with eachother, incremented 16 to allow the user more time to turn before a collision regesters
    func isCollided(o1: SKSpriteNode, o2: SKSpriteNode) -> Bool{
//        let width = o1.size.width
        var collision = false
        
//        if abs(o1.position.x - o2.position.x) < width - 16 &&
//            abs(o1.position.y - o2.position.y) < width - 16{
        if o1.position.x == o2.position.x && o1.position.y == o2.position.y {
            collision = true
        }
        return collision
    }
    
    
    
    
    /*
    Checks to see if the head of the snake has collided with the snake itself, with the wall, or with food
    returns true if there is a collision with the wall or itself, and false if there are no collisions or if it collided with food. If it collided with food, it calls the dropFood() method of the Food class to move the food to a randomly generated spot on the map.
    */
    
    func checkCollisions() -> Bool{
     
        let body = snake.getSnake()
        let head = body[0]
        //Checks if head hits food
        if isCollided(o1: head.getSegment(), o2: food.getFood()) {
            tryDropFood()
            snake.addSegment(scene: self)
            score.addPoint()
            vibrate.vibrate()
            runningScoreLabel?.text = "Score: \(score.getScore())"
            MusicPlayer.shared.playSoundEffect(soundType: .eat)
        }
        //Checks if head hits wall, incremented 10 to each boundary to allow the user more time to make a turn before the game registers a collision

        if head.getSegment().position.x + (head.getSegment().size.width / 2) >= frame.maxX - 32 + 10 || head.getSegment().position.x - (head.getSegment().size.width / 2) <= frame.minX + 32 - 10 || head.getSegment().position.y + (head.getSegment().size.width / 2) >= CGFloat(maxY) + 10 || head.getSegment().position.y - (head.getSegment().size.width / 2) <= CGFloat(minY) - 10 {
            MusicPlayer.shared.playSoundEffect(soundType: .death)
            vibrate.vibrate()
            return true
        }
        
        //Checks if head hits body piece
        var i = 3
        while i < body.count {
            if isCollided(o1: head.getSegment(), o2: body[i].getSegment()) {
                MusicPlayer.shared.playSoundEffect(soundType: .death)
                vibrate.vibrate()
                return true
            }
            i += 1
        }
        
        //Checks if head hits inner wall piece
        let walls = Gameboard.shared.getWalls()
        for wall in walls {
            if isCollided(o1: head.getSegment(), o2: wall) {
                MusicPlayer.shared.playSoundEffect(soundType: .death)
                vibrate.vibrate()
                return true
            }
        }
        return false
    }
    
    
    
    //Sets the framrate to an Int, gets faster as the game goes on
//    func setFramerate(framerate: Int) {
//        self.view?.preferredFramesPerSecond = framerate
//    }
    
    //Allows the user to share an image of the snake and a message
    func shareScore(){
        
        let textToShare = "I just scored \(score.getScore()) points in Snake!. You will never beat me!"

        if let myWebsite = URL(string: "https://apps.apple.com/us/app/snake-classic-snake-enhanced/id1507017428?ls=1") {
            let objectsToShare = [textToShare, myWebsite, image ?? #imageLiteral(resourceName: "snake_menu.png")] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

            //Excluded options
            activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]

            activityVC.popoverPresentationController?.sourceView = viewController?.view
            viewController?.present(activityVC, animated: true, completion: nil)
        }
        
    }
    
    
    
}
