//
//  Vibrations.swift
//  Snake
//
//  Created by Nick Dareshori on 4/10/20.
//  Copyright © 2020 Nick Dareshori. All rights reserved.
//

import SpriteKit
import GameKit
import GameplayKit

class Vibrations {
    
    private var vibrationsEnabled = true
    
    func vibrate() {
        if vibrationsEnabled {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
    
    func disableVibrations() {
        vibrationsEnabled = false
    }
    
    func enableVibrations() {
        vibrationsEnabled = true
    }
}
