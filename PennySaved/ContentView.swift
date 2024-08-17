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
    @FetchRequest(
        entity: Saving.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Saving.date, ascending: false)]
    ) var savings: FetchedResults<Saving>
    

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
    
    @State private var needsRefresh: Bool = false
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // PROFILE HEADER
                    ScrollView(.horizontal) {
                        HStack {
                            NavigationLink(destination: NewSavingView()) {
                                HStack{
                                    Text("New Almost Saving")
                                    Image(systemName: "plus")
                                    
                                }.padding()
                                    .background(Color("buttonPrimary"))
                                    .foregroundStyle(.black)
                                    .cornerRadius(50)
                                   
                            }
                            NavigationLink(destination: NewGoalView()) {
                                HStack{
                                    Text("New Goal")
                                    Image(systemName: "plus")
                                    
                                }.padding()
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
                                Text("This Month Potential Savings").font(.caption)
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
                                Text("Lifetime Potential Savings").font(.caption)
                                
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
                    VStack(alignment: .leading, spacing: 10) {
                        VStack(alignment: .leading, spacing: .zero){
                            Text("Monthly Breakdown")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text("Current Year")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        Chart {
                            ForEach(monthlySavings, id: \.month) { data in
                                BarMark(
                                    x: .value("Month", data.month),
                                    y: .value("Saving", data.amount)
                                )
                                .annotation {
                                    Text("$\(data.amount.formatted())")
                                        .rotationEffect(.degrees(-90))
                                        .font(.caption)
                                        .frame(maxHeight: .infinity)
                                        .foregroundStyle(.white)
                                        .fixedSize()
                                        .padding(.vertical)
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
                    .padding(.horizontal, 5)
              
                   
                    
                    // Goals Section
                    
                    HStack {
                        Text("Savings Goals").foregroundStyle(.white)
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
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack{
                            if !goalsVm.goals.isEmpty {
                                ForEach(goalsVm.goals) {goal in
                                    
                                    GoalCellView(goal: goal)
                                }
                            } else {
                                ContentUnavailableView("No goals found", systemImage: "figure.walk.circle.fill")
                                
                            }
                        }  .padding(.horizontal, 15)
                    }

                   
                    
                    // TODAY
                    HStack {
                        Text("Today").foregroundStyle(.white)
                        Spacer()
                        NavigationLink(destination: savigsListView(saving: Array(savings))) {
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
                    if !savingsToday.isEmpty {
                        ForEach(savingsToday) { datum in
                            savingTransactionCellView(saving: datum)
                                .padding(.horizontal, 15)
                        }
                    } else {
                        ContentUnavailableView("No savings found Today", systemImage: "dollarsign.circle.fill")
                    }
                    
                   
                        // This Month
                        VStack(alignment: .leading){
                            Text("This Month").foregroundStyle(.white)
                            if !savingsThisMonth.isEmpty {
                                ForEach(savingsThisMonth) { datum in
                                    savingTransactionCellView(saving: datum)
                                        
                                }
                            } else {
                                
                                ContentUnavailableView("No savings found this month", systemImage: "dollarsign.circle.fill")
                                
                            }
                        }.padding(.horizontal, 15)
                    
                }
                Spacer()
            }
            
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





#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}


