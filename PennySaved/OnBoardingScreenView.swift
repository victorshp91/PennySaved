//
//  OnBoardingScreenView.swift
//  PennySaved
//
//  Created by Victor Saint Hilaire on 8/30/24.
//

import SwiftUI

struct OnboardingScreen: View {
    @State private var currentSlide = 0
    @Binding var showOnBoardingScreen: Bool
    @State private var showSubscriptionView = false
    
    let slides = [
        OnboardingSlide(title: "Save on Impulse Buys", description: "Track items you almost bought but didn't. Watch your savings grow!", imageName: "dollarsign.circle.fill"),
        OnboardingSlide(title: "Set Exciting Goals", description: "Apply your savings to meaningful goals and watch them come to life.", imageName: "target"),
        OnboardingSlide(title: "Boost Your Finances", description: "Make smarter decisions and achieve financial freedom faster!", imageName: "bolt.fill")
    ]
    
    // Custom colors
    let accentColor = Color(hex: "C9F573")
    let backgroundColor = Color(hex: "0B1523")
    let secondaryColor = Color(hex: "212B33")
    
    var body: some View {
        ZStack {
            backgroundColor.edgesIgnoringSafeArea(.all)
            
            VStack {
                TabView(selection: $currentSlide) {
                    ForEach(0..<slides.count, id: \.self) { index in
                        VStack {
                            Image(systemName: slides[index].imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 150, height: 150)
                                .foregroundColor(accentColor)
                                .padding()
                            
                            Text(slides[index].title)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(accentColor)
                                .padding()
                            
                            Text(slides[index].description)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                                .padding()
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                
                Button(action: {
                    if currentSlide < slides.count - 1 {
                        withAnimation {
                            currentSlide += 1
                        }
                    } else {
                        showSubscriptionView = true
                    }
                }) {
                    Text(currentSlide < slides.count - 1 ? "Next" : "Get Started")
                        .font(.headline)
                        .foregroundColor(backgroundColor)
                        .frame(width: 200, height: 50)
                        .background(accentColor)
                        .cornerRadius(25)
                }
                .padding()
            }
        }
        .onDisappear {
            UserDefaults.standard.set(false, forKey: "showOnBoardingScreen")
        }
        .fullScreenCover(isPresented: $showSubscriptionView) {
            SubscriptionView()
                .onDisappear {
                    showOnBoardingScreen = false
                }
        }
    }
}

struct OnboardingSlide {
    let title: String
    let description: String
    let imageName: String
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct OnboardingScreen_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingScreen(showOnBoardingScreen: Binding.constant(true))
    }
}
