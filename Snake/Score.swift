//
//  Score.swift
//  Snake
//
//  Created by Nick Dareshori on 4/6/20.
//  Copyright © 2020 Nick Dareshori. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit
import GameplayKit

class Score {
    private var score = 0
    private var highScore = 0
    
    //Called each time the snake eats, increments the score by 1
    func addPoint() {
        score += 1
    }
    //Returns the score
    func getScore() -> Int {return score}
    //Returns the highscore
    func getHighScore() -> Int {
        if let high = UserDefaults.standard.object(forKey: "highscore") as? Int {
            return high
        }
        else {
            return highScore
        }
    }
    //Calls method to calculate the high score and then resets the score to 0
    func resetScore() {
        calculateHighScore()
        score = 0
    }
    
    func resetHighScoreCAUTION() {
        highScore = 0
        UserDefaults.standard.set(highScore, forKey: "highscore")
    }
    //Calculates the high score, comparing it to the saved user default highscore.
    func calculateHighScore() {
        if let allTimeHigh = UserDefaults.standard.object(forKey: "highscore") as? Int {
            if score > allTimeHigh {
                highScore = score
                UserDefaults.standard.set(highScore, forKey: "highscore")
                MenuViewController.shared.submitScoreToGC(highscore: highScore)
            } else {
                highScore = allTimeHigh
            }
        } else {
            if score > highScore {
                highScore = score
                UserDefaults.standard.set(highScore, forKey: "highscore")
                MenuViewController.shared.submitScoreToGC(highscore: highScore)
                print("NEW HIGHSCORE!!!!!!!!!!!!!")
            }
        }
        
    }
}
