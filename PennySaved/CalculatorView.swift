//
//  CalculatorView.swift
//  PennySaved
//
//  Created by Victor Saint Hilaire on 8/12/24.
//

import SwiftUI

struct CalculatorView: View {
    let rows = [
        ["7", "8", "9"],
        ["4", "5", "6"],
        ["1", "2", "3"],
        ["0", ".", "Delete"]
    ]

  

    @Binding  var displayText: String

    
    var body: some View {
        
        VStack(spacing: 10) {
            HStack{
                
                Text(displayText)
                    
                    .font(.system(size: 75))
                    .fontWeight(.bold)
                
                    .frame(maxWidth: .infinity, alignment: .trailing)
                   
            }
           
               
               
                .foregroundStyle(.primary)
              
            
            ForEach(rows, id: \.self) { row in
                HStack(spacing: 20) {
                    ForEach(row, id: \.self) { item in
                        Button(action: {
                            self.buttonPressed(item)
                        }) {
                            Text(item)
                                .font(.title)
                                .frame(width: self.buttonWidth(for: item), height: 60)
                                .background(self.buttonBackgroundColor(for: item))
                                .foregroundColor(.black)
                                .cornerRadius(10)
                        }
                    }
                }
            }
        }
      
        .edgesIgnoringSafeArea(.all)
    }

    private func buttonPressed(_ item: String) {
        switch item {
        case "Delete":
            if !displayText.isEmpty {
                displayText.removeLast()
            }
            if displayText.isEmpty {
                displayText = "0"
            }
   
         
        case ".":
            if !displayText.contains(".") {
                displayText += item
            }
        default:
            if displayText == "0" {
                displayText = item
            } else {
                displayText += item
            }
        }
    }

    private func buttonWidth(for item: String) -> CGFloat {
      
        return (UIScreen.main.bounds.width - 80) / 3
    }
    
    private func buttonBackgroundColor(for item: String) -> Color {
        switch item {
        case "Done":
            return Color("buttonPrimary").opacity(1)
        default:
            return Color("buttonPrimary").opacity(0.8)
        }
    }
}



