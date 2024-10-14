//
//  SubscriptionView.swift
//  PennySaved
//
//  Created by Victor Saint Hilaire on 10/8/24.
//


import SwiftUI
import StoreKit

struct SubscriptionView: View {
    @EnvironmentObject var storeKit: StoreKitManager
    @State private var selectedProduct: Product?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var purchaseSuccessful = false
    @Environment(\.dismiss) private var dismiss
    
    let accentColor = Color(hex: "C9F573")
    let backgroundColor = Color(hex: "0B1523")
    let secondaryColor = Color(hex: "212B33")
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Unlock Premium Features")
                        .font(.title.bold())
                        .foregroundColor(accentColor)
                    
                    Text("You've reached the limit of free features. Upgrade to Premium to remove these limitations:")
                        .foregroundColor(.white)
                        .padding(.bottom)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        LimitationRow(icon: "arrow.up.circle.fill", text: "Only 12 ThinkTwiceSave Records", premium: "Unlimited Records", accentColor: accentColor)
                        LimitationRow(icon: "flag.fill", text: "Only 6 ThinkTwiceSave Goals", premium: "Unlimited Goals", accentColor: accentColor)
                        LimitationRow(icon: "folder.fill", text: "Only 6 Custom Categories", premium: "Unlimited Categories", accentColor: accentColor)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(secondaryColor)
                    .cornerRadius(10)
                    
                    Text("Premium Benefits:")
                        .font(.headline)
                        .foregroundColor(accentColor)
                        .padding(.top)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        FeatureRow(icon: "infinity", text: "Unlimited ThinkTwiceSave Records", accentColor: accentColor)
                        FeatureRow(icon: "flag.fill", text: "Unlimited ThinkTwiceSave Goals", accentColor: accentColor)
                        FeatureRow(icon: "folder.fill", text: "Unlimited Custom Categories", accentColor: accentColor)
                        FeatureRow(icon: "chart.pie.fill", text: "Detailed savings analysis", accentColor: accentColor)
                        FeatureRow(icon: "icloud.and.arrow.up", text: "Cloud sync and backup", accentColor: accentColor)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(secondaryColor)
                    .cornerRadius(10)
                    
                    VStack(spacing: 15) {
                        ForEach(storeKit.products, id: \.id) { product in
                            PlanButton(product: product,
                                       isSelected: selectedProduct == product,
                                       accentColor: accentColor,
                                       secondaryColor: secondaryColor,
                                       action: { selectedProduct = product })
                        }
                    }
                    
                    Button(action: {
                        if let product = selectedProduct {
                            Task {
                                do {
                                    if (try await storeKit.purchase(product)) != nil {
                                        alertMessage = "Thank you for your purchase!"
                                        purchaseSuccessful = true
                                        showingAlert = true
                                        await storeKit.updatePurchasedProducts()
                                    } else {
                                        alertMessage = "Purchase was cancelled or is pending."
                                        showingAlert = true
                                    }
                                } catch {
                                    alertMessage = "Failed to purchase: \(error.localizedDescription)"
                                    showingAlert = true
                                }
                            }
                        }
                    }) {
                        Text("Upgrade Now")
                            .font(.headline)
                            .foregroundColor(backgroundColor)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(accentColor)
                            .cornerRadius(10)
                    }
                    .padding(.top)
                    .disabled(selectedProduct == nil)
                    
                    footerView
                }
                .padding()
            }
            .background(backgroundColor.edgesIgnoringSafeArea(.all))
            .navigationTitle("Premium Subscription")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: closeButton)
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("Purchase Status"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK")) {
                        if purchaseSuccessful {
                            dismiss()
                        }
                    }
                )
            }
        }
    }
    
    private var closeButton: some View {
        Button(action: {
            dismiss()
        }) {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.white)
                .font(.title2)
        }
    }
    
    private var footerView: some View {
        VStack(spacing: 20) {
            Button(action: {
                Task {
                    do {
                        try await AppStore.sync()
                    } catch {
                        print(error)
                    }
                }
            }) {
                Text("Restore Purchases")
                    .foregroundColor(accentColor)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(secondaryColor)
                    .cornerRadius(10)
            }
            
            VStack(spacing: 15) {
                HStack {
                    NavigationLink(destination: PrivacyPolicyView()) {
                        Text("Privacy Policy")
                    }
                    Spacer()
                    NavigationLink(destination: TermsAndConditionsView()) {
                        Text("Terms & Conditions")
                    }
                }
                .foregroundColor(accentColor)
                
                Text("Payment will be charged to your App Store account at confirmation of purchase. Subscription automatically renews unless turned off at least 24 hours before the end of the current period. Manage subscriptions in your Account Settings after purchase.")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .background(secondaryColor)
            .cornerRadius(10)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    let accentColor: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(accentColor)
            Text(text)
                .foregroundColor(.white)
            Spacer()
        }
    }
}

struct PlanButton: View {
    let product: Product
    let isSelected: Bool
    let accentColor: Color
    let secondaryColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading) {
                    Text(product.displayName)
                        .font(.headline)
                    Text(subscriptionPeriod)
                        .font(.subheadline)
                }
                Spacer()
                if let savings = calculateSavings() {
                    Text(savings)
                        .font(.caption)
                        .padding(5)
                        .background(accentColor.opacity(0.2))
                        .cornerRadius(5)
                }
            }
            .padding()
            .background(isSelected ? accentColor.opacity(0.1) : secondaryColor)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? accentColor : Color.clear, lineWidth: 2)
            )
        }
        .foregroundColor(.white)
    }
    
    private var subscriptionPeriod: String {
        if let subscription = product.subscription {
            switch subscription.subscriptionPeriod.unit {
            case .day: return "\(product.displayPrice) / day"
            case .week: return "\(product.displayPrice) / week"
            case .month: return "\(product.displayPrice) / month"
            case .year: return "\(product.displayPrice) / year"
            @unknown default: return product.displayPrice
            }
        } else {
            return "\(product.displayPrice) / Lifetime"
        }
    }
    
    private func calculateSavings() -> String? {
        switch product.id {
        case "thinkTwiceWeekly":
            return nil  // No hay ahorro para el plan semanal
        case "ThinkTwiceMonthly":
            return "Save 25%"  // (0.99 * 4 - 2.99) / (0.99 * 4) ≈ 25%
        case "ThinkTwiceYearly":
            return "Save 42%"  // (0.99 * 52 - 29.99) / (0.99 * 52) ≈ 42%
        case "ThinkTwiceLifetime":
            return "Best Value"
        default:
            return nil
        }
    }
}

struct LimitationRow: View {
    let icon: String
    let text: String
    let premium: String
    let accentColor: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(accentColor)
            VStack(alignment: .leading) {
                Text(text)
                    .foregroundColor(.white)
                Text(premium)
                    .foregroundColor(accentColor)
                    .font(.caption)
            }
            Spacer()
        }
    }
}

#Preview {
    SubscriptionView()
}
