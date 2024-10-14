//
//  savingTransactionCellView.swift
//  PennySaved
//
//  Created by Victor Saint Hilaire on 8/12/24.
//

import SwiftUI

struct savingTransactionCellView: View {
    @EnvironmentObject var storeKit: StoreKitManager
    @StateObject var saving: Saving
    
    var body: some View {
        HStack {
            Image(systemName: "\(saving.category?.icon ?? "questionmark")")
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)
                .padding()
                .background(.white)
                .foregroundStyle(.black)
                .clipShape(Circle())
          
            VStack(alignment: .leading) {
                Text(saving.name ?? "Not Name").bold()
                Text("Saved on \(saving.date ?? Date(), style: .date)").foregroundStyle(.secondary)
                NavigationLink(destination: NewSavingView(isForEdit: true, savingForEdit: saving).environmentObject(storeKit)) {
                    Text("Details")
                        .foregroundStyle(Color("buttonPrimary"))
                }
            }
            .font(.subheadline)
            
            Spacer()
            
            Text("$\(saving.amount, specifier: "%.2f")").bold().font(.title3)
        }
        .padding(15)
        .frame(maxWidth: .infinity)
        .background(Color("boxesBg"))
        .cornerRadius(35)
        .foregroundStyle(.white)
    }
}

//#Preview {
//    savingTransactionCellView(iconName: "handbag.fill", title: <#String#>, date: <#String#>, amount: <#String#>)
//}
