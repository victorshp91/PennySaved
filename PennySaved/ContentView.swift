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
        formatter.dateFormat = "dd MMM yyyy" // Adjust this format to match your date format
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
                            Text("Your PennySaved").foregroundStyle(.secondary)
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
                    
                    // THIS MONTH SAVED
                    HStack {
                        
                        HStack{
                            Image(systemName: "m.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40)
                            VStack(alignment:.leading) {
                                Text("This Month")
                                Text("$\(totalAmountThisMonth, specifier: "%.2f")").bold()
                            }
                            Spacer()
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("boxesBg"))
                        .cornerRadius(10)
                        .foregroundStyle(.white)
                        
                     
                        
                        HStack{
                            Image(systemName: "t.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40)
                            VStack(alignment:.leading) {
                                Text("Total Saved")
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
                    
                    // Gráfico de Ahorros
                    VStack(alignment: .leading, spacing: 10) {
                        Text("By Months")
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
                                            .font(.caption).foregroundStyle(.white)
                                            
                                    }
                                    .annotation(position: .bottom, alignment: .center, spacing: 5) {
                                        Text(abbreviatedMonth(from: data.month))
                                            .font(.caption).foregroundStyle(.white)
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
                    
                    HStack{
                        Text("Goals").foregroundStyle(.white)
                        Spacer()
                        Button(action: {
                            print("MMG")
                        }){
                            Image(systemName: "arrow.forward.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(Color("buttonPrimary"))
                                .frame(width: 25, height: 25)
                        }
                    }
                    DeckCompletionView()
                    
                    
                    if !savingsToday.isEmpty {
                        // TODAY
                        Text("Today").foregroundStyle(.white)
                        ForEach(savingsToday) { datum in
                            savingTransactionCellView(saving: datum)
                        }
                    }
                    
                    if !savingsThisMonth.isEmpty {
                        // This Month
                        Text("This Month").foregroundStyle(.white)
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
        dateFormatter.dateFormat = "MMMM" // Mes completo
        let date = dateFormatter.date(from: month)
        
        dateFormatter.dateFormat = "MMM" // Abreviatura del mes
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
            
            Text("Buy a car")
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
                progress = targetProgress // Update progress on owned cards change
            }
        }
    }
}






#Preview {
    ContentView()
}


