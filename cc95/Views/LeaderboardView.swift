//
//  LeaderboardView.swift
//  cc95
//
//  Created by IGOR on 17/11/2025.
//

import SwiftUI

struct LeaderboardView: View {
    @ObservedObject private var dataService = DataService.shared
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Spacer()
                    
                    Text("Best Scores")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .frame(height: 60)
                .overlay(
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(Color("ElementColor"))
                    }
                    .padding(.leading, 20),
                    alignment: .leading
                )
                .padding(.top, 50)
                
                if dataService.gameState.highScores.isEmpty {
                    emptyStateView
                } else {
                    leaderboardList
                }
            }
        }
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "trophy.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(Color("ElementColor").opacity(0.4))
            
            VStack(spacing: 12) {
                Text("No Scores Yet")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Complete levels to see your scores here")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
    
    // MARK: - Leaderboard List
    private var leaderboardList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(sortedLevelScores, id: \.level.id) { item in
                    LevelScoreRow(
                        level: item.level,
                        score: item.score,
                        rank: item.rank
                    )
                }
            }
            .padding(20)
        }
    }
    
    private var sortedLevelScores: [(level: GameLevel, score: Int, rank: Int)] {
        let levels = dataService.getLevels()
        var result: [(level: GameLevel, score: Int, rank: Int)] = []
        
        for level in levels {
            if let score = dataService.gameState.highScores[level.id] {
                let allScores = dataService.gameState.highScores.values.sorted(by: >)
                let rank = allScores.firstIndex(of: score)! + 1
                result.append((level: level, score: score, rank: rank))
            }
        }
        
        return result.sorted { $0.score > $1.score }
    }
}

// MARK: - Level Score Row
struct LevelScoreRow: View {
    let level: GameLevel
    let score: Int
    let rank: Int
    
    var body: some View {
        HStack(spacing: 16) {
            // Rank Badge
            ZStack {
                Circle()
                    .fill(rankColor)
                    .frame(width: 50, height: 50)
                
                Text("#\(rank)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Level Info
            VStack(alignment: .leading, spacing: 6) {
                Text(level.name)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                
                HStack(spacing: 8) {
                    Text("Level \(level.id)")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text("•")
                        .foregroundColor(.white.opacity(0.4))
                    
                    Text(level.difficulty.rawValue)
                        .font(.system(size: 13))
                        .foregroundColor(difficultyColor)
                }
            }
            
            Spacer()
            
            // Score
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.yellow)
                    Text("\(score)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
        )
    }
    
    private var rankColor: Color {
        switch rank {
        case 1: return Color.yellow
        case 2: return Color.gray
        case 3: return Color.orange
        default: return Color("ElementColor")
        }
    }
    
    private var difficultyColor: Color {
        switch level.difficulty {
        case .easy: return .green
        case .medium: return .yellow
        case .hard: return .orange
        case .expert: return .red
        }
    }
}
