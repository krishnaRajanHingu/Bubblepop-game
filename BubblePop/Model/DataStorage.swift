//
//  DataStorage.swift
//  BubblePop
//
//  Created by Krishna Hingu on 6/5/19.
//  Copyright © 2019 Krishna Hingu. All rights reserved.
//

import Foundation

struct DataStorage: Codable {
    
    // Enum for data error
    enum DataError: Error {
        case dataNotFound
        case dataNotSaved
    }
    
    let gameSettingsURL: URL
    let scoreboardURL: URL
    
    init() {
        // Set up URLs
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        gameSettingsURL = documentsDirectory.appendingPathComponent("game_settings")
            .appendingPathExtension("json")
        scoreboardURL = documentsDirectory.appendingPathComponent("scoreboard")
            .appendingPathExtension("json")
    }
    
    // Store Data
    func storeSettings(settings: GameSettings) throws {
        let data = try JSONEncoder().encode(settings)
        try writeData(data, to: gameSettingsURL)
    }
    
    func storeScores(scores: [ScoreBoard]) throws {
        let data = try JSONEncoder().encode(scores)
        try writeData(data, to: scoreboardURL)
    }
    
    // Read Write Data
    func readData(from archive: URL) throws -> Data {
        if let data = try? Data(contentsOf: archive) {
            return data
        }
        throw DataError.dataNotFound
    }
    
    func writeData(_ data: Data, to archive: URL) throws {
        do {
            try data.write(to: archive, options: .noFileProtection)
        }
        catch {
            throw DataError.dataNotSaved
        }
    }
    
    func showGameSettings() throws -> GameSettings {
        let data = try readData(from: gameSettingsURL)
        if let settings = try? JSONDecoder().decode(GameSettings.self, from: data) {
            return settings
        }
        throw DataError.dataNotFound
    }
    
    func showScoreboard() throws -> [ScoreBoard] {
        let data = try readData(from: scoreboardURL)
        if let scoreboard = try? JSONDecoder().decode([ScoreBoard].self, from: data) {
            return scoreboard
        }
        throw DataError.dataNotFound
    }
    
}
