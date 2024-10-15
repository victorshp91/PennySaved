//
//  NewGoalView.swift
//  PennySaved
//
//  Created by Victor Saint Hilaire on 8/16/24.
//

import SwiftUI

struct NewGoalView: View {
    @State var showDeleteAlert = false
    @EnvironmentObject var goalsVm: GoalsVm  // Access the GoalsVm instance
    @EnvironmentObject var savingsVm: SavingsVm  // Access the GoalsVm instance
    @Environment(\.presentationMode) var presentationMode
    // EDIT
    @State  var isForEdit = false
    @State  var goalForEdit: Goals?
    
    @State var showThinkTwiceSave = false
    @State private var name = ""
    @State private var note = ""
    @State private var targetAmount = "0"
    @State private var currentAmount = 0.0
    @State private var date = Date()
    @State private var completed = false
 

    var body: some View {
        let validationResult = validateForm()
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                
                // NOMBRE DEL ARTÍCULO
                Text("ThinkTwiceSave Goal Name")
                    .foregroundStyle(.white)
                
                HStack {
                 
                    TextField("Goal Name", text: $name)
                        .padding()
                       
               
                } .frame(maxWidth: .infinity, maxHeight: 100)
                    .background(Color("boxesBg"))
                    .cornerRadius(16)
                    .tint(Color("buttonPrimary"))
                    .foregroundStyle(.white)
                
                // PICKER PARA LA FECHA
                VStack(alignment: .leading, spacing: 10) {
                    DatePicker("Date Started", selection: $date, in: ...Date(), displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .preferredColorScheme(.dark)
                        .tint(.black)
                        .foregroundStyle(.white)
                }
                .padding()
                .background(Color("boxesBg"))
                .cornerRadius(16)
                // CURRENT AMOUNT SI ES PARA EDIT
                if isForEdit {
                    if let goal = goalForEdit {
                        HStack{
                            VStack(alignment:.leading, spacing: 10){
                                HStack{
                                    Text("Current Amount ThinkTwiceSave")
                                    Spacer()
                                    Text("$\(goalsVm.totalSavings(for: goal), specifier: "%.2f")").bold()
                                }
                                if isForEdit {
                                    Button(action: {
                                        showThinkTwiceSave = true
                                    }){
                                        Text("See ThinkTwiceSave on this Goal")
                                            .foregroundStyle(Color("buttonPrimary"))
                                    }.sheet(isPresented: $showThinkTwiceSave) {
                                        savigsListView(goal:goalForEdit, saving: savingsVm.savings.filter { $0.goal == goalForEdit })
                                            .presentationDetents([.medium,.large])
                                        
                                    }
                                    VStack(alignment: .leading){
                                        let remainingAmount = goal.targetAmount - goalsVm.totalSavings(for: goal)
                                        if remainingAmount > 0 && !completed {
                                            HStack{
                                                Text("Remaining")
                                                
                                                Text("$\(remainingAmount, specifier: "%.2f")").bold()
                                            }
                                            Text("Keep going, you're making progress!")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        } else {
                                            
                                            Text("🎉 Goal achieved! Great job!")
                                                .font(.subheadline)
                                                .foregroundColor(.green)
                                            
                                            
                                        }
                                    }
                                    
                                    if isForEdit && goal.targetAmount < Double(targetAmount) ?? 0.0{
                                        VStack(alignment: .leading, spacing: 10) {
                                            Toggle(isOn: $completed) {
                                                HStack {
                                                    Image(systemName: completed ? "checkmark.circle.fill" : "circle")
                                                        .foregroundColor(completed ? .green : .gray)
                                                    Text(completed ? "Completed" : "Mark as Completed")
                                                        .font(.headline)
                                                }
                                            }
                                            .toggleStyle(SwitchToggleStyle(tint: Color("buttonPrimary")))
                                            .onChange(of: goalsVm.totalSavings(for: goal)) { 
                                                if goalsVm.totalSavings(for: goal) >= goal.targetAmount {
                                                    completed = true
                                                }
                                            }
                                        }
                                        .padding()
                                        .background(Color(.systemBackground))
                                        .cornerRadius(16)
                                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                    }
                                }
                            }
                        }.padding()
                            .frame(maxWidth: .infinity)
                            .background(Color("boxesBg"))
                            .cornerRadius(16)
                    }
                }
                
                
                
                // MONTO
                Text("Target Amount")
                    .foregroundStyle(.white)
                
               
        
                
           
                CalculatorView(displayText: $targetAmount)
                
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
                
                // Mostrar el mensaje de error
                if let errorMessage = validationResult.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                // BOTÓN "GUARDAR"
                Button(action: {
                    
                    if validationResult.isValid {
                        if isForEdit {
                            updateGoal()
                        } else {
                            saveGoal()
                        }
                    }
                }) {
                    Text("Save Goal")
                        .font(.headline)
                        .foregroundColor(validateForm().isValid ? .black : Color.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(validateForm().isValid ? Color("buttonPrimary") : Color.gray)
                        .cornerRadius(16)
                }
                .disabled(!validateForm().isValid)
               
                
            } .navigationTitle(isForEdit ? "Edit Goal":"New Goal")
                .navigationBarTitleDisplayMode(.inline)
                .padding(15)
                .onAppear(perform: {
                
                    if isForEdit {
                        name = goalForEdit?.name ?? ""
                        note = goalForEdit?.note ?? ""
                        date = goalForEdit?.date ?? Date()
                        targetAmount = String(goalForEdit?.targetAmount ?? 0)
                        if let goal = goalForEdit {
                            currentAmount = goalsVm.totalSavings(for: goal)
                            completed = currentAmount >= goal.targetAmount || goal.completed
                        }
                    }
                })

            
        }.scrollDismissesKeyboard(.immediately)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("bg"))
            
    }

    
    // GUARDAR EN COREDATA
    private func saveGoal() {
        // Convertir la cantidad a un tipo Double
        guard let targetAmount = Double(targetAmount) else {
            print("Invalid amount")
            return
        }
        
        // Crear una nueva instancia de Saving
        let newGoal = Goals(context: PersistenceController.shared.container.viewContext)
        newGoal.id = UUID()
        newGoal.targetAmount = targetAmount
      
        newGoal.date = Date()
        newGoal.note = note
        newGoal.currentAmount = 0
        newGoal.name = name
        
       
    
        
        // Guardar en Core Data
        do {
            try PersistenceController.shared.save()
            print("Saving saved: \(targetAmount) on \(date)")
            goalsVm.fetchGols()
            self.presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving the saving: \(error.localizedDescription)")
        }
    }
    
    private func updateGoal() {
        if let goal = goalForEdit {
            
            // Convertir la cantidad a un tipo Double
            guard let targetAmount = Double(targetAmount) else {
                print("Invalid amount")
                return
            }
            
            
            
            
          
            goal.date = Date()
            goal.note = note
            goal.currentAmount = 0
            goal.name = name
            goal.completed = completed
            if (targetAmount > goalsVm.totalSavings(for: goal) && !goal.completed ) || goal.targetAmount < targetAmount {
            goal.completed = false
            }
            goal.targetAmount = targetAmount
            
            
            
            do {
                try PersistenceController.shared.save()
                goalsVm.fetchGols()
                self.presentationMode.wrappedValue.dismiss()
            }catch {
                print("Error saving the saving: \(error.localizedDescription)")
            }
        }
    }
    
 

    private func validateForm() -> ValidationResult {
        guard let targetAmountDouble = Double(targetAmount), !targetAmount.isEmpty else {
            return ValidationResult(isValid: false, errorMessage: "Please enter a valid target amount.")
        }
        
        if targetAmountDouble == 0 {
            return ValidationResult(isValid: false, errorMessage: "Target amount must be greater than zero.")
        }
        
        if name.isEmpty {
            return ValidationResult(isValid: false, errorMessage: "Please enter a name for the goal.")
        }
        
        if isForEdit, let goal = goalForEdit {
            let totalSavings = goalsVm.totalSavings(for: goal)
            if targetAmountDouble < totalSavings {
                return ValidationResult(isValid: false, errorMessage: "Target amount cannot be less than the current savings (\(String(format: "%.2f", totalSavings))).")
            }
        }
        
        return ValidationResult(isValid: true, errorMessage: nil)
    }
}



#Preview {
    NewGoalView().preferredColorScheme(.dark)
}
