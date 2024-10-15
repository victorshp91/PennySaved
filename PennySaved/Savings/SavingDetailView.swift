//
//  SavingDetailView.swift
//  PennySaved
//
//  Created by Victor Saint Hilaire on 10/14/24.
//


import SwiftUI

struct SavingDetailView: View {
    @StateObject var saving: Saving
    @EnvironmentObject var savingsVm: SavingsVm
    @State private var showEditView = false
    @State private var showDeleteAlert = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    Text(saving.name ?? "NA")
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                    Text(saving.amount.formatted(.currency(code: "USD")))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("buttonPrimary"))
                }
                .padding()
                .background(Color("boxesBg"))
                .cornerRadius(16)

                // Date and Category
                HStack {
                    VStack(alignment: .leading) {
                        Text("Date")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(saving.date ?? Date(), style: .date)
                            .font(.headline)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Category")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        HStack {
                            Text(saving.category?.name ?? "Uncategorized")
                                .font(.headline)
                            Image(systemName: saving.category?.icon ?? "questionmark")
                        }
                    }
                }
                .padding()
                .background(Color("boxesBg"))
                .cornerRadius(16)

                // Goal (if any)
                if let goal = saving.goal {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Applied to Goal")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(goal.name ?? "NA")
                            .font(.headline)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color("boxesBg"))
                    .cornerRadius(16)
                }

                // Note
                if ((saving.note?.isEmpty) == nil) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Note")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(saving.note ?? "NA")
                            .font(.body)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color("boxesBg"))
                    .cornerRadius(16)
                }

                // Edit Button
                Button(action: {
                    showEditView = true
                }) {
                    Text("Edit Saving")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("buttonPrimary"))
                        .cornerRadius(16)
                }
                .padding(.top)

                // Delete Button
                Button(action: {
                    showDeleteAlert = true
                }) {
                    Text("Delete Saving")
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
        .navigationTitle("Saving Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showEditView) {
            NewSavingView(isForEdit: true, savingForEdit: saving)
        }
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text("Delete Saving"),
                message: Text("Are you sure you want to delete this saving? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    deleteSaving()
                },
                secondaryButton: .cancel()
            )
        }
    }

    private func deleteSaving() {
        let context = PersistenceController.shared.container.viewContext
        context.delete(saving)
        
        do {
            try PersistenceController.shared.save()
            savingsVm.fetchSavings()
            presentationMode.wrappedValue.dismiss()
            print("Saving deleted successfully.")
        } catch {
            print("Failed to delete saving: \(error.localizedDescription)")
        }
    }
}

// Preview
//struct SavingDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        let context = PersistenceController.preview.container.viewContext
//        let sampleSaving = Saving(context: context)
//        sampleSaving.id = UUID()
//        sampleSaving.name = "Sample Saving"
//        sampleSaving.amount = 100.0
//        sampleSaving.date = Date()
//        sampleSaving.note = "This is a sample note for the saving."
//        
//        let sampleCategory = Category(context: context)
//        sampleCategory.name = "Food"
//        sampleCategory.icon = "fork.knife"
//        sampleSaving.category = sampleCategory
//        
//        return NavigationView {
//            SavingDetailView(saving: sampleSaving)
//        }
//        .environmentObject(GoalsVm())
//        .environmentObject(SavingsVm())
//    }
//}
