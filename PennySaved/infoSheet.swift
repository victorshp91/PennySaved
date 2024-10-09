//
//  infoSheet.swift
//  PennySaved
//
//  Created by Victor Saint Hilaire on 10/8/24.
//

import SwiftUI

struct InfoSheetView: View {
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 10) {
                    // App Information Section
                    VStack(alignment: .leading, spacing: 20) {
                        Group {
                            HStack {
                                Image(systemName: "info.circle")
                                Text("App Information")
                            }
                            .font(.title3.bold())
                            Text("PennySaved is your innovative financial companion, designed to help you track expenses you almost made but avoided. By recording these 'almost-spent' amounts, you can redirect them towards your savings goals, turning potential expenses into actual savings.")
                        }

                        // Features Section
                        Group {
                            HStack {
                                Image(systemName: "star")
                                Text("Features")
                            }
                            .font(.title3.bold())
                            Text("• Track avoided expenses\n• Set and visualize savings goals\n• Redirect 'almost-spent' money to goals\n• Customizable expense categories\n• Insightful reports on savings progress")
                        }
                    }
                    .padding()
                    
                    // Privacy Section
                    VStack(alignment: .leading, spacing: 20) {
                        Group {
                            HStack {
                                Image(systemName: "lock.shield")
                                Text("Privacy")
                            }
                            .font(.title3.bold())
                            Text("Your financial data is securely stored on your device. We prioritize your privacy and do not share any personal information with third parties.")
                        }
                    }
                    .padding()
                    
                    Spacer()
                }
                .foregroundColor(.primary)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("PennySaved")
            .background(Color("bg"))
        }
    }
}

#Preview {
    InfoSheetView()
        .preferredColorScheme(.dark)
}
