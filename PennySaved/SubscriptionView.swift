//
//  SubscriptionView.swift
//  PennySaved
//
//  Created by Victor Saint Hilaire on 10/8/24.
//


import SwiftUI

struct SubscriptionView: View {
    let subscriptionPlans: [SubscriptionPlan]
    
    @State private var selectedPlan: SubscriptionPlan?
    
    let accentColor = Color(hex: "C9F573")
    let backgroundColor = Color(hex: "0B1523")
    let secondaryColor = Color(hex: "212B33")
    
    init() {
        let weeklyPlan = SubscriptionPlan(name: "Weekly", price: 0.99, period: "week")
        let monthlyPlan = SubscriptionPlan(name: "Monthly", price: 2.99, period: "month")
        let annualPlan = SubscriptionPlan(name: "Annual", price: 29.99, period: "year")
        let lifetimePlan = SubscriptionPlan(name: "Lifetime", price: 49.99, period: "one-time")
        
        self.subscriptionPlans = [
            weeklyPlan,
            monthlyPlan.withSavings(comparedTo: weeklyPlan),
            annualPlan.withSavings(comparedTo: weeklyPlan),
            lifetimePlan.withSavings(comparedTo: weeklyPlan)
        ]
        
        _selectedPlan = State(initialValue: weeklyPlan)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Unlock Premium Features")
                        .font(.title.bold())
                        .foregroundColor(accentColor)
                    
                    Text("You've reached the limit of free features. Upgrade to Premium to create unlimited goals and savings, and access more features!")
                        .foregroundColor(.white)
                        .padding(.bottom)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        FeatureRow(icon: "target", text: "Unlimited financial goals", accentColor: accentColor)
                        FeatureRow(icon: "dollarsign.circle", text: "Unlimited savings tracking", accentColor: accentColor)
                        FeatureRow(icon: "chart.pie.fill", text: "Detailed expense analysis", accentColor: accentColor)
                        FeatureRow(icon: "folder.badge.plus", text: "Unlimited custom categories", accentColor: accentColor)
                    }
                    
                    VStack(spacing: 15) {
                        ForEach(subscriptionPlans, id: \.name) { plan in
                            PlanButton(plan: plan, isSelected: selectedPlan == plan, accentColor: accentColor, secondaryColor: secondaryColor) {
                                selectedPlan = plan
                            }
                        }
                    }
                    
                    Button(action: {
                        // Implement subscription action
                    }) {
                        Text("Subscribe Now")
                            .font(.headline)
                            .foregroundColor(backgroundColor)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(accentColor)
                            .cornerRadius(10)
                    }
                    .padding(.top)
                }
                .padding()
            }
            .background(backgroundColor.edgesIgnoringSafeArea(.all))
            .navigationTitle("Premium Subscription")
            .navigationBarTitleDisplayMode(.inline)
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
        }
    }
}

struct PlanButton: View {
    let plan: SubscriptionPlan
    let isSelected: Bool
    let accentColor: Color
    let secondaryColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading) {
                    Text(plan.name)
                        .font(.headline)
                    Text(String(plan.price) + " / " + plan.period)
                        .font(.subheadline)
                }
                Spacer()
                if let savings = plan.savings {
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
}

struct SubscriptionPlan: Equatable {
    let name: String
    let price: Double
    let period: String
    var savings: String?
    
    var formattedPrice: String {
        return String(format: "$%.2f", price)
    }
    
    func withSavings(comparedTo baseplan: SubscriptionPlan) -> SubscriptionPlan {
        var newPlan = self
        let weeksInYear = 52.0
        _ = 4.0
        
        let baseYearlyPrice: Double
        let yearlyPrice: Double
        
        switch baseplan.period {
        case "week":
            baseYearlyPrice = baseplan.price * weeksInYear
        case "month":
            baseYearlyPrice = baseplan.price * 12
        case "year":
            baseYearlyPrice = baseplan.price
        default:
            return self
        }
        
        switch self.period {
        case "week":
            yearlyPrice = self.price * weeksInYear
        case "month":
            yearlyPrice = self.price * 12
        case "year":
            yearlyPrice = self.price
        case "one-time":
            yearlyPrice = self.price / 2  // Asumimos 2 años de uso para el plan de por vida
        default:
            return self
        }
        
        let savingsPercentage = (baseYearlyPrice - yearlyPrice) / baseYearlyPrice * 100
        newPlan.savings = String(format: "%.0f%%", savingsPercentage)
        
        return newPlan
    }
}

#Preview {
    SubscriptionView()
}
