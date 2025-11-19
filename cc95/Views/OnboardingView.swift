//
//  OnboardingView.swift
//  cc95
//
//  Created by IGOR on 17/11/2025.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button(action: {
                        viewModel.skipOnboarding()
                        isPresented = false
                    }) {
                        Text("Skip")
                            .foregroundColor(Color("ElementColor"))
                            .font(.system(size: 16))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 8)
                
                // Page content
                TabView(selection: $viewModel.currentPage) {
                    ForEach(Array(viewModel.pages.enumerated()), id: \.element.id) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                
                // Navigation buttons
                HStack(spacing: 20) {
                    if viewModel.currentPage > 0 {
                        Button(action: {
                            withAnimation {
                                viewModel.previousPage()
                            }
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .foregroundColor(Color("ElementColor"))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color("ElementColor"), lineWidth: 2)
                            )
                        }
                    }
                    
                    Button(action: {
                        withAnimation {
                            if viewModel.currentPage == viewModel.pages.count - 1 {
                                viewModel.nextPage()
                                isPresented = false
                            } else {
                                viewModel.nextPage()
                            }
                        }
                    }) {
                        HStack {
                            Text(viewModel.currentPage == viewModel.pages.count - 1 ? "Get Started" : "Next")
                            if viewModel.currentPage != viewModel.pages.count - 1 {
                                Image(systemName: "chevron.right")
                            }
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color("ElementColor"))
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: page.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(page.color)
            
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                
                Text(page.description)
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(4)
                    .minimumScaleFactor(0.9)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
        }
        .padding()
    }
}

