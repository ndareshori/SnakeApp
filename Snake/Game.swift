//
//  Game.swift
//  Snake
//
//  Created by Nick Dareshori on 4/16/20.
//  Copyright © 2020 Nick Dareshori. All rights reserved.
//

import Foundation

class Game {
//    static let shared = Game()
    //Stores whether or not the user is currently in the game scene
    var isGamePlaying = false
    //Stores whether or not the game is paused
    var isGamePaused = false
    
    func pauseGame() {
        print("game paused")
        isGamePaused = true
    }
    
    func resumeGameFromPause() {
        print("game resumed from pause")
        isGamePaused = false
    }
    
    func getPauseStatus() -> Bool{return isGamePaused}
    
    func gameStart() {
        isGamePlaying = true
    }
    
    func gameStop() {
        isGamePlaying = false
    }
    
    func getGetGameStatus() -> Bool {return isGamePlaying}
    
}
