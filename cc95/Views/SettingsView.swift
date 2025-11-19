//
//  SettingsView.swift
//  cc95
//
//  Created by IGOR on 17/11/2025.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject private var dataService = DataService.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var showingResetAlert = false
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Spacer()
                    
                    Text("Settings")
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
                        // Game Settings
                        SettingSection(title: "Game Settings") {
                            SettingRow(
                                icon: "hand.tap.fill",
                                title: "Haptic Feedback",
                                toggle: Binding(
                                    get: { dataService.settings.hapticFeedback },
                                    set: { _ in dataService.toggleHapticFeedback() }
                                )
                            )
                        }
                        
                        // Statistics
                        SettingSection(title: "Game Progress") {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(Color("ElementColor"))
                                Text("Total Score")
                                    .foregroundColor(.white)
                                Spacer()
                                Text("\(dataService.gameState.totalScore)")
                                    .foregroundColor(.white)
                                    .font(.system(size: 16, weight: .bold))
                            }
                            Divider().background(Color.white.opacity(0.2))
                            HStack {
                                Image(systemName: "flag.fill")
                                    .foregroundColor(Color("ElementColor"))
                                Text("Levels Completed")
                                    .foregroundColor(.white)
                                Spacer()
                                Text("\(dataService.gameState.completedLevels.count)")
                                    .foregroundColor(.white)
                                    .font(.system(size: 16, weight: .bold))
                            }
                            Divider().background(Color.white.opacity(0.2))
                            HStack {
                                Image(systemName: "trophy.fill")
                                    .foregroundColor(Color("ElementColor"))
                                Text("Best Score")
                                    .foregroundColor(.white)
                                Spacer()
                                Text("\(dataService.gameState.highScores.values.max() ?? 0)")
                                    .foregroundColor(.white)
                                    .font(.system(size: 16, weight: .bold))
                            }
                        }
                        
                        // Danger Zone
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Danger Zone")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.red)
                            
                            Button(action: {
                                showingResetAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "trash.circle.fill")
                                        .foregroundColor(.red)
                                    Text("Reset All Progress")
                                        .foregroundColor(.red)
                                        .font(.system(size: 16, weight: .semibold))
                                    Spacer()
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.red.opacity(0.1))
                                )
                            }
                        }
                    }
                    .padding(20)
                }
            }
        }
        .alert("Reset All Progress", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                dataService.resetGameState()
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("This will delete all your game progress, scores, and achievements. This action cannot be undone.")
        }
    }
}

// MARK: - Setting Section
struct SettingSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                content
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
            )
        }
    }
}

// MARK: - Setting Row
struct SettingRow: View {
    let icon: String
    let title: String
    @Binding var toggle: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color("ElementColor"))
            Text(title)
                .foregroundColor(.white)
            Spacer()
            Toggle("", isOn: $toggle)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: Color("ElementColor")))
        }
    }
}
