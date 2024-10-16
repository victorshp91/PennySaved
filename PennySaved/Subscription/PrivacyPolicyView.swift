//
//  PrivacyPolicyView.swift
//  PennySaved
//
//  Created by Victor Saint Hilaire on 10/13/24.
//

import SwiftUI

struct PrivacyPolicyView: View {
    @State private var policyData: PolicyData?
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    let accentColor = Color(hex: "C9F573")
    let backgroundColor = Color(hex: "0B1523")
    let secondaryColor = Color(hex: "212B33")
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(policyData?.title ?? "Privacy Policy")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(accentColor)
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: accentColor))
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let sections = policyData?.sections {
                    ForEach(sections, id: \.title) { section in
                        policySection(title: section.title, content: section.content)
                    }
                }
            }
            .padding()
        }
        .background(backgroundColor.edgesIgnoringSafeArea(.all))
        .navigationBarTitle("Privacy Policy", displayMode: .inline)
        .onAppear {
            loadPolicyData()
        }
    }
    
    private func policySection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(accentColor)
            
            Text(content)
                .foregroundColor(.white)
        }
        .padding()
        .background(secondaryColor)
        .cornerRadius(10)
    }
    
    private func loadPolicyData() {
        guard let url = URL(string: "https://rayjewelry.us/thinktwice/privacy.json") else {
            self.errorMessage = "Invalid URL"
            self.isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = "Error: \(error.localizedDescription)"
                } else if let data = data {
                    let decoder = JSONDecoder()
                    if let decodedData = try? decoder.decode(PolicyData.self, from: data) {
                        self.policyData = decodedData
                    } else {
                        self.errorMessage = "Error decoding data"
                    }
                } else {
                    self.errorMessage = "Unknown error"
                }
            }
        }.resume()
    }
}

struct PolicyData: Codable {
    let title: String
    let sections: [PolicySection]
}

struct PolicySection: Codable {
    let title: String
    let content: String
}

struct PrivacyPolicyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyPolicyView()
    }
}
