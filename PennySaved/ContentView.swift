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
    
    @EnvironmentObject var goalsVm: GoalsVm  // Access the GoalsVm instance
    @EnvironmentObject var savingsVm: SavingsVm  // Access the SavingsVm instance
    @AppStorage("showOnBoardingScreen") var showOnBoardingScreen = true
    @State private var showInfoSheet = false  // Add this line
    @State private var showSubscriptionView = false
    @State private var showNewGoalView = false
    @State private var showNewSavingView = false
    
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
        return savingsVm.savings.filter { formatter.string(from: $0.date ?? Date()) == todayString }
    }
    
    var savingsThisMonth: [Saving] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        let currentMonthString = formatter.string(from: Date())
        return savingsVm.savings.filter { formatter.string(from: $0.date ?? Date()) == currentMonthString }
    }
    
    var totalAmount: Double {
        savingsVm.savings.reduce(0) { $0 + ($1.amount) }
    }
    
    var totalAmountThisMonth: Double {
        savingsThisMonth.reduce(0) { $0 + ($1.amount) }
    }
    
    var monthlySavings: [(month: String, amount: Double)] {
        var monthlyData = [(month: String, amount: Double)]()
        
        for month in 1...12 {
            let startDate = Calendar.current.date(from: DateComponents(year: currentYear, month: month, day: 1))!
            let endDate = Calendar.current.date(byAdding: .month, value: 1, to: startDate)!
            let filteredSavings = savingsVm.savings.filter {
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
    
    @State private var needsRefresh: Bool = false
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    
                    Image("cabecera")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 40)
                        .padding(.horizontal, 15)
                    // PROFILE HEADER
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            NavigationLink(destination: savigsListView(saving: savingsVm.savings)) {
                                HStack {
                                    Text("View All ThinkTwiceSave")
                                    Image(systemName: "list.bullet")
                                }
                                .padding()
                                .background(Color("buttonPrimary"))
                                .foregroundStyle(.black)
                                .cornerRadius(50)
                            }
                            
                            Button(action: handleNewSavingTap) {
                                HStack{
                                    Text("New ThinkTwiceSave")
                                    Image(systemName: "plus")
                                    
                                }.padding()
                                    .background(Color("buttonPrimary"))
                                    .foregroundStyle(.black)
                                    .cornerRadius(50)
                                
                            }
                            Button(action: handleNewGoalTap) {
                                HStack {
                                    Text("New Goal")
                                    Image(systemName: "plus")
                                }
                                .padding()
                                .background(Color("buttonPrimary"))
                                .foregroundStyle(.black)
                                .cornerRadius(50)
                            }
                        } .font(.headline).bold()
                            .padding(.horizontal, 15)
                    }
                    
                    
                    // THIS MONTH SAVED & TOTAL SAVINGS
                    HStack {
                        HStack {
                            Image(systemName: "m.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40)
                            VStack(alignment:.leading) {
                                Text("This Month ThinkTwiceSave").font(.caption)
                                Text("$\(totalAmountThisMonth, specifier: "%.2f")").bold()
                            }
                            Spacer()
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: 250)
                        .background(Color("boxesBg"))
                        .cornerRadius(10)
                        .foregroundStyle(.white)
                        
                        HStack {
                            Image(systemName: "l.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40)
                            VStack(alignment:.leading) {
                                Text("Lifetime ThinkTwiceSave").font(.caption)
                                
                                Text("$\(totalAmount, specifier: "%.2f")").bold()
                            }
                            Spacer()
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: 250)
                        .background(Color("boxesBg"))
                        .cornerRadius(10)
                        .foregroundStyle(.white)
                    }.padding(.horizontal, 15)
                    
                    // Savings Chart
                    
                    
                    MonthlySavingsChartView()
                    
                    
                    // Goals Section
                    
                    HStack {
                        Text("ThinkTwiceSave Goals").foregroundStyle(.white)
                        Spacer()
                        NavigationLink(destination: GoalsListView(isForSelect: false, selectedGoal: Binding.constant(nil))) {
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
                        
                    }.padding(.horizontal, 15)
                    
                    
                    HStack{
                        if !goalsVm.goals.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack{
                                    ForEach(goalsVm.goals.prefix(3)) {goal in
                                        
                                        GoalCellView(goal: goal, isForSelect: false)
                                    }
                                }.padding(.horizontal, 15)
                            }
                        } else {
                            Spacer()
                            ContentUnavailableView("No goals found", systemImage: "figure.walk.circle.fill")
                            Spacer()
                            
                            
                            
                        }
                    }
                    
                    
                    
                    
                    // TODAY
                    HStack {
                        Text("Today").foregroundStyle(.white)
                        Spacer()
                        
                        
                    }.padding(.horizontal, 15)
                    if !savingsToday.isEmpty {
                        ForEach(savingsToday) { datum in
                            savingTransactionCellView(saving: datum)
                                .padding(.horizontal, 15)
                        }
                    } else {
                        ContentUnavailableView("No ThinkTwiceSave found Today", systemImage: "dollarsign.circle.fill")
                    }
                    
                    
                    // This Month
                    VStack(alignment: .leading){
                        Text("This Month").foregroundStyle(.white)
                        if !savingsThisMonth.isEmpty {
                            ForEach(savingsThisMonth) { datum in
                                savingTransactionCellView(saving: datum)
                                
                            }
                        } else {
                            
                            ContentUnavailableView("No ThinkTwiceSave found this month", systemImage: "dollarsign.circle.fill")
                            
                        }
                    }.padding(.horizontal, 15)
                    
                }
                Spacer()
            }.sheet(isPresented: $showOnBoardingScreen){
                
                OnboardingScreen(showOnBoardingScreen: $showOnBoardingScreen)
                    .presentationDetents([.large])
            }
           
            
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("bg"))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showInfoSheet = true  // Update this line
                    }) {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(Color("buttonPrimary"))
                    }
                }
            }
            .sheet(isPresented: $showInfoSheet) {
                InfoSheetView()
            }
            .sheet(isPresented: $showSubscriptionView) {
                SubscriptionView()
            }
            .sheet(isPresented: $showNewGoalView) {
                NewGoalView()
            }
            .sheet(isPresented: $showNewSavingView) {
                NewSavingView()
            }
        }
    }
    
    func abbreviatedMonth(from month: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM" // Full month name
        let date = dateFormatter.date(from: month)
        
        dateFormatter.dateFormat = "MMM" // Abbreviated month name
        return date != nil ? dateFormatter.string(from: date!) : month
    }
    
    
    func MonthlySavingsChartView() -> some View {
        
        
        
        return VStack(alignment: .leading, spacing: 5) {
            HStack {
                
                VStack(alignment: .leading, spacing: .zero){
                    HStack{
                        Text("Monthly Breakdown")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Spacer()
                        
                    }
                    Text("Current Year")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                
                
            }
            
            .padding()
           
            
            ScrollView(.horizontal, showsIndicators: false) {
                // Calculate the maximum value to scale the bar heights
                let maxAmount = monthlySavings.map { $0.amount }.max() ?? 1.0

                // Show the bar chart for each month
                HStack(alignment: .bottom, spacing: 5) {
                    ForEach(monthlySavings, id: \.month) { data in
                        VStack {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color("buttonPrimary"))
                                .frame(
                                    width: 20,
                                    height: maxAmount > 0 ? CGFloat(data.amount) / CGFloat(maxAmount) * 50 : 0 // Scale height based on the maximum value, ensure no division by zero
                                )
                            
                            VStack {
                                Text("$\(data.amount, specifier: "%.2f")").bold()
                                Text(data.month)
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 2)
                        }
                        .padding(.horizontal, 5)
                    }
                }
                .padding(.vertical)
                .padding(.horizontal, 10)

                
                
                
            }
        }.foregroundStyle(.white)
        
            .frame(maxHeight: .infinity)
            .background(Color("boxesBg"))
            .cornerRadius(10)
            .padding(.horizontal, 15)
        
        
        
    }
    
    private func handleNewGoalTap() {
        if goalsVm.goalCount >= 3 {
            showSubscriptionView = true
        } else {
            showNewGoalView = true
        }
    }
    
    private func handleNewSavingTap() {
        if savingsVm.savingsCount >= 2 {
            showSubscriptionView = true
        } else {
            showNewSavingView = true
        }
    }
}






#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}


