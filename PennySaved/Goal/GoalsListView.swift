import SwiftUI

enum GoalSortOption: String, CaseIterable, Identifiable {
    case targetAsc = "Target ↑"
    case targetDesc = "Target ↓"
    case nameAsc = "Name A-Z"
    case nameDesc = "Name Z-A"
    case dateAsc = "Date ↑"
    case dateDesc = "Date ↓"
    case remainingAsc = "Remaining ↑"
    case remainingDesc = "Remaining ↓"
    case completedFirst = "Completed First"
    case incompleteFirst = "Incomplete First"

    var id: String { self.rawValue }
}

enum GoalCompletionFilter: String, CaseIterable, Identifiable {
    case all = "All Goals"
    case completed = "Completed"
    case incomplete = "Incomplete"
    
    var id: String { self.rawValue }
}

struct GoalsListView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var storeKit: StoreKitManager
    @EnvironmentObject var goalsVm: GoalsVm
    @State var isForSelect: Bool
    @Binding var selectedGoal: Goals?
    @State var firstGoal: Goals?
    @State var donePressed = false
    @State var saving: Saving?

    @State private var selectedSortOption: GoalSortOption = .dateDesc
    @State private var searchText = ""
    @State private var completionFilter: GoalCompletionFilter = .all
    @State private var showingNewGoalView = false  // Add this line
    @State private var showSubscriptionView = false

    private func sortedGoals() -> [Goals] {
        var sortedGoals = goalsVm.goals

        // Filter based on completion status
        sortedGoals = sortedGoals.filter { goal in
            switch completionFilter {
            case .all:
                return true
            case .completed:
                return goal.completed
            case .incomplete:
                return !goal.completed
            }
        }

        // Aplicar filtros solo si isForSelect es true
        if isForSelect {
            sortedGoals = sortedGoals.filter { goal in
                let isNotCompleted = !goal.completed
                let totalSavings = goalsVm.totalSavings(for: goal)
                return isNotCompleted && totalSavings < goal.targetAmount
            }
        }

        // Aplicar ordenación
        switch selectedSortOption {
        case .targetAsc:
            sortedGoals.sort { $0.targetAmount < $1.targetAmount }
        case .targetDesc:
            sortedGoals.sort { $0.targetAmount > $1.targetAmount }
        case .nameAsc:
            sortedGoals.sort { $0.name ?? "" < $1.name ?? "" }
        case .nameDesc:
            sortedGoals.sort { $0.name ?? "" > $1.name ?? "" }
        case .dateAsc:
            sortedGoals.sort { $0.date ?? Date() < $1.date ?? Date() }
        case .dateDesc:
            sortedGoals.sort { $0.date ?? Date() > $1.date ?? Date() }
        case .remainingAsc:
            sortedGoals.sort {
                (($0.targetAmount - goalsVm.totalSavings(for: $0)) < ($1.targetAmount - goalsVm.totalSavings(for: $1)))
            }
        case .remainingDesc:
            sortedGoals.sort {
                (($0.targetAmount - goalsVm.totalSavings(for: $0)) > ($1.targetAmount - goalsVm.totalSavings(for: $1)))
            }
        case .completedFirst:
            sortedGoals.sort { $0.completed && !$1.completed }
        case .incompleteFirst:
            sortedGoals.sort { !$0.completed && $1.completed }
        }

        // Aplicar filtro de búsqueda
        sortedGoals = sortedGoals.filter { goal in
            searchText.isEmpty || goal.name?.localizedCaseInsensitiveContains(searchText) == true
        }

        // Mover el selectedGoal al principio si existe
        if let selectedGoal = selectedGoal,
           let index = sortedGoals.firstIndex(of: selectedGoal) {
            sortedGoals.move(fromOffsets: IndexSet(integer: index), toOffset: 0)
        }

        return sortedGoals
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    SearchBarView(searchingText: $searchText, searchBoxDefaultText: "ThinkTwiceSave Goal Name")
                        .padding(.horizontal, 15)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            Picker("Sort by", selection: $selectedSortOption) {
                                ForEach(0..<GoalSortOption.allCases.count, id: \.self) { index in
                                    let option = GoalSortOption.allCases[index]
                                    Text(option.rawValue).tag(option)
                                    
                                    // Add a divider every two options
                                    if index % 2 == 1 && index < GoalSortOption.allCases.count - 1 {
                                        Divider()
                                    }
                                }
                            }
                            .pickerStyle(.menu)
                            .padding(5)
                            .background(Color("boxesBg"))
                            .cornerRadius(16)

                            Picker("Show", selection: $completionFilter) {
                                ForEach(GoalCompletionFilter.allCases) { filter in
                                    Text(filter.rawValue).tag(filter)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding(5)
                            .background(Color("boxesBg"))
                            .cornerRadius(16)
                        }
                        .padding(.horizontal, 15)
                    }

                    if sortedGoals().isEmpty {
                        ContentUnavailableView("No Goal found matching your search", systemImage: "magnifyingglass.circle.fill")
                    } else {
                        ForEach(sortedGoals()) { goal in
                            HStack {
                                if isForSelect && goalsVm.totalSavings(for: goal) < goal.targetAmount && goal.targetAmount >= saving?.amount ?? 0.0 {
                                    Button(action: {
                                        withAnimation {
                                            selectedGoal = goal
                                        }
                                    }) {
                                        Image(systemName: selectedGoal == goal ? "checkmark.circle.fill" : "plus.circle.fill")
                                            .foregroundStyle(selectedGoal == goal ? Color("buttonPrimary") : Color.white)
                                            .font(.title)
                                    }
                                }

                                GoalCellView(goal: goal, isForSelect: isForSelect)
                            }
                            .padding(.horizontal, 15)
                        }
                    }
                }
                .navigationTitle("Goals")
                .navigationBarTitleDisplayMode(.inline)
                .padding(.top)
                .onAppear(perform: {
                    if isForSelect {
                        firstGoal = selectedGoal
                    }
                })
                .onDisappear(perform: {
                    if !donePressed {
                        selectedGoal = firstGoal
                    }
                })
            }.scrollDismissesKeyboard(.immediately)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("bg"))
            .toolbar {
                if isForSelect {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            donePressed = true
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Done")
                                .foregroundStyle(Color("buttonPrimary"))
                        }
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            selectedGoal = firstGoal
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Cancel")
                                .foregroundStyle(Color.red)
                        }
                    }
                } else {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            goalsVm.handleNewGoalTap(
                                storeKit: storeKit,
                                showSubscriptionView: { showSubscriptionView = true },
                                showNewGoalView: { showingNewGoalView = true }
                            )
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingNewGoalView) {
                NewGoalView()
            }
            .sheet(isPresented: $showSubscriptionView) {
                SubscriptionView()
            }
        }
    }
}

#Preview {
    GoalsListView(isForSelect: false, selectedGoal: .constant(Goals()))
        .preferredColorScheme(.dark)
        .environmentObject(GoalsVm(viewContext: PersistenceController.shared.container.viewContext))
}
