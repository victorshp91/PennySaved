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
    @State private var note = ""
    @State private var category: Category?
    @State private var showCategory = false
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
        newSaving.note = note
        newSaving.category = category
        
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
        if let _ = Double(amount), !amount.isEmpty && !name.isEmpty && Double(amount) != 0  && category != nil{
            return true
        }
        return false
    }
}

#Preview {
    NewSavingView()
}
