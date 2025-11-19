//
//  StatisticsView.swift
//  cc95
//
//  Created by IGOR on 17/11/2025.
//

import SwiftUI

struct StatisticsView: View {
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
                    
                    Text("Statistics")
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
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Overview Section
                        overviewSection
                        
                        // Level Statistics
                        levelStatisticsSection
                        
                        // Score Statistics
                        scoreStatisticsSection
                        
                        // Performance Section
                        performanceSection
                    }
                    .padding(20)
                }
            }
        }
    }
    
    // MARK: - Overview Section
    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Overview")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            HStack(spacing: 12) {
                StatCard(
                    icon: "gamecontroller.fill",
                    value: "\(dataService.gameState.completedLevels.count)",
                    label: "Levels"
                )
                
                StatCard(
                    icon: "star.fill",
                    value: "\(dataService.gameState.totalScore)",
                    label: "Score"
                )
                
                StatCard(
                    icon: "trophy.fill",
                    value: "\(calculateWinRate())%",
                    label: "Win Rate"
                )
            }
        }
    }
    
    // MARK: - Level Statistics Section
    private var levelStatisticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Level Progress")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                StatRow(
                    title: "Total Levels",
                    value: "\(dataService.getLevels().count)",
                    icon: "square.grid.3x3.fill"
                )
                
                Divider()
                    .background(Color.white.opacity(0.2))
                
                StatRow(
                    title: "Completed",
                    value: "\(dataService.gameState.completedLevels.count)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                Divider()
                    .background(Color.white.opacity(0.2))
                
                StatRow(
                    title: "Remaining",
                    value: "\(dataService.getLevels().count - dataService.gameState.completedLevels.count)",
                    icon: "clock.fill",
                    color: .orange
                )
                
                Divider()
                    .background(Color.white.opacity(0.2))
                
                StatRow(
                    title: "Current Level",
                    value: "\(dataService.gameState.currentLevel)",
                    icon: "flag.fill",
                    color: Color("ElementColor")
                )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.1))
            )
        }
    }
    
    // MARK: - Score Statistics Section
    private var scoreStatisticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Score Statistics")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                StatRow(
                    title: "Total Score",
                    value: "\(dataService.gameState.totalScore)",
                    icon: "star.fill"
                )
                
                Divider()
                    .background(Color.white.opacity(0.2))
                
                StatRow(
                    title: "Highest Score",
                    value: "\(getHighestScore())",
                    icon: "crown.fill",
                    color: .yellow
                )
                
                Divider()
                    .background(Color.white.opacity(0.2))
                
                StatRow(
                    title: "Average Score",
                    value: "\(getAverageScore())",
                    icon: "chart.bar.fill",
                    color: .blue
                )
                
                Divider()
                    .background(Color.white.opacity(0.2))
                
                StatRow(
                    title: "Leaderboard Rank",
                    value: "#\(getLeaderboardRank())",
                    icon: "list.number",
                    color: Color("ElementColor")
                )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.1))
            )
        }
    }
    
    // MARK: - Performance Section
    private var performanceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Performance")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                StatRow(
                    title: "Easy Levels",
                    value: "\(completedByDifficulty(.easy))",
                    icon: "leaf.fill",
                    color: .green
                )
                
                Divider()
                    .background(Color.white.opacity(0.2))
                
                StatRow(
                    title: "Medium Levels",
                    value: "\(completedByDifficulty(.medium))",
                    icon: "flame.fill",
                    color: .yellow
                )
                
                Divider()
                    .background(Color.white.opacity(0.2))
                
                StatRow(
                    title: "Hard Levels",
                    value: "\(completedByDifficulty(.hard))",
                    icon: "bolt.fill",
                    color: .orange
                )
                
                Divider()
                    .background(Color.white.opacity(0.2))
                
                StatRow(
                    title: "Expert Levels",
                    value: "\(completedByDifficulty(.expert))",
                    icon: "sparkles",
                    color: .red
                )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.1))
            )
        }
    }
    
    // MARK: - Helper Functions
    private func calculateWinRate() -> Int {
        let total = dataService.getLevels().count
        let completed = dataService.gameState.completedLevels.count
        return total > 0 ? (completed * 100) / total : 0
    }
    
    private func getHighestScore() -> Int {
        return dataService.gameState.highScores.values.max() ?? 0
    }
    
    private func getAverageScore() -> Int {
        let scores = dataService.gameState.highScores.values
        return scores.isEmpty ? 0 : scores.reduce(0, +) / scores.count
    }
    
    private func getLeaderboardRank() -> Int {
        let sortedScores = dataService.leaderboard.sorted { $0.score > $1.score }
        if let userScore = dataService.gameState.highScores.values.max(),
           let rank = sortedScores.firstIndex(where: { $0.score <= userScore }) {
            return rank + 1
        }
        return dataService.leaderboard.count + 1
    }
    
    private func completedByDifficulty(_ difficulty: GameLevel.Difficulty) -> Int {
        let levels = dataService.getLevels().filter { $0.difficulty == difficulty }
        let completed = levels.filter { dataService.gameState.completedLevels.contains($0.id) }
        return completed.count
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 26))
                .foregroundColor(Color("ElementColor"))
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.7))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
        )
    }
}

// MARK: - Stat Row
struct StatRow: View {
    let title: String
    let value: String
    let icon: String
    var color: Color = .white
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 22)
                .font(.system(size: 16))
            
            Text(title)
                .foregroundColor(.white)
                .font(.system(size: 15))
                .lineLimit(1)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.white)
                .font(.system(size: 15, weight: .bold))
                .lineLimit(1)
        }
    }
}

