//
//  DataService.swift
//  cc95
//
//  Created by IGOR on 17/11/2025.
//

import Foundation
import Combine

class DataService: ObservableObject {
    static let shared = DataService()
    
    private let gameStateKey = "whirljig_game_state"
    private let settingsKey = "whirljig_settings"
    private let leaderboardKey = "whirljig_leaderboard"
    
    @Published var gameState: GameState
    @Published var settings: GameSettings
    @Published var leaderboard: [PlayerScore]
    
    private init() {
        self.gameState = DataService.loadGameState()
        self.settings = DataService.loadSettings()
        self.leaderboard = DataService.loadLeaderboard()
    }
    
    // MARK: - Game State Management
    func saveGameState() {
        if let encoded = try? JSONEncoder().encode(gameState) {
            UserDefaults.standard.set(encoded, forKey: gameStateKey)
        }
    }
    
    private static func loadGameState() -> GameState {
        guard let data = UserDefaults.standard.data(forKey: "whirljig_game_state"),
              let state = try? JSONDecoder().decode(GameState.self, from: data) else {
            return GameState.initial
        }
        return state
    }
    
    func completeLevel(_ level: Int, score: Int) {
        gameState.completedLevels.insert(level)
        gameState.totalScore += score
        
        if let currentHigh = gameState.highScores[level] {
            gameState.highScores[level] = max(currentHigh, score)
        } else {
            gameState.highScores[level] = score
        }
        
        addToLeaderboard(level: level, score: score)
        saveGameState()
    }
    
    func unlockNextLevel() {
        gameState.currentLevel += 1
        saveGameState()
    }
    
    func resetGameState() {
        gameState = GameState.initial
        leaderboard = []
        saveGameState()
        saveLeaderboard()
    }
    
    // MARK: - Settings Management
    func saveSettings() {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: settingsKey)
        }
    }
    
    private static func loadSettings() -> GameSettings {
        guard let data = UserDefaults.standard.data(forKey: "whirljig_settings"),
              let settings = try? JSONDecoder().decode(GameSettings.self, from: data) else {
            return GameSettings.initial
        }
        return settings
    }
    
    func updateVolume(sound: Double? = nil, music: Double? = nil) {
        if let sound = sound {
            settings.soundVolume = sound
        }
        if let music = music {
            settings.musicVolume = music
        }
        saveSettings()
    }
    
    func toggleHapticFeedback() {
        settings.hapticFeedback.toggle()
        saveSettings()
    }
    
    // MARK: - Leaderboard Management
    private func addToLeaderboard(level: Int, score: Int) {
        let newScore = PlayerScore(
            id: leaderboard.count + 1,
            playerName: "Player",
            score: score,
            level: level,
            date: Date()
        )
        leaderboard.append(newScore)
        leaderboard.sort { $0.score > $1.score }
        if leaderboard.count > 100 {
            leaderboard = Array(leaderboard.prefix(100))
        }
        saveLeaderboard()
    }
    
    private func saveLeaderboard() {
        if let encoded = try? JSONEncoder().encode(leaderboard) {
            UserDefaults.standard.set(encoded, forKey: leaderboardKey)
        }
    }
    
    private static func loadLeaderboard() -> [PlayerScore] {
        guard let data = UserDefaults.standard.data(forKey: "whirljig_leaderboard"),
              let scores = try? JSONDecoder().decode([PlayerScore].self, from: data) else {
            return []
        }
        return scores
    }
    
    // MARK: - Level Data
    func getLevels() -> [GameLevel] {
        return [
            // Easy Levels (1-6) - Tutorial and Learning
            GameLevel(id: 1, name: "First Steps", description: "Learn the basics", gridSize: 3, timeLimit: 90, targetScore: 50, shapeTypes: [.circle, .square], difficulty: .easy),
            GameLevel(id: 2, name: "Shape Shifter", description: "More shapes to match", gridSize: 3, timeLimit: 80, targetScore: 100, shapeTypes: [.circle, .square, .triangle], difficulty: .easy),
            GameLevel(id: 3, name: "Quick Match", description: "Speed things up", gridSize: 3, timeLimit: 70, targetScore: 150, shapeTypes: [.circle, .square, .triangle], difficulty: .easy),
            GameLevel(id: 4, name: "Pattern Play", description: "Find the patterns", gridSize: 4, timeLimit: 75, targetScore: 200, shapeTypes: [.circle, .square, .triangle], difficulty: .easy),
            GameLevel(id: 5, name: "Diamond Intro", description: "New shape appears", gridSize: 4, timeLimit: 70, targetScore: 250, shapeTypes: [.circle, .square, .triangle, .diamond], difficulty: .easy),
            GameLevel(id: 6, name: "Easy Master", description: "Complete basics", gridSize: 4, timeLimit: 65, targetScore: 300, shapeTypes: [.circle, .square, .triangle, .diamond], difficulty: .easy),
            
            // Medium Levels (7-14) - Intermediate Challenge
            GameLevel(id: 7, name: "Pentagon Power", description: "Five sides challenge", gridSize: 4, timeLimit: 60, targetScore: 350, shapeTypes: [.circle, .triangle, .diamond, .pentagon], difficulty: .medium),
            GameLevel(id: 8, name: "Time Pressure", description: "Beat the clock", gridSize: 5, timeLimit: 55, targetScore: 400, shapeTypes: [.square, .diamond, .pentagon], difficulty: .medium),
            GameLevel(id: 9, name: "Shape Variety", description: "All shapes available", gridSize: 5, timeLimit: 60, targetScore: 450, shapeTypes: ShapeType.allCases, difficulty: .medium),
            GameLevel(id: 10, name: "Hexagon Hunt", description: "Six-sided challenge", gridSize: 5, timeLimit: 50, targetScore: 500, shapeTypes: ShapeType.allCases, difficulty: .medium),
            GameLevel(id: 11, name: "Quick Thinking", description: "Faster decisions", gridSize: 5, timeLimit: 45, targetScore: 550, shapeTypes: ShapeType.allCases, difficulty: .medium),
            GameLevel(id: 12, name: "Rotation Master", description: "Complex rotations", gridSize: 5, timeLimit: 50, targetScore: 600, shapeTypes: ShapeType.allCases, difficulty: .medium),
            GameLevel(id: 13, name: "Grid Expansion", description: "Bigger playground", gridSize: 6, timeLimit: 60, targetScore: 650, shapeTypes: ShapeType.allCases, difficulty: .medium),
            GameLevel(id: 14, name: "Medium Master", description: "Peak performance", gridSize: 6, timeLimit: 55, targetScore: 700, shapeTypes: ShapeType.allCases, difficulty: .medium),
            
            // Hard Levels (15-20) - Advanced Players
            GameLevel(id: 15, name: "Speed Demon", description: "Ultimate speed test", gridSize: 6, timeLimit: 45, targetScore: 750, shapeTypes: ShapeType.allCases, difficulty: .hard),
            GameLevel(id: 16, name: "Chaos Theory", description: "Pure chaos", gridSize: 6, timeLimit: 40, targetScore: 800, shapeTypes: ShapeType.allCases, difficulty: .hard),
            GameLevel(id: 17, name: "Memory Challenge", description: "Remember everything", gridSize: 6, timeLimit: 50, targetScore: 850, shapeTypes: ShapeType.allCases, difficulty: .hard),
            GameLevel(id: 18, name: "Precision Strike", description: "No mistakes allowed", gridSize: 6, timeLimit: 45, targetScore: 900, shapeTypes: ShapeType.allCases, difficulty: .hard),
            GameLevel(id: 19, name: "Time Crunch", description: "Extreme pressure", gridSize: 6, timeLimit: 35, targetScore: 950, shapeTypes: ShapeType.allCases, difficulty: .hard),
            GameLevel(id: 20, name: "Hard Master", description: "Conquer the hard", gridSize: 6, timeLimit: 40, targetScore: 1000, shapeTypes: ShapeType.allCases, difficulty: .hard),
            
            // Expert Levels (21-24) - Only for True Masters
            GameLevel(id: 21, name: "Elite Challenge", description: "For experts only", gridSize: 6, timeLimit: 50, targetScore: 1100, shapeTypes: ShapeType.allCases, difficulty: .expert),
            GameLevel(id: 22, name: "Grand Master", description: "Supreme difficulty", gridSize: 6, timeLimit: 40, targetScore: 1200, shapeTypes: ShapeType.allCases, difficulty: .expert),
            GameLevel(id: 23, name: "Impossible Task", description: "Nearly impossible", gridSize: 6, timeLimit: 35, targetScore: 1300, shapeTypes: ShapeType.allCases, difficulty: .expert),
            GameLevel(id: 24, name: "The Ultimate", description: "Can you beat this?", gridSize: 6, timeLimit: 30, targetScore: 1500, shapeTypes: ShapeType.allCases, difficulty: .expert)
        ]
    }
    
    func getLevel(id: Int) -> GameLevel? {
        return getLevels().first { $0.id == id }
    }
}

