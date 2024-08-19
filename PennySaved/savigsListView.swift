//
//  savigsListView.swift
//  PennySaved
//
//  Created by Victor Saint Hilaire on 8/13/24.
//

import SwiftUI

enum SortOption: String, CaseIterable, Identifiable {
    case amountAsc = "Amount ↑"
    case amountDesc = "Amount ↓"
    case nameAsc = "Name A-Z"
    case nameDesc = "Name Z-A"
    case dateAsc = "Date ↑"
    case dateDesc = "Date ↓"
    
    var id: String { self.rawValue }
}

struct savigsListView: View {
    
    @FetchRequest(
            entity: Category.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)]
        ) var categories: FetchedResults<Category>
    var goal: Goals? // SI ES PARA VER  LA LISTA PARA UN GOAL
    @State private var selectedCategory: Category? // Category selection
    var saving: [Saving]
    @State private var selectedMonth: Int = 0
    let months = ["All Months",
            "January", "February", "March", "April", "May", "June",
            "July", "August", "September", "October", "November", "December"
        ]
    
    // Function to sort savings based on selected option
        private func sortedSavings() -> [Saving] {
            
            var sortedSavings = saving
            
            switch selectedSortOption {
            case .amountAsc:
                sortedSavings.sort { $0.amount < $1.amount }
            case .amountDesc:
                sortedSavings.sort { $0.amount > $1.amount }
            case .nameAsc:
                sortedSavings.sort { $0.name ?? "" < $1.name ?? "" }
            case .nameDesc:
                sortedSavings.sort { $0.name ?? "" > $1.name ?? "" }
            case .dateAsc:
                sortedSavings.sort { $0.date ?? Date() < $1.date  ??  Date()}
            case .dateDesc:
                sortedSavings.sort { $0.date ?? Date() > $1.date ??  Date()}
            }
            
            // Filter by the selected month, 0 means all months
                    if selectedMonth > 0 {
                        sortedSavings = sortedSavings.filter {
                            Calendar.current.component(.month, from: $0.date ?? Date()) == selectedMonth
                        }
                    }
            
            // Filter by selected category
                   if let category = selectedCategory {
                       sortedSavings = sortedSavings.filter { $0.category == category }
                   }
            
             sortedSavings = sortedSavings.filter { saving in
                searchText.isEmpty || saving.name?.localizedCaseInsensitiveContains(searchText) == true
            }
                    
                    return sortedSavings
        }
    
    
    
    @State private var selectedSortOption: SortOption = .dateDesc
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    
                    SearchBarView(searchingText: $searchText, searchBoxDefaultText: "Saving Name")
                        .padding(.horizontal,15)
                       
                    ScrollView(.horizontal, showsIndicators: false ) {
                        
                        
                        HStack {
                           
                            Picker("Sort by", selection: $selectedSortOption) {
                                ForEach(0..<SortOption.allCases.count, id: \.self) { index in
                                    let option = SortOption.allCases[index]
                                    Text(option.rawValue).tag(option)
                                    
                                    // Add a divider every two options
                                    if index % 2 == 1 && index < SortOption.allCases.count - 1 {
                                        Divider()
                                    }
                                }
                            }
                            .pickerStyle(.menu)
                            
                            .padding(5)
                            .background(Color("boxesBg"))
                            .cornerRadius(16)
                            
                            // Picker for Selecting Month
                            Picker("Select Month", selection: $selectedMonth) {
                                ForEach(0..<months.count, id: \.self) { index in
                                    Text(months[index]).tag(index)
                                    
                                }
                            }
                            
                            .pickerStyle(.menu)
                            .padding(5)
                            .background(Color("boxesBg"))
                            .cornerRadius(16)
                            
                            // Picker for Selecting Category
                            Picker("Select Category", selection: $selectedCategory) {
                                Text("All Categories").tag(Category?.none) // Optional, to show all categories
                                ForEach(categories) { category in
                                    HStack(spacing: 10) {
                                        Image(systemName: "\(category.icon ?? "questionmark")")
                                        Text(category.name ?? "Unknown").tag(category as Category?)
                                    }.tag(category as Category?)
                                }
                            }
                            
                            .pickerStyle(.menu)
                            .padding(5)
                            .background(Color("boxesBg"))
                            .cornerRadius(16)
                            
                            
                            
                        } .padding(.horizontal,15)
                    }
                    
                    
                    
                    
                    if sortedSavings().isEmpty {
                        ContentUnavailableView("No saving found matching your search", systemImage: "magnifyingglass.circle.fill")
                    } else {
                        if goal != nil {
                            Text("Almost Savings for Goal \(goal?.name ?? "NO DATA")")
                        }
                        ForEach(sortedSavings()) { datum in
                            savingTransactionCellView(saving: datum)
                                .padding(.horizontal, 15)
                               
                            
                        }
                    }
                    
                }.navigationTitle("Savings")
                    .navigationBarTitleDisplayMode(.inline)
                    .padding(.top)
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("bg"))
        }
    }
}

#Preview {
    savigsListView(saving: []).preferredColorScheme(.dark)
}
