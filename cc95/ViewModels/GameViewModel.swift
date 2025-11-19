//
//  GameViewModel.swift
//  cc95
//
//  Created by IGOR on 17/11/2025.
//

import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    @Published var currentLevel: GameLevel
    @Published var shapes: [GameShape] = []
    @Published var score: Int = 0
    @Published var timeRemaining: Int
    @Published var gameState: GamePlayState = .ready
    @Published var selectedShape: GameShape?
    @Published var moves: Int = 0
    @Published var matchedPairs: Int = 0
    @Published var combo: Int = 0
    @Published var hintsRemaining: Int = 3
    @Published var showHintAnimation: Bool = false
    
    private var timer: Timer?
    private let dataService = DataService.shared
    private var cancellables = Set<AnyCancellable>()
    
    enum GamePlayState {
        case ready
        case playing
        case paused
        case completed
        case failed
    }
    
    init(level: GameLevel) {
        self.currentLevel = level
        self.timeRemaining = level.timeLimit
        setupLevel()
    }
    
    // MARK: - Game Setup
    private func setupLevel() {
        generateShapes()
        score = 0
        moves = 0
        matchedPairs = 0
        combo = 0
        hintsRemaining = 3
        timeRemaining = currentLevel.timeLimit
        gameState = .ready
    }
    
    private func generateShapes() {
        shapes = []
        let gridSize = currentLevel.gridSize
        var positions: [GridPosition] = []
        
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                positions.append(GridPosition(row: row, col: col))
            }
        }
        
        positions.shuffle()
        
        let shapesCount = min(positions.count, currentLevel.gridSize * currentLevel.gridSize)
        let pairsCount = shapesCount / 2
        
        var shapePool: [ShapeType] = []
        for _ in 0..<pairsCount {
            let randomShape = currentLevel.shapeTypes.randomElement() ?? .circle
            shapePool.append(randomShape)
            shapePool.append(randomShape)
        }
        
        shapePool.shuffle()
        
        for i in 0..<min(shapePool.count, positions.count) {
            let shape = GameShape(
                type: shapePool[i],
                rotation: Double.random(in: 0...360),
                position: positions[i]
            )
            shapes.append(shape)
        }
    }
    
    // MARK: - Game Controls
    func startGame() {
        gameState = .playing
        startTimer()
    }
    
    func pauseGame() {
        gameState = .paused
        timer?.invalidate()
    }
    
    func resumeGame() {
        gameState = .playing
        startTimer()
    }
    
    func resetGame() {
        timer?.invalidate()
        setupLevel()
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.endGame(success: false)
            }
        }
    }
    
    private func endGame(success: Bool) {
        timer?.invalidate()
        gameState = success ? .completed : .failed
        
        if success {
            dataService.completeLevel(currentLevel.id, score: score)
            if currentLevel.id < dataService.getLevels().count {
                dataService.unlockNextLevel()
            }
        }
    }
    
    // MARK: - Game Logic
    func selectShape(_ shape: GameShape) {
        guard gameState == .playing else { return }
        
        if let selected = selectedShape {
            if selected.id == shape.id {
                selectedShape = nil
                return
            }
            
            checkMatch(first: selected, second: shape)
            selectedShape = nil
        } else {
            selectedShape = shape
        }
    }
    
    func rotateShape(_ shape: GameShape) {
        guard gameState == .playing else { return }
        
        if let index = shapes.firstIndex(where: { $0.id == shape.id }) {
            shapes[index].rotation += 90
            if shapes[index].rotation >= 360 {
                shapes[index].rotation = 0
            }
            moves += 1
        }
    }
    
    private func checkMatch(first: GameShape, second: GameShape) {
        moves += 1
        
        let rotationMatch = abs(first.rotation - second.rotation) < 5 || abs(first.rotation - second.rotation) > 355
        
        if first.type == second.type && rotationMatch {
            markAsMatched(first)
            markAsMatched(second)
            
            // Combo system
            combo += 1
            
            let basePoints = 10
            let timeBonus = timeRemaining
            let moveBonus = max(0, 50 - moves)
            let comboBonus = combo * 5
            score += basePoints + timeBonus + moveBonus + comboBonus
            
            matchedPairs += 1
            
            checkLevelCompletion()
        } else {
            // Reset combo on mistake
            combo = 0
        }
    }
    
    func useHint() {
        guard hintsRemaining > 0 && gameState == .playing else { return }
        
        hintsRemaining -= 1
        showHintAnimation = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showHintAnimation = false
        }
    }
    
    private func markAsMatched(_ shape: GameShape) {
        if let index = shapes.firstIndex(where: { $0.id == shape.id }) {
            shapes[index].isMatched = true
        }
    }
    
    private func checkLevelCompletion() {
        let allMatched = shapes.allSatisfy { $0.isMatched }
        if allMatched && score >= currentLevel.targetScore {
            endGame(success: true)
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}

