//
//  MenuViewController.swift
//  Snake
//
//  Created by Nick Dareshori on 4/7/20.
//  Copyright © 2020 Nick Dareshori. All rights reserved.
//

import UIKit
import GameKit

class MenuViewController: UIViewController, GKGameCenterControllerDelegate {
    
    
   private var game = Game()
   static let shared = MenuViewController()
    
    
    /* Variables */
   var gcEnabled = Bool() // Check if the user has Game Center enabled
   var gcDefaultLeaderBoard = String() // Check the default leaderboardID
   private var scoreObj = Score()
   private var vibrate = Vibrations()

        
        
   let LEADERBOARD_ID = "LB_highscores"
    
    
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var openSettingsButton: UIButton!
    @IBOutlet weak var exitSettingsButton: UIButton!
    
    @IBOutlet weak var settingsPanel: UIImageView!
    
    
    @IBOutlet weak var controlTypeLabel: UILabel!
    @IBOutlet weak var controlButtonSwipe: UIButton!
    @IBOutlet weak var controlButtonKeys: UIButton!
    @IBOutlet weak var controlButtonJoystick: UIButton!
    
    @IBOutlet weak var soundsControlLabel: UILabel!
    @IBOutlet weak var soundsOnButton: UIButton!
    @IBOutlet weak var soundsOffButton: UIButton!
    
    @IBOutlet weak var musicControlLabel: UILabel!
    @IBOutlet weak var musicOnButton: UIButton!
    @IBOutlet weak var musicOffButton: UIButton!
    
    
    @IBOutlet weak var vibrationsControlLabel: UILabel!
    @IBOutlet weak var vibrationsOnButton: UIButton!
    @IBOutlet weak var vibrationsOffButton: UIButton!
    
    
    @IBOutlet weak var messageArea: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dismissMessageAreaButton: UIButton!
    
    
    @IBOutlet weak var playClassicButton: UIButton!
    
    @IBOutlet weak var playLevel1Button: UIButton!
    @IBOutlet weak var playLevel1Button_Locked: UIButton!
    
    //Userdefault that keeps track of users who bought the app so that they can be given rewards when it's made free
    private var didBuyApp = true
    
    @IBOutlet weak var highscoresButton: UIButton!
    
    //Boolean that gets sent over to the GameScene through the segue
    var controlsType = GameScene.controlMode.keys
    private var isMusicEnabled = true
    private var areSoundsEnabled = true
    private var areVibrationsEnabled = true
    //Userdefaults allow me to keep track of the user's preferences
    private var levelChoice = GameScene.levels.classic
    
    private var hasHighscoreReset = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authenticateLocalPlayer()
        closeSettingsMenu()

        
        if let scoreDidReset = UserDefaults.standard.object(forKey: "hasHighscoreResetAgain") as? Bool {
            if !scoreDidReset {
                resetHighScoreCAUTION()
            }
        } else {
            messageArea.isHidden = false
            messageLabel.isHidden = false
            dismissMessageAreaButton.isHidden = false
            messageLabel.text = "Due to major updates, we had to reset your highscore. We apologize for the inconvenience."
            resetHighScoreCAUTION()
        }

        if let boughtApp = (UserDefaults.standard.object(forKey: "didBuyApp") as? Bool) {
            print("Did buy App?: \(boughtApp)")
        } else {
            didBuyApp = true
            UserDefaults.standard.set(didBuyApp, forKey: "didBuyApp")
            print("Set bought app boolean to:  \(didBuyApp)")
        }
        
        if let musicPref = UserDefaults.standard.object(forKey: "musicPreference") as? Bool {
            isMusicEnabled = musicPref
            if (!isMusicEnabled) {
                MusicPlayer.shared.turnMusicOff()
            }
        }
        if let soundsPref = UserDefaults.standard.object(forKey: "soundsPreference") as? Bool {
            areSoundsEnabled = soundsPref
            if (!areSoundsEnabled) {
                MusicPlayer.shared.turnSoundsOff()
            }
        }
        if let controlsPref = UserDefaults.standard.object(forKey: "controlPreference") as? String {
            controlsType = convertStringToDirection(string: controlsPref)
        }
        if let vibrationsPref = UserDefaults.standard.object(forKey: "vibrationPreference") as? Bool {
            areVibrationsEnabled = vibrationsPref
        }
        
        MusicPlayer.shared.startBackgroundMusic(songInt: 0)
        // Do any additional setup after loading the view.
    }
    
    func authenticateLocalPlayer() {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.local
             
        localPlayer.authenticateHandler = {(ViewController, error) -> Void in
            if((ViewController) != nil) {
                // 1. Show login if player is not logged in
                self.present(ViewController!, animated: true, completion: nil)
            } else if (localPlayer.isAuthenticated) {
                // 2. Player is already authenticated & logged in, load game center
                self.gcEnabled = true
                     
                // Get the default leaderboard ID
                localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: { (leaderboardIdentifer, error) in
                    if error != nil { print(error!)
                    } else { self.gcDefaultLeaderBoard = leaderboardIdentifer! }
                })
                 
            } else {
                // 3. Game center is not enabled on the users device
                self.gcEnabled = false
                print("Local player could not be authenticated!")
                print(error as Any)
            }
        }
    }
    
   //Sends the segue and plays the game music
    @IBAction func playButtonTapped(_ sender: Any) {
        MusicPlayer.shared.playSoundEffect(soundType: .button)
        playButton.isHidden = true
        settingsPanel.isHidden = false
        exitSettingsButton.isHidden = false
        playClassicButton.isHidden = false
        if scoreObj.getHighScore() >= 1 {
            playLevel1Button.isHidden = false
        } else {
            playLevel1Button_Locked.isHidden = false
        }
    }
    
    @IBAction func playClassicButtonTapped(_ sender: UIButton) {
        game.gameStart()
        MusicPlayer.shared.playSoundEffect(soundType: .start)
        levelChoice = GameScene.levels.classic
        self.performSegue(withIdentifier: "playSegue", sender: self)
        closeSettingsMenu()
    }
    
    @IBAction func playLevel1ButtonTapped(_ sender: UIButton) {
        game.gameStart()
        MusicPlayer.shared.playSoundEffect(soundType: .start)
        levelChoice = GameScene.levels.level1
        self.performSegue(withIdentifier: "playSegue", sender: self)
        closeSettingsMenu()
    }
    @IBAction func playLevel1Button_LockedTapped(_ sender: UIButton) {
        dismissMessageAreaButton.isHidden = false
        messageArea.isHidden = false
        messageLabel.text = "You must get at least 50 points in classic mode before unlocking level 1."
        messageLabel.isHidden = false
        
    }
    
    
    func submitScoreToGC(highscore: Int) {
       // Submit score to GC leaderboard
       let bestScoreInt = GKScore(leaderboardIdentifier: LEADERBOARD_ID)
       bestScoreInt.value = Int64(highscore)
       GKScore.report([bestScoreInt]) { (error) in
           if error != nil {
               print(error!.localizedDescription)
           } else {
               print("Best Score submitted to your Leaderboard!")
           }
        }
    }
    
    @IBAction func dismissMessageAreaButtonTapped(_ sender: UIButton) {
        MusicPlayer.shared.playSoundEffect(soundType: .button)
        messageArea.isHidden = true
        messageLabel.isHidden = true
        dismissMessageAreaButton.isHidden = true
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func checkGCLeaderboard(_ sender: AnyObject) {
        
        MusicPlayer.shared.playSoundEffect(soundType: .button)
        let gcVC = GKGameCenterViewController()
        gcVC.gameCenterDelegate = self
        gcVC.viewState = .leaderboards
        gcVC.leaderboardIdentifier = LEADERBOARD_ID
        present(gcVC, animated: true, completion: nil)
    }
    

 
    //Calls a function that opens the settings menu
    @IBAction func OpenSettingsButtonTapped(_ sender: UIButton) {
        
        MusicPlayer.shared.playSoundEffect(soundType: .button)
        openSettingsMenu()
        exitSettingsButton.isHidden = false
        openSettingsButton.isHidden = true
    }
    //Calls a function that closes settings menu
    @IBAction func closeSettingsButtonTapped(_ sender: UIButton) {
        
        MusicPlayer.shared.playSoundEffect(soundType: .button)
        closeSettingsMenu()
        
    }
    
    //Opens settings menu, determines which buttons to display based on the user's previous preferences
    func openSettingsMenu() {
        controlTypeLabel.isHidden = false
        soundsControlLabel.isHidden = false
        musicControlLabel.isHidden = false
        vibrationsControlLabel.isHidden = false
        playButton.isHidden = true
        highscoresButton.isHidden = true
        settingsPanel.isHidden = false
        
        swapControlButtonViews()
        if areSoundsEnabled {
            soundsOnButton.isHidden = false
            soundsOffButton.isHidden = true
        } else {
            soundsOnButton.isHidden = true
            soundsOffButton.isHidden = false
        }
        if isMusicEnabled {
            musicOnButton.isHidden = false
            musicOffButton.isHidden = true
        } else {
            musicOnButton.isHidden = true
            musicOffButton.isHidden = false
        }
        if areVibrationsEnabled {
            vibrationsOnButton.isHidden = false
            vibrationsOffButton.isHidden = true
        } else {
            vibrationsOnButton.isHidden = true
            vibrationsOffButton.isHidden = false
        }
        
    }
    
    func resetHighScoreCAUTION() {
        scoreObj.resetHighScoreCAUTION()
        hasHighscoreReset = true
        UserDefaults.standard.set(hasHighscoreReset, forKey: "hasHighscoreResetAgain")
    }
    
    //closes settings menu and hides all the settings menu images
    func closeSettingsMenu() {
        playButton.isHidden = false
        highscoresButton.isHidden = false
        exitSettingsButton.isHidden = true
        openSettingsButton.isHidden = false
        settingsPanel.isHidden = true
        controlTypeLabel.isHidden = true
        controlButtonKeys.isHidden = true
        controlButtonSwipe.isHidden = true
        controlButtonJoystick.isHidden = true
        soundsControlLabel.isHidden = true
        vibrationsControlLabel.isHidden = true
        vibrationsOnButton.isHidden = true
        vibrationsOffButton.isHidden = true
        soundsOnButton.isHidden = true
        soundsOffButton.isHidden = true
        musicControlLabel.isHidden = true
        musicOnButton.isHidden = true
        musicOffButton.isHidden = true
        
        playLevel1Button_Locked.isHidden = true
        playLevel1Button.isHidden = true
        playClassicButton.isHidden = true
        
        messageLabel.isHidden = true
        messageArea.isHidden = true
        dismissMessageAreaButton.isHidden = true
    }
    
    //Each time a button is tapped, it hides itself and unhides its counterpart.
    @IBAction func soundsOnButtonTapped(_ sender: UIButton) {
        
        areSoundsEnabled = false
        UserDefaults.standard.set(areSoundsEnabled, forKey: "soundsPreference")
        MusicPlayer.shared.turnSoundsOff()
        soundsOnButton.isHidden = true
        soundsOffButton.isHidden = false
    }
    @IBAction func soundsOffButtonTapped(_ sender: UIButton) {
        
        areSoundsEnabled = true
        UserDefaults.standard.set(areSoundsEnabled, forKey: "soundsPreference")
        MusicPlayer.shared.turnSoundsOn()
        MusicPlayer.shared.playSoundEffect(soundType: .button)
        soundsOffButton.isHidden = true
        soundsOnButton.isHidden = false
    }
    @IBAction func musicOnButtonTapped(_ sender: UIButton) {
        
        MusicPlayer.shared.playSoundEffect(soundType: .button)
        isMusicEnabled = false
        UserDefaults.standard.set(isMusicEnabled, forKey: "musicPreference")
        MusicPlayer.shared.turnMusicOff()
        musicOnButton.isHidden = true
        musicOffButton.isHidden = false
    }
    @IBAction func musicOffButtonTapped(_ sender: UIButton) {
        
        MusicPlayer.shared.playSoundEffect(soundType: .button)
        isMusicEnabled = true
        UserDefaults.standard.set(isMusicEnabled, forKey: "musicPreference")
        MusicPlayer.shared.turnMusicOn()
        musicOffButton.isHidden = true
        musicOnButton.isHidden = false
    }
    
    @IBAction func vibrationsOnButtonTapped(_ sender: UIButton) {
        areVibrationsEnabled = false
        MusicPlayer.shared.playSoundEffect(soundType: .button)
        vibrate.disableVibrations()
        UserDefaults.standard.set(areVibrationsEnabled, forKey: "vibrationPreference")
        vibrationsOnButton.isHidden = true
        vibrationsOffButton.isHidden = false
    }
    
    @IBAction func vibrationsOffButtonTapped(_ sender: UIButton) {
        areVibrationsEnabled = true
        MusicPlayer.shared.playSoundEffect(soundType: .button)
        vibrate.enableVibrations()
        vibrate.vibrate()
        UserDefaults.standard.set(areVibrationsEnabled, forKey: "vibrationPreference")
        vibrationsOnButton.isHidden = false
        vibrationsOffButton.isHidden = true
    }
    
    @IBAction func controlButtonSwipeTapped(_ sender: UIButton) {
        MusicPlayer.shared.playSoundEffect(soundType: .button)
        
        controlsType = .joystick
        UserDefaults.standard.set(convertDirectionToString(control: controlsType), forKey: "controlPreference")
        swapControlButtonViews()
    }
    @IBAction func controlButtonKeysTapped(_ sender: UIButton) {
        
        MusicPlayer.shared.playSoundEffect(soundType: .button)
        controlsType = .swipe
        UserDefaults.standard.set(convertDirectionToString(control: controlsType), forKey: "controlPreference")
        swapControlButtonViews()
    }
    @IBAction func controlButtonJoystickTapped(_ sender: UIButton) {
        MusicPlayer.shared.playSoundEffect(soundType: .button)
        controlsType = .keys
        UserDefaults.standard.set(convertDirectionToString(control: controlsType), forKey: "controlPreference")
        swapControlButtonViews()
    }
    func swapControlButtonViews() {
        if controlsType == .keys {
            controlButtonKeys.isHidden = false
            controlButtonSwipe.isHidden = true
            controlButtonJoystick.isHidden = true
        } else if controlsType == .swipe {
            controlButtonKeys.isHidden = true
            controlButtonSwipe.isHidden = false
            controlButtonJoystick.isHidden = true
        } else {
            controlButtonKeys.isHidden = true
            controlButtonSwipe.isHidden = true
            controlButtonJoystick.isHidden = false
        }
    }
    
    func convertDirectionToString(control: GameScene.controlMode) -> String {
        if control == .keys {
            return "keys"
        } else if control == .swipe {
            return "swipe"
        } else {
            return "joystick"
        }
    }
    
    func convertStringToDirection(string: String) -> GameScene.controlMode {
        if string == "keys" {
            return .keys
        } else if string == "swipe" {
            return .swipe
        } else {
            return .joystick
        }
    }
    
    

    //Unwins the segue
    @IBAction func unwindToMainMenu(sender: UIStoryboardSegue){
        game.gameStop()
    }
    
    //Prepares the segue, sending the boolean that determines the controls type
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is GameViewController {
            let vc = segue.destination as? GameViewController
            vc?.controls = controlsType
            vc?.userSelectedLevel = levelChoice
        }
    }
    
    
}

