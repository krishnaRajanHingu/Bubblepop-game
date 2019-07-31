//
//  GameSettings.swift
//  BubblePop
//
//  Created by Krishna Hingu on 5/5/19.
//  Copyright © 2019 Krishna Hingu. All rights reserved.
//

import Foundation

// Game setting Model
struct GameSettings: Codable {
    // Default settings
    var gameTime: Int = 60
    var maxBubbles: Int = 15
}
