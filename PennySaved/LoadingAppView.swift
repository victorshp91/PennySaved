//
//  LoadingApp.swift
//  PennySaved
//
//  Created by Victor Saint Hilaire on 8/24/24.
//

import SwiftUI

struct LoadingAppView: View {
    var body: some View {
        VStack {
            ProgressView("Loading...")
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)  // Adjust the size of the loading spinner
                .padding()

            Text("Fetching your data, please wait...")
                .foregroundColor(.white)
                .font(.headline)
                .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}
