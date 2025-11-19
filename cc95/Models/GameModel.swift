//
//  GameModel.swift
//  cc95
//
//  Created by IGOR on 17/11/2025.
//

import SwiftUI

// MARK: - Shape Types
enum ShapeType: String, CaseIterable, Codable {
    case circle
    case triangle
    case square
    case diamond
    case pentagon
    case hexagon
    
    var color: Color {
        Color("ElementColor")
    }
    
    @ViewBuilder
    func shape(rotation: Double) -> some View {
        switch self {
        case .circle:
            Circle()
                .rotationEffect(.degrees(rotation))
        case .triangle:
            Triangle()
                .rotationEffect(.degrees(rotation))
        case .square:
            Rectangle()
                .rotationEffect(.degrees(rotation))
        case .diamond:
            Diamond()
                .rotationEffect(.degrees(rotation))
        case .pentagon:
            Pentagon()
                .rotationEffect(.degrees(rotation))
        case .hexagon:
            Hexagon()
                .rotationEffect(.degrees(rotation))
        }
    }
}

// MARK: - Custom Shapes
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()
        return path
    }
}

struct Pentagon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        for i in 0..<5 {
            let angle = (Double(i) * 2.0 * .pi / 5.0) - .pi / 2
            let x = center.x + radius * CGFloat(cos(angle))
            let y = center.y + radius * CGFloat(sin(angle))
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }
}

struct Hexagon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        for i in 0..<6 {
            let angle = (Double(i) * 2.0 * .pi / 6.0) - .pi / 2
            let x = center.x + radius * CGFloat(cos(angle))
            let y = center.y + radius * CGFloat(sin(angle))
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - Game Shape
struct GameShape: Identifiable, Equatable {
    let id = UUID()
    let type: ShapeType
    var rotation: Double
    var position: GridPosition
    var isMatched: Bool = false
    
    static func == (lhs: GameShape, rhs: GameShape) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Grid Position
struct GridPosition: Equatable, Codable {
    var row: Int
    var col: Int
}

// MARK: - Game Level
struct GameLevel: Identifiable, Codable {
    let id: Int
    let name: String
    let description: String
    let gridSize: Int
    let timeLimit: Int
    let targetScore: Int
    let shapeTypes: [ShapeType]
    let difficulty: Difficulty
    
    enum Difficulty: String, Codable {
        case easy
        case medium
        case hard
        case expert
    }
}

// MARK: - Game State
struct GameState: Codable {
    var currentLevel: Int
    var completedLevels: Set<Int>
    var highScores: [Int: Int]
    var totalScore: Int
    var hasCompletedOnboarding: Bool
    
    static var initial: GameState {
        GameState(
            currentLevel: 1,
            completedLevels: [],
            highScores: [:],
            totalScore: 0,
            hasCompletedOnboarding: false
        )
    }
}

// MARK: - Player Score
struct PlayerScore: Identifiable, Codable {
    let id: Int
    let playerName: String
    let score: Int
    let level: Int
    let date: Date
}

// MARK: - Game Settings
struct GameSettings: Codable {
    var soundVolume: Double
    var musicVolume: Double
    var hapticFeedback: Bool
    
    static var initial: GameSettings {
        GameSettings(
            soundVolume: 0.7,
            musicVolume: 0.5,
            hapticFeedback: true
        )
    }
}

