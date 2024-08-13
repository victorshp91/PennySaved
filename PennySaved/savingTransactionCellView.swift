//
//  savingTransactionCellView.swift
//  PennySaved
//
//  Created by Victor Saint Hilaire on 8/12/24.
//

import SwiftUI

struct savingTransactionCellView: View {

    var saving: Saving
    
    var body: some View {
        HStack {
            Image(systemName: "handbag.fill")
                .padding()
                .background(.white)
                .foregroundStyle(.black)
                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(saving.name ?? "").bold()
                Text("Saved on \(saving.date ?? Date(), style: .date)").foregroundStyle(.secondary)
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
