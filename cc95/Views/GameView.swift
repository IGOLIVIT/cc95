//
//  GameView.swift
//  cc95
//
//  Created by IGOR on 17/11/2025.
//

import SwiftUI

struct GameView: View {
    @StateObject private var viewModel: GameViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingLevelComplete = false
    @State private var showingLevelFailed = false
    
    init(level: GameLevel) {
        _viewModel = StateObject(wrappedValue: GameViewModel(level: level))
    }
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack(spacing: 12) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14))
                            Text("Exit")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundColor(Color("ElementColor"))
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 2) {
                        Text(viewModel.currentLevel.name)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.yellow)
                            Text("\(viewModel.score)")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if viewModel.gameState == .playing {
                            viewModel.pauseGame()
                        } else if viewModel.gameState == .paused {
                            viewModel.resumeGame()
                        }
                    }) {
                        Image(systemName: viewModel.gameState == .playing ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(Color("ElementColor"))
                    }
                    .disabled(viewModel.gameState == .ready)
                }
                .padding(.horizontal, 16)
                .padding(.top, 50)
                .padding(.bottom, 8)
                
                // Stats Bar
                HStack(spacing: 8) {
                    // Timer
                    HStack(spacing: 4) {
                        Image(systemName: "timer")
                            .font(.system(size: 13))
                        Text("\(viewModel.timeRemaining)s")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(timerColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                    )
                    
                    // Combo
                    if viewModel.combo > 1 {
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 13))
                            Text("×\(viewModel.combo)")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundColor(.orange)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.orange.opacity(0.2))
                        )
                    }
                    
                    Spacer()
                    
                    // Target
                    HStack(spacing: 4) {
                        Text("\(viewModel.score)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color("ElementColor"))
                        Text("/")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.5))
                        Text("\(viewModel.currentLevel.targetScore)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                    )
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
                
                // Game Grid
                GeometryReader { geometry in
                    let gridSize = viewModel.currentLevel.gridSize
                    let spacing: CGFloat = 6
                    let availableWidth = geometry.size.width - 32
                    let availableHeight = geometry.size.height - 80
                    let maxSize = min(availableWidth, availableHeight)
                    let totalSpacing = spacing * CGFloat(gridSize - 1)
                    let cellSize = (maxSize - totalSpacing) / CGFloat(gridSize)
                    
                    VStack(spacing: 0) {
                        Spacer()
                        
                        VStack(spacing: spacing) {
                            ForEach(0..<gridSize, id: \.self) { row in
                                HStack(spacing: spacing) {
                                    ForEach(0..<gridSize, id: \.self) { col in
                                        if let shape = viewModel.shapes.first(where: { $0.position.row == row && $0.position.col == col }) {
                                            ShapeCellView(
                                                shape: shape,
                                                isSelected: viewModel.selectedShape?.id == shape.id,
                                                size: cellSize,
                                                onTap: { viewModel.selectShape(shape) }
                                            )
                                        } else {
                                            Color.clear
                                                .frame(width: cellSize, height: cellSize)
                                        }
                                    }
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding(.horizontal, 20)
                
                // Controls
                HStack(spacing: 16) {
                    // Hint Button
                    Button(action: {
                        viewModel.useHint()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 20))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Hints")
                                    .font(.system(size: 12, weight: .medium))
                                Text("\(viewModel.hintsRemaining)")
                                    .font(.system(size: 16, weight: .bold))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(viewModel.hintsRemaining > 0 ? Color("ElementColor") : Color.white.opacity(0.2))
                        )
                    }
                    .disabled(viewModel.hintsRemaining == 0 || viewModel.gameState != .playing)
                    
                    // Stats Display
                    VStack(spacing: 8) {
                        HStack(spacing: 12) {
                            VStack(spacing: 4) {
                                Image(systemName: "hand.tap.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(Color("ElementColor"))
                                Text("\(viewModel.moves)")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                Text("Moves")
                                    .font(.system(size: 11))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .frame(maxWidth: .infinity)
                            
                            VStack(spacing: 4) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.green)
                                Text("\(viewModel.matchedPairs)")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                Text("Pairs")
                                    .font(.system(size: 11))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.1))
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
            
            // Overlays
            if viewModel.gameState == .ready {
                readyOverlay
            }
            
            if viewModel.gameState == .paused {
                pausedOverlay
            }
        }
        .edgesIgnoringSafeArea(.top)
        .alert("Level Complete! 🎉", isPresented: $showingLevelComplete) {
            Button("Continue") {
                presentationMode.wrappedValue.dismiss()
            }
            Button("Replay") {
                viewModel.resetGame()
                showingLevelComplete = false
            }
        } message: {
            Text("Score: \(viewModel.score)\nMoves: \(viewModel.moves)\nCombo: ×\(viewModel.combo)")
        }
        .alert("Time's Up! ⏰", isPresented: $showingLevelFailed) {
            Button("Try Again") {
                viewModel.resetGame()
                showingLevelFailed = false
            }
            Button("Exit") {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Score: \(viewModel.score)\nKeep practicing!")
        }
        .onChange(of: viewModel.gameState) { newState in
            if newState == .completed {
                showingLevelComplete = true
            } else if newState == .failed {
                showingLevelFailed = true
            }
        }
    }
    
    // MARK: - Timer Color
    private var timerColor: Color {
        if viewModel.timeRemaining > 20 {
            return .white
        } else if viewModel.timeRemaining > 10 {
            return .orange
        } else {
            return .red
        }
    }
    
    // MARK: - Ready Overlay
    private var readyOverlay: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Image(systemName: "flag.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(Color("ElementColor"))
                
                VStack(spacing: 12) {
                    Text("Ready?")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(viewModel.currentLevel.description)
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                VStack(spacing: 12) {
                    HStack(spacing: 20) {
                        InfoPill(icon: "timer", text: "\(viewModel.currentLevel.timeLimit)s")
                        InfoPill(icon: "target", text: "\(viewModel.currentLevel.targetScore)")
                        InfoPill(icon: "grid", text: "\(viewModel.currentLevel.gridSize)×\(viewModel.currentLevel.gridSize)")
                    }
                }
                
                Button(action: {
                    viewModel.startGame()
                }) {
                    Text("Start Game")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color("ElementColor"))
                                .shadow(color: Color("ElementColor").opacity(0.3), radius: 10)
                        )
                }
                .padding(.horizontal, 40)
            }
        }
    }
    
    // MARK: - Paused Overlay
    private var pausedOverlay: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Image(systemName: "pause.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(Color("ElementColor"))
                
                Text("Paused")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                
                VStack(spacing: 16) {
                    Button(action: {
                        viewModel.resumeGame()
                    }) {
                        Text("Resume")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color("ElementColor"))
                            )
                    }
                    
                    Button(action: {
                        viewModel.resetGame()
                    }) {
                        Text("Restart")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.white.opacity(0.2))
                            )
                    }
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Exit")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                            )
                    }
                }
                .padding(.horizontal, 40)
            }
        }
    }
}

// MARK: - Info Pill
struct InfoPill: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
            Text(text)
                .font(.system(size: 14, weight: .semibold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.2))
        )
    }
}

// MARK: - Shape Cell View
struct ShapeCellView: View {
    let shape: GameShape
    let isSelected: Bool
    let size: CGFloat
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: size * 0.15)
                    .fill(isSelected ? Color("ElementColor").opacity(0.3) : Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: size * 0.15)
                            .stroke(isSelected ? Color("ElementColor") : Color.white.opacity(0.2), lineWidth: isSelected ? 3 : 1)
                    )
                
                shape.type.shape(rotation: shape.rotation)
                    .foregroundColor(shape.type.color)
                    .frame(width: size * 0.6, height: size * 0.6)
            }
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    GameView(level: GameLevel(id: 1, name: "Test", description: "Test level", gridSize: 4, timeLimit: 60, targetScore: 100, shapeTypes: ShapeType.allCases, difficulty: .easy))
}
