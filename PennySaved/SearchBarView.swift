//
//  SearchBarView.swift
//  PennySaved
//
//  Created by Victor Saint Hilaire on 8/16/24.
//

import SwiftUI

struct SearchBarView: View {
    
    @Binding var searchingText: String
    var searchBoxDefaultText : String

    var body: some View {
        
        TextField(searchBoxDefaultText, text: $searchingText)
            .disableAutocorrection(true)
            .padding(EdgeInsets(top: 10, leading: 40, bottom: 10, trailing: 20))
           
            .background(Color(.secondarySystemFill))
               
            .cornerRadius(16)
            .accentColor(.black)
            .overlay(
                HStack {
                    
                    Image(systemName: "magnifyingglass.circle.fill")
                    
                        .foregroundColor(.gray)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 10)
                        .font(.title2)
                    
                    
                    Spacer()
                    if !searchingText.isEmpty {
                        Button(action: {
                            searchingText = ""
                        }, label: {
                            Image(systemName: "x.circle.fill")
                                .foregroundColor(.gray)
                                .frame(minWidth: 0, alignment: .trailing)
                                .padding(.trailing, 10)
                                .font(.title2)
                        })
                    }
                }
            )
        
    }
}

struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        SearchBarView(searchingText: .constant(""), searchBoxDefaultText: "")
    }
}

