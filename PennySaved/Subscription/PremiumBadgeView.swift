//
//  PremiumBadgeView.swift
//  PennySaved
//
//  Created by Victor Saint Hilaire on 10/12/24.
//


import SwiftUI

struct PremiumBadgeView: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "crown.fill")
                .foregroundColor(.yellow)
            
            Text("PREMIUM")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.black.opacity(0.6))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.yellow, lineWidth: 2)
        )
    }
}
