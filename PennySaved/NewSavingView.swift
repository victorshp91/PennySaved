//
//  NewSavingView.swift
//  PennySaved
//
//  Created by Victor Saint Hilaire on 8/12/24.
//

import SwiftUI

struct NewSavingView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var amount = "0"
    @State private var selectedDate: Date = Date()
    @State private var name = ""
    
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
                    Image(systemName: "handbag.fill")
                        .padding()
                        .background(.white)
                        .foregroundStyle(.black)
                        .clipShape(Circle())
                    Text("Food")
                    Spacer()
                    Text("Change")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .padding()
                       
                        .background(Color("buttonPrimary"))
                        .cornerRadius(16)
                }
                .padding()
                .background(Color("boxesBg"))
                .cornerRadius(16)
                
                // PICKER PARA LA FECHA
                VStack(alignment: .leading, spacing: 10) {
                    DatePicker("Date of Saving", selection: $selectedDate, displayedComponents: .date)
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
                
               
                
                // BOTÓN "GUARDAR"
                Button(action: {
                    // Acción para guardar el ahorro
                    saveSaving()
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
            .navigationTitle("New Saving")
            .navigationBarTitleDisplayMode(.inline)
            .padding(15)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("bg"))
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
        
        // Guardar en Core Data
        do {
            try PersistenceController.shared.container.viewContext.save()
            print("Saving saved: \(amountDouble) on \(selectedDate)")
            self.presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving the saving: \(error.localizedDescription)")
        }
    }
    
    // VALIDACIÓN DEL FORMULARIO
    private func isFormValid() -> Bool {
        if let _ = Double(amount), !amount.isEmpty && !name.isEmpty && Double(amount) != 0 {
            return true
        }
        return false
    }
}

#Preview {
    NewSavingView()
}
