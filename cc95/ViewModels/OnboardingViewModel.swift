//
//  OnboardingViewModel.swift
//  cc95
//
//  Created by IGOR on 17/11/2025.
//

import SwiftUI
import Combine

class OnboardingViewModel: ObservableObject {
    @Published var currentPage: Int = 0
    @Published var isOnboardingComplete: Bool = false
    
    private let dataService = DataService.shared
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Welcome!",
            description: "Challenge your mind with strategic puzzles, rotating shapes, and exciting gameplay",
            imageName: "circle.hexagongrid.fill",
            color: Color("ElementColor")
        ),
        OnboardingPage(
            title: "Match Shapes",
            description: "Select two identical shapes to create a match and score points",
            imageName: "square.on.square",
            color: Color("ElementColor")
        ),
        OnboardingPage(
            title: "Rotate to Align",
            description: "Long press on shapes to rotate them and align perfectly with their match",
            imageName: "arrow.clockwise.circle.fill",
            color: Color("ElementColor")
        ),
        OnboardingPage(
            title: "Beat the Clock",
            description: "Complete levels before time runs out to unlock new challenges",
            imageName: "timer",
            color: Color("ElementColor")
        ),
        OnboardingPage(
            title: "Let's Play!",
            description: "Start your puzzle journey and become a master!",
            imageName: "play.circle.fill",
            color: Color("ElementColor")
        )
    ]
    
    func nextPage() {
        if currentPage < pages.count - 1 {
            currentPage += 1
        } else {
            completeOnboarding()
        }
    }
    
    func previousPage() {
        if currentPage > 0 {
            currentPage -= 1
        }
    }
    
    func skipOnboarding() {
        completeOnboarding()
    }
    
    private func completeOnboarding() {
        isOnboardingComplete = true
        dataService.gameState.hasCompletedOnboarding = true
        dataService.saveGameState()
    }
}

struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
    let color: Color
}

