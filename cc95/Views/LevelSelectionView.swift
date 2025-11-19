//
//  LevelSelectionView.swift
//  cc95
//
//  Created by IGOR on 17/11/2025.
//

import SwiftUI

struct LevelSelectionView: View {
    @ObservedObject private var dataService = DataService.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedLevel: GameLevel?
    @State private var selectedDifficulty: GameLevel.Difficulty?
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(Color("ElementColor"))
                        .font(.system(size: 17, weight: .semibold))
                    }
                    
                    Spacer()
                    
                    Text("Select Level")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Color.clear.frame(width: 70)
                }
                .frame(height: 60)
                .padding(.horizontal, 20)
                .padding(.top, 50)
                
                // Difficulty Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        DifficultyFilterButton(
                            title: "All",
                            isSelected: selectedDifficulty == nil,
                            action: { selectedDifficulty = nil }
                        )
                        
                        DifficultyFilterButton(
                            title: "Easy",
                            isSelected: selectedDifficulty == .easy,
                            action: { selectedDifficulty = .easy }
                        )
                        
                        DifficultyFilterButton(
                            title: "Medium",
                            isSelected: selectedDifficulty == .medium,
                            action: { selectedDifficulty = .medium }
                        )
                        
                        DifficultyFilterButton(
                            title: "Hard",
                            isSelected: selectedDifficulty == .hard,
                            action: { selectedDifficulty = .hard }
                        )
                        
                        DifficultyFilterButton(
                            title: "Expert",
                            isSelected: selectedDifficulty == .expert,
                            action: { selectedDifficulty = .expert }
                        )
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 12)
                
                // Levels List
                ScrollView {
                    LazyVStack(spacing: 14) {
                        ForEach(filteredLevels) { level in
                            LevelCardView(
                                level: level,
                                isUnlocked: isLevelUnlocked(level),
                                isCompleted: dataService.gameState.completedLevels.contains(level.id),
                                highScore: dataService.gameState.highScores[level.id]
                            )
                            .onTapGesture {
                                if isLevelUnlocked(level) {
                                    selectedLevel = level
                                }
                            }
                        }
                    }
                    .padding(20)
                }
            }
        }
        .fullScreenCover(item: $selectedLevel) { level in
            GameView(level: level)
        }
    }
    
    private var filteredLevels: [GameLevel] {
        let allLevels = dataService.getLevels()
        if let difficulty = selectedDifficulty {
            return allLevels.filter { $0.difficulty == difficulty }
        }
        return allLevels
    }
    
    private func isLevelUnlocked(_ level: GameLevel) -> Bool {
        if level.id == 1 {
            return true
        }
        return dataService.gameState.completedLevels.contains(level.id - 1)
    }
}

// MARK: - Difficulty Filter Button
struct DifficultyFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(isSelected ? Color("ElementColor") : Color.white.opacity(0.1))
                )
        }
    }
}

// MARK: - Level Card View
struct LevelCardView: View {
    let level: GameLevel
    let isUnlocked: Bool
    let isCompleted: Bool
    let highScore: Int?
    
    var body: some View {
        HStack(spacing: 16) {
            // Level Number Circle
            ZStack {
                Circle()
                    .fill(isUnlocked ? Color("ElementColor") : Color.white.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                if isUnlocked {
                    Text("\(level.id)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.3))
                }
            }
            
            // Level Info
            VStack(alignment: .leading, spacing: 8) {
                Text(level.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(isUnlocked ? .white : .white.opacity(0.4))
                
                HStack(spacing: 8) {
                    DifficultyBadge(difficulty: level.difficulty)
                    
                    Text("•")
                        .foregroundColor(.white.opacity(0.4))
                    
                    HStack(spacing: 4) {
                        Image(systemName: "square.grid.3x3")
                            .font(.system(size: 11))
                        Text("\(level.gridSize)×\(level.gridSize)")
                            .font(.system(size: 13))
                    }
                    .foregroundColor(.white.opacity(0.6))
                }
                
                if let score = highScore {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.yellow)
                        Text("Best: \(score)")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
            
            Spacer()
            
            // Status Icon
            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.green)
            } else if isUnlocked {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(Color("ElementColor"))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(isUnlocked ? 0.1 : 0.05))
        )
        .opacity(isUnlocked ? 1.0 : 0.5)
    }
}

// MARK: - Difficulty Badge
struct DifficultyBadge: View {
    let difficulty: GameLevel.Difficulty
    
    var body: some View {
        Text(difficulty.rawValue)
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(difficultyColor)
            )
    }
    
    private var difficultyColor: Color {
        switch difficulty {
        case .easy: return .green
        case .medium: return .yellow
        case .hard: return .orange
        case .expert: return .red
        }
    }
}
