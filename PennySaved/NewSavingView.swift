//
//  NewSavingView.swift
//  PennySaved
//
//  Created by Victor Saint Hilaire on 8/12/24.
//

import SwiftUI

struct NewSavingView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var goalsVm: GoalsVm  // Access the GoalsVm instance
    @EnvironmentObject var savingVm: SavingsVm  // Access the GoalsVm instance
    @State private var amount = "0"
    @State private var selectedDate: Date = Date()
    @State private var name = ""
    @State private var note = ""
    @State private var category: Category?
    @State  var selectedGoal: Goals?
    @State private var showCategory = false
    @State private var showGoals = false
    // EDIT
    @State  var isForEdit = false
    @State  var savingForEdit: Saving?
    
    
    @State private var showDeleteAlert = false
    
    var body: some View {
        
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                // NOMBRE DEL ARTÍCULO
                Text("What did you almost buy?")
                    .foregroundStyle(.white)
                
                HStack {
                 
                    TextField("Item Name", text: $name)
                        .padding()
                       
               
                } .frame(maxWidth: .infinity, maxHeight: 100)
                    .background(Color("boxesBg"))
                    .cornerRadius(16)
                    .tint(Color("buttonPrimary"))
                    .foregroundStyle(.white)
                
                // Categoria
                HStack() {
                    Image(systemName: "\(category?.icon ?? "questionmark")")
                        .padding()
                        .background(.white)
                        .foregroundStyle(.black)
                        .clipShape(Circle())
                    Text("\(category?.name ?? "Category")")
                    Spacer()
                    Button(action: {
                        showCategory = true
                    }) {
                        Text(category != nil ? "Change":"Select")
                            .font(.headline)
                            .foregroundStyle(.black)
                            .padding()
                        
                            .background(Color("buttonPrimary"))
                            .cornerRadius(16)
                    }.sheet(isPresented: $showCategory) {
                        CategoryView(category: $category)
                    }
                }
                .padding()
                .background(Color("boxesBg"))
                .cornerRadius(16)
                
                // GOAL
                VStack(alignment: .leading, spacing: 10) {
                    HStack{
                        VStack(alignment: .leading){
                            Text("Apply to a Goal").bold()
                            Text("Optional").font(.footnote).foregroundStyle(.secondary)
                            Spacer()
                            Text("\(selectedGoal?.name ?? "None")")
                        }
                        Spacer()
                        Button(action: {
                            showGoals = true
                        }) {
                            Text(selectedGoal != nil ? "Change":"Select")
                                .font(.headline)
                                .foregroundStyle(.black)
                                .padding()
                            
                                .background(Color("buttonPrimary"))
                                .cornerRadius(16)
                        }.sheet(isPresented: $showGoals) {
                            GoalsListView(isForSelect: true, selectedGoal: $selectedGoal)
                           
                        }
                        
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color("boxesBg"))
                .cornerRadius(16)
                
                // PICKER PARA LA FECHA
                VStack(alignment: .leading, spacing: 10) {
                    DatePicker("Date of Saving", selection: $selectedDate, in: ...Date(), displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .preferredColorScheme(.dark)
                        .tint(.black)
                        .foregroundStyle(.white)
                }
                .padding()
                .background(Color("boxesBg"))
                .cornerRadius(16)
                
                
                
                // MONTO
                Text("Amount Saved")
                    .foregroundStyle(.white)
           
                CalculatorView(displayText: $amount)
                
                
                //NOTE
                
                Text("Note")
                    .foregroundStyle(.white)
                TextEditor(text: $note)
                    .scrollContentBackground(.hidden) // <- Hide it
                    .background(.clear) // To see this
                    .frame(height: 100)
                    .tint(Color("buttonPrimary"))
                    .padding()
                    .background(Color("boxesBg"))
                    .cornerRadius(16)
                
               
                
                // BOTÓN "GUARDAR"
                Button(action: {
                    if isForEdit {
                        updateSaving()
                    }else {
                        // Acción para guardar el ahorro
                        saveSaving()
                    }
                }) {
                    Text("Save Saving")
                        .font(.headline)
                        .foregroundColor(isFormValid() ? .black : Color.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isFormValid() ? Color("buttonPrimary") : Color.gray)
                        .cornerRadius(16)
                }
                .disabled(!isFormValid())
               
                
            }
            .navigationTitle(isForEdit ? "Edit Saving":"New Saving")
            .navigationBarTitleDisplayMode(.inline)
            .padding(15)
            .onAppear(perform: {
            
                if isForEdit {
                    name = savingForEdit?.name ?? ""
                    note = savingForEdit?.note ?? ""
                    selectedDate = savingForEdit?.date ?? Date()
                    amount = String(savingForEdit?.amount ?? 0)
                    category = savingForEdit?.category
                    selectedGoal = savingForEdit?.goal
                }
            })
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("bg"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if isForEdit {
                    Button("Delete") {
                        showDeleteAlert = true       // Trigger the alert
                       
                        
                    }.foregroundStyle(.red)
                        .alert(isPresented: $showDeleteAlert) {
                            Alert(
                                title: Text("Delete Saving"),
                                message: Text("Are you sure you want to delete this saving?"),
                                primaryButton: .destructive(Text("Delete")) {
                                    if let saving = savingForEdit {
                                        deleteSaving(saving: saving)
                                    }
                                },
                                secondaryButton: .cancel()
                            )
                        }
                }
            }
        }
    }
    
    private func deleteSaving(saving: Saving) {
        let context = PersistenceController.shared.container.viewContext

        context.delete(saving) // Delete the Saving from the context
        
        // Save the context to persist the deletion
        do {
            try PersistenceController.shared.save()
            savingVm.fetchSavings() // PARA ACUTALIZAR EL ARRAY CON LOS SAVINGS
            self.presentationMode.wrappedValue.dismiss()
            print("Saving deleted successfully.")
        } catch {
            print("Failed to delete saving: \(error.localizedDescription)")
        }
    }

    
    // GUARDAR EN COREDATA
    private func saveSaving() {
        // Convertir la cantidad a un tipo Double
        guard let amountDouble = Double(amount) else {
            print("Invalid amount")
            return
        }
        
        // Crear una nueva instancia de Saving
        let newSaving = Saving(context: PersistenceController.shared.container.viewContext)
        newSaving.id = UUID()
        newSaving.amount = amountDouble
        newSaving.date = selectedDate
        newSaving.name = name
        newSaving.note = note
        newSaving.category = category
        if let goal = self.selectedGoal {
            newSaving.goal = goal
        }
        
        
        // Guardar en Core Data
        do {
            try PersistenceController.shared.save()
            print("Saving saved: \(amountDouble) on \(selectedDate)")
            savingVm.fetchSavings() // PARA ACUTALIZAR EL ARRAY CON LOS SAVINGS

            self.presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving the saving: \(error.localizedDescription)")
        }
    }
    
    private func updateSaving() {
        if let saving = savingForEdit {
            
            // Convertir la cantidad a un tipo Double
            guard let amountDouble = Double(amount) else {
                print("Invalid amount")
                return
            }
            
            
            
            saving.name = name
            saving.amount = amountDouble
            saving.date = selectedDate
            saving.note = note
            saving.category = category
            
            if let goal = self.selectedGoal {
                saving.goal = goal
                goalsVm.fetchGols()
            } else {
                saving.goal = nil
            }
            
            do {
                try PersistenceController.shared.save()
                savingVm.fetchSavings() // PARA ACUTALIZAR EL ARRAY CON LOS SAVINGS

                self.presentationMode.wrappedValue.dismiss()
            }catch {
                print("Error saving the saving: \(error.localizedDescription)")
            }
        }
    }
    
    // VALIDACIÓN DEL FORMULARIO
    private func isFormValid() -> Bool {
        if let _ = Double(amount), !amount.isEmpty && !name.isEmpty && Double(amount) != 0  && category != nil{
            return true
        }
        return false
    }
}

#Preview {
    NewSavingView()
}
