//
//  AchievementsView.swift
//  cc95
//
//  Created by IGOR on 17/11/2025.
//

import SwiftUI

struct AchievementsView: View {
    @ObservedObject private var dataService = DataService.shared
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Text("Achievements")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("\(unlockedCount)/\(achievements.count) Unlocked")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(height: 80)
                .frame(maxWidth: .infinity)
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
                    LazyVStack(spacing: 16) {
                        ForEach(achievements) { achievement in
                            AchievementCard(
                                achievement: achievement,
                                isUnlocked: checkAchievement(achievement)
                            )
                        }
                    }
                    .padding(20)
                }
            }
        }
    }
    
    // MARK: - Achievements Data
    private var achievements: [Achievement] {
        [
            Achievement(id: "first_level", title: "First Steps", description: "Complete your first level", icon: "flag.fill", requirement: 1),
            Achievement(id: "five_levels", title: "Getting Started", description: "Complete 5 levels", icon: "star.fill", requirement: 5),
            Achievement(id: "all_levels", title: "Master Player", description: "Complete all levels", icon: "crown.fill", requirement: 10),
            Achievement(id: "score_1000", title: "Score Hunter", description: "Reach 1000 total score", icon: "target", requirement: 1000),
            Achievement(id: "score_5000", title: "High Scorer", description: "Reach 5000 total score", icon: "flame.fill", requirement: 5000),
            Achievement(id: "perfect_level", title: "Perfectionist", description: "Complete a level with 0 mistakes", icon: "checkmark.seal.fill", requirement: 1),
            Achievement(id: "speed_demon", title: "Speed Demon", description: "Complete a level in under 30 seconds", icon: "bolt.fill", requirement: 1),
            Achievement(id: "combo_master", title: "Combo Master", description: "Match 5 pairs in a row without mistakes", icon: "multiply.circle.fill", requirement: 5),
            Achievement(id: "dedicated", title: "Dedicated Player", description: "Play 3 days in a row", icon: "calendar", requirement: 3),
            Achievement(id: "expert", title: "Expert Level", description: "Complete an Expert difficulty level", icon: "graduationcap.fill", requirement: 1)
        ]
    }
    
    private var unlockedCount: Int {
        achievements.filter { checkAchievement($0) }.count
    }
    
    private func checkAchievement(_ achievement: Achievement) -> Bool {
        switch achievement.id {
        case "first_level":
            return dataService.gameState.completedLevels.count >= 1
        case "five_levels":
            return dataService.gameState.completedLevels.count >= 5
        case "all_levels":
            return dataService.gameState.completedLevels.count >= dataService.getLevels().count
        case "score_1000":
            return dataService.gameState.totalScore >= 1000
        case "score_5000":
            return dataService.gameState.totalScore >= 5000
        case "perfect_level":
            return dataService.gameState.completedLevels.count >= 3
        case "speed_demon":
            return dataService.gameState.completedLevels.count >= 5
        case "combo_master":
            return dataService.gameState.totalScore >= 2000
        case "dedicated":
            return dataService.gameState.completedLevels.count >= 7
        case "expert":
            let expertLevels = dataService.getLevels().filter { $0.difficulty == .expert }
            return expertLevels.contains { dataService.gameState.completedLevels.contains($0.id) }
        default:
            return false
        }
    }
}

// MARK: - Achievement Model
struct Achievement: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let requirement: Int
}

// MARK: - Achievement Card
struct AchievementCard: View {
    let achievement: Achievement
    let isUnlocked: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? Color("ElementColor") : Color.white.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 28))
                    .foregroundColor(isUnlocked ? .white : .white.opacity(0.3))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(achievement.title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(isUnlocked ? .white : .white.opacity(0.5))
                
                Text(achievement.description)
                    .font(.system(size: 14))
                    .foregroundColor(isUnlocked ? .white.opacity(0.7) : .white.opacity(0.3))
                    .lineLimit(2)
            }
            
            Spacer()
            
            if isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(isUnlocked ? 0.1 : 0.05))
        )
    }
}
