//
//  NewGoalView.swift
//  PennySaved
//
//  Created by Victor Saint Hilaire on 8/16/24.
//

import SwiftUI

struct NewGoalView: View {
    @EnvironmentObject var goalsVm: GoalsVm  // Access the GoalsVm instance

    @Environment(\.presentationMode) var presentationMode
    // EDIT
    @State  var isForEdit = false
    @State  var goalForEdit: Goals?
    
   
    @State private var name = ""
    @State private var note = ""
    @State private var targetAmount = "0"
    @State private var currentAmount = 0.0
    @State private var date = Date()
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                
                // NOMBRE DEL ARTÍCULO
                Text("Goal Name")
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
                if let goal = goalForEdit {
                    HStack{
                        Text("Current Amount")
                        Spacer()
                        Text("\(currentAmount, specifier: "%.2f")")
                    }.padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("boxesBg"))
                        .cornerRadius(16)
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
                
                // BOTÓN "GUARDAR"
                Button(action: {
                    if isForEdit {
                        saveGoal()
                    }else {
                        // Acción para guardar el ahorro
                        saveGoal()
                    }
                }) {
                    Text("Save Goal")
                        .font(.headline)
                        .foregroundColor(isFormValid() ? .black : Color.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isFormValid() ? Color("buttonPrimary") : Color.gray)
                        .cornerRadius(16)
                }
                .disabled(!isFormValid())
                
            } .navigationTitle("New Saving")
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
                        }
                    }
                })

            
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
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
            self.presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving the saving: \(error.localizedDescription)")
        }
    }
    
    // VALIDACIÓN DEL FORMULARIO
    private func isFormValid() -> Bool {
        if let _ = Double(targetAmount), !targetAmount.isEmpty && !name.isEmpty && Double(targetAmount) != 0 &&  Double(targetAmount) ?? 0.0 >= currentAmount{
            return true
        }
        return false
    }
}

#Preview {
    NewGoalView().preferredColorScheme(.dark)
}
