//
//  MusicPlayer.swift
//  Snake
//
//  Created by Nick Dareshori on 4/7/20.
//  Copyright © 2020 Nick Dareshori. All rights reserved.
//

import Foundation
import AVFoundation
class MusicPlayer {
    
    var audioPlayer: AVAudioPlayer?
    var soundPlayer: AVAudioPlayer?
    private var isSoundEnabled = true
    private var isMusicEnabled = true
    //MusicPlayer singleton, used to ensure that two soundbytes aren't playing at the same time
    static let shared = MusicPlayer()
    
    enum SoundEffect {
        case start
        case eat
        case button
        case death
    }
    //Starts the background music, taking in either 0 or 1 as an int
    func startBackgroundMusic(songInt: Int) {
        if isMusicEnabled {
            var songName = ""
            if songInt == 0 { //Main menu song
                songName = "menu_song"
            } else { //In game song
                songName = "game_song"
            }
            if let bundle = Bundle.main.path(forResource: songName, ofType: "wav") {
                let backgroundMusic = NSURL(fileURLWithPath: bundle)
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf:backgroundMusic as URL)
                    guard let audioPlayer = audioPlayer else { return }
                    audioPlayer.numberOfLoops = -1
                    audioPlayer.prepareToPlay()
                    audioPlayer.play()
                } catch {
                    print(error)
                }
            }
        }
    }
    //Stops background music and makes sure it can't be played again
    func turnMusicOff() {
        isMusicEnabled = false
        stopBackgroundMusic()
    }
    //Starts the background music again
    func turnMusicOn() {
        isMusicEnabled = true
        startBackgroundMusic(songInt: 0)
    }
    //Turns sounds off
    func turnSoundsOff() {
        isSoundEnabled = false
    }
    //turns sounds on
    func turnSoundsOn() {
        isSoundEnabled = true
    }
    //Stops all background music currently playing
    func stopBackgroundMusic() {
        guard let audioPlayer = audioPlayer else { return }
        audioPlayer.stop()
    }
    //Plays the specified sound effect
    func playSoundEffect(soundType: SoundEffect) {
        if isSoundEnabled {
            var sound = ""
            if soundType == .start { //Played at start of game
                sound = "start"
            } else if soundType == .eat{ //Played when Snake eats
                sound = "eat"
            } else if soundType == .button { //Played when button is pressed
                sound = "button"
            } else if soundType == .death { //Played when snake dies
                sound = "death"
            }
           
            let pathToSound = Bundle.main.path(forResource: sound, ofType: "wav")!
            let url = URL(fileURLWithPath: pathToSound)
            
            do{
                soundPlayer = try AVAudioPlayer(contentsOf: url)
                soundPlayer?.play()
            } catch {}
        }
    }

}
