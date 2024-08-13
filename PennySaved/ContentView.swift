//
//  ContentView.swift
//  PennySaved
//
//  Created by Victor Saint Hilaire on 8/12/24.
//

import SwiftUI
import CoreData
import Charts

struct ContentView: View {
    @FetchRequest(
        entity: Saving.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Saving.date, ascending: false)]
    ) var savings: FetchedResults<Saving>
    
    @Environment(\.managedObjectContext) private var viewContext

    var today: Date {
        Calendar.current.startOfDay(for: Date())
    }
    
    var currentMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: Date())
    }

    var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }
    
    var savingsToday: [Saving] {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        let todayString = formatter.string(from: today)
        return savings.filter { formatter.string(from: $0.date ?? Date()) == todayString }
    }
    
    var savingsThisMonth: [Saving] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        let currentMonthString = formatter.string(from: Date())
        return savings.filter { formatter.string(from: $0.date ?? Date()) == currentMonthString }
    }

    var totalAmount: Double {
        savings.reduce(0) { $0 + ($1.amount) }
    }

    var totalAmountThisMonth: Double {
        savingsThisMonth.reduce(0) { $0 + ($1.amount) }
    }

    var monthlySavings: [(month: String, amount: Double)] {
        var monthlyData = [(month: String, amount: Double)]()
        
        for month in 1...12 {
            let startDate = Calendar.current.date(from: DateComponents(year: currentYear, month: month, day: 1))!
            let endDate = Calendar.current.date(byAdding: .month, value: 1, to: startDate)!
            let filteredSavings = savings.filter {
                if let date = $0.date {
                    return date >= startDate && date < endDate
                }
                return false
            }
            let totalAmountForMonth = filteredSavings.reduce(0) { $0 + ($1.amount) }
            let monthName = DateFormatter().monthSymbols[month - 1]
            monthlyData.append((month: monthName, amount: totalAmountForMonth))
        }
        
        return monthlyData
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // PROFILE HEADER
                    HStack {
                        Image("profile")
                            .resizable()
                            .clipShape(Circle())
                            .scaledToFill()
                            .frame(width: 65, height: 65)
                        VStack(alignment:.leading) {
                            Text("Welcome, Arina").bold()
                            Text("Track your potential savings with PennySaved.").foregroundStyle(.secondary)
                        }
                        .font(.subheadline)
                        Spacer()
                        NavigationLink(destination: NewSavingView()) {
                            Image(systemName: "plus")
                                .padding()
                                .background(Color("buttonPrimary"))
                                .foregroundStyle(.black)
                                .clipShape(Circle())
                        }
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .background(Color("boxesBg"))
                    .cornerRadius(50)
                    .foregroundStyle(.white)
                    
                    // THIS MONTH SAVED & TOTAL SAVINGS
                    HStack {
                        HStack {
//                            Image(systemName: "m.circle.fill")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 40)
                            VStack(alignment:.leading) {
                                Text("This Month Potential Savings")
                                Text("$\(totalAmountThisMonth, specifier: "%.2f")").bold()
                            }
                            Spacer()
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("boxesBg"))
                        .cornerRadius(10)
                        .foregroundStyle(.white)
                        
                        HStack {
//                            Image(systemName: "t.circle.fill")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 40)
                            VStack(alignment:.leading) {
                                Text("Lifetime Potential Savings")
                                Text("$\(totalAmount, specifier: "%.2f")").bold()
                            }
                            Spacer()
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("boxesBg"))
                        .cornerRadius(10)
                        .foregroundStyle(.white)
                    }
                    
                    // Savings Chart
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Monthly Breakdown")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Chart {
                            ForEach(monthlySavings, id: \.month) { data in
                                BarMark(
                                    x: .value("Month", data.month),
                                    y: .value("Saving", data.amount)
                                )
                                .annotation {
                                    Text("$\(data.amount.formatted())")
                                        .font(.caption)
                                        .foregroundStyle(.white)
                                }
                                .annotation(position: .bottom, alignment: .center, spacing: 5) {
                                    Text(abbreviatedMonth(from: data.month))
                                        .font(.caption)
                                        .foregroundStyle(.white)
                                }
                                .foregroundStyle(Color("buttonPrimary"))
                                .cornerRadius(5)
                            }
                        }
                        .chartXAxis(.hidden)
                        .chartYAxis(.hidden)
                    }
                    .foregroundStyle(.white)
                    .padding()
                    .background(Color("boxesBg"))
                    .cornerRadius(10)
                    
                    // Goals Section
                    HStack {
                        Text("Savings Goals").foregroundStyle(.white)
                        Spacer()
                        Button(action: {
                            print("View All")
                        }) {
                            HStack {
                                Spacer()
                                Text("View All")
                                Image(systemName: "arrow.forward.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                            }
                            .foregroundStyle(Color("buttonPrimary"))
                            .frame(maxWidth:.infinity, maxHeight: 25)
                        }
                    }
                    DeckCompletionView()
                    
                    // TODAY
                    HStack {
                        Text("Potential Purchases Today").foregroundStyle(.white)
                        Spacer()
                        Button(action: {}) {
                            HStack {
                                Spacer()
                                Text("View All")
                                Image(systemName: "arrow.forward.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                            }
                            .foregroundStyle(Color("buttonPrimary"))
                            .frame(maxWidth:.infinity, maxHeight: 25)
                        }
                    }
                    if !savingsToday.isEmpty {
                        ForEach(savingsToday) { datum in
                            savingTransactionCellView(saving: datum)
                        }
                    } else {
                        Text("Add a Saving Entry")
                            .foregroundStyle(.white)
                    }
                    
                    if !savingsThisMonth.isEmpty {
                        // This Month
                        Text("Potential Purchases This Month").foregroundStyle(.white)
                        ForEach(savingsThisMonth) { datum in
                            savingTransactionCellView(saving: datum)
                        }
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 15)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("bg"))
            .navigationTitle("Dashboard")
        }
    }
    
    func abbreviatedMonth(from month: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM" // Full month name
        let date = dateFormatter.date(from: month)
        
        dateFormatter.dateFormat = "MMM" // Abbreviated month name
        return date != nil ? dateFormatter.string(from: date!) : month
    }
}

struct DeckCompletionView: View {
    @State private var progress: Double = 0.0 // Progress of deck completion
    
    var body: some View {
        let ownedCards = 25 // Number of owned cards in the set
        let totalCards = 100 // Total number of cards in the set
        let targetProgress = Double(ownedCards) / Double(totalCards) // Target progress based on owned and total cards
        
        return VStack(spacing: 5) {
            Text("Buy a Car")
                .foregroundColor(.white)
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 10) // Background circle
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                    .stroke(Color("buttonPrimary"), lineWidth: 10) // Progress circle
                    .frame(width: 80, height: 80)
                    .rotationEffect(Angle(degrees: -90)) // Rotate circle to start from top
                    .padding()
                    .overlay(
                        Text("\(Int(progress * 100))%") // Display progress percentage
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
                    .animation(.easeInOut, value: progress) // Animation for progress change
            }
        }
        .padding()
        .frame(width: 180, height: 150) // Ensure the size matches StatisticView
        .background(Color("boxesBg")) // Background color
        .cornerRadius(16) // Corner radius for rounded corners
        .onAppear {
            withAnimation {
                progress = targetProgress // Animate progress on appear
            }
        }
        .onChange(of: ownedCards) {
            withAnimation {
                progress = targetProgress // Update progress when target changes
            }
        }
    }
}



#Preview {
    ContentView()
}


