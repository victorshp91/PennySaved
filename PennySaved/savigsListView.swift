//
//  savigsListView.swift
//  PennySaved
//
//  Created by Victor Saint Hilaire on 8/13/24.
//

import SwiftUI

struct savigsListView: View {
    var saving: [Saving]
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                
                ForEach(saving) { datum in
                    savingTransactionCellView(saving: datum)
                }
                
            }.navigationTitle("Savings")
                .navigationBarTitleDisplayMode(.inline)
                .padding(15)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("bg"))
    }
}

#Preview {
    savigsListView(saving: [])
}
