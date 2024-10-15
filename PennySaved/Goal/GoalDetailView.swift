//
//  GoalDetailView.swift
//  PennySaved
//
//  Created by Victor Saint Hilaire on 10/14/24.
//


import SwiftUI

struct GoalDetailView: View {
    let goal: Goals
    @EnvironmentObject var goalsVm: GoalsVm
    @EnvironmentObject var savingsVm: SavingsVm
    @State private var showEditView = false
    @State private var showSavingsList = false
    @State private var showDeleteAlert = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    Text(goal.name ?? "NA")
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                    Text(goal.targetAmount.formatted(.currency(code: "USD")))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("buttonPrimary"))
                }
                .padding()
                .background(Color("boxesBg"))
                .cornerRadius(16)

                // Progress
                VStack(alignment: .leading, spacing: 10) {
                    Text("Progress")
                        .font(.headline)
                    ProgressView(value: goalsVm.totalSavings(for: goal), total: goal.targetAmount)
                        .accentColor(Color("buttonPrimary"))
                    HStack {
                        Text("Current: \(goalsVm.totalSavings(for: goal).formatted(.currency(code: "USD")))")
                        Spacer()
                        Text("Target: \(goal.targetAmount.formatted(.currency(code: "USD")))")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                .padding()
                .background(Color("boxesBg"))
                .cornerRadius(16)

                // Date and Status
                HStack {
                    VStack(alignment: .leading) {
                        Text("Date Started")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(goal.date ?? Date(), style: .date)
                            .font(.headline)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Status")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(goal.completed ? "Completed" : "In Progress")
                            .font(.headline)
                            .foregroundColor(goal.completed ? .green : Color("buttonPrimary"))
                    }
                }
                .padding()
                .background(Color("boxesBg"))
                .cornerRadius(16)

                // Note
                if ((goal.note?.isEmpty) == nil) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Note")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(goal.note ?? "NA")
                            .font(.body)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color("boxesBg"))
                    .cornerRadius(16)
                }

                // View Savings Button
                Button(action: {
                    showSavingsList = true
                }) {
                    Text("View ThinkTwiceSave for this Goal")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("buttonPrimary"))
                        .cornerRadius(16)
                }

                // Edit Button
                Button(action: {
                    showEditView = true
                }) {
                    Text("Edit Goal")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("buttonPrimary"))
                        .cornerRadius(16)
                }

                // Delete Button
                Button(action: {
                    showDeleteAlert = true
                }) {
                    Text("Delete Goal")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(16)
                }
            }
            .padding()
        }
        .background(Color("bg"))
        .navigationTitle("Goal Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showEditView) {
            NewGoalView(isForEdit: true, goalForEdit: goal)
        }
        .sheet(isPresented: $showSavingsList) {
            savigsListView(goal: goal, saving: savingsVm.savings.filter { $0.goal == goal })
                .presentationDetents([.medium, .large])
        }
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text("Delete Goal"),
                message: Text("Are you sure you want to delete this goal? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    deleteGoal(goal: goal)
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private func deleteGoal(goal: Goals) {
        let context = PersistenceController.shared.container.viewContext

        context.delete(goal) // Delete the Saving from the context
        
        // Save the context to persist the deletion
        do {
            try PersistenceController.shared.save()
            goalsVm.fetchGols() // PARA ACUTALIZAR EL ARRAY CON LOS SAVINGS
            self.presentationMode.wrappedValue.dismiss()
            print("Goal deleted successfully.")
        } catch {
            print("Failed to delete goal: \(error.localizedDescription)")
        }
    }

    
}

// Preview
//struct GoalDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        let context = PersistenceController.preview.container.viewContext
//        let sampleGoal = Goals(context: context)
//        sampleGoal.id = UUID()
//        sampleGoal.name = "Sample Goal"
//        sampleGoal.targetAmount = 1000.0
//        sampleGoal.date = Date()
//        sampleGoal.note = "This is a sample note for the goal."
//        sampleGoal.completed = false
//        
//        return NavigationView {
//            GoalDetailView(goal: sampleGoal)
//        }
//        .environmentObject(GoalsVm())
//        .environmentObject(SavingsVm())
//    }
//}
