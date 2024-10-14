//
//  PremiumBadgeView.swift
//  PennySaved
//
//  Created by Victor Saint Hilaire on 10/12/24.
//

import SwiftUI

struct PremiumBadgeView: View {
    @EnvironmentObject var storeKit: StoreKitManager
    @State private var showingSubscriptionView = false
    
    var body: some View {
        Group {
            if storeKit.hasActiveSubscription {
                premiumBadge
            } else {
                upgradeToPremiumButton
            }
        }
        .sheet(isPresented: $showingSubscriptionView) {
            SubscriptionView()
        }
    }
    
    private var premiumBadge: some View {
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
    
    private var upgradeToPremiumButton: some View {
        Button(action: {
            showingSubscriptionView = true
        }) {
            HStack(spacing: 8) {
                Image(systemName: "crown")
                    .foregroundColor(.yellow)
                
                Text("Upgrade")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.black.opacity(0.6))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color("buttonPrimary"), lineWidth: 2)
            )
        }
    }
}
