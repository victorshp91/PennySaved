//
//  GoalsListView.swift
//  PennySaved
//
//  Created by Victor Saint Hilaire on 8/16/24.
//

import SwiftUI

struct GoalsListView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var goalsVm: GoalsVm  // Access the GoalsVm instance
    @State var isForSelect: Bool
    @Binding var selectedGoal: Goals?
    @State var firstGoal: Goals?
    @State var donePressed = false
    
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    
                    if goalsVm.goals.isEmpty {
                        ContentUnavailableView("No Goal found matching your search", systemImage: "magnifyingglass.circle.fill")
                    } else {
                        
                        ForEach(goalsVm.goals) { goal in
                            HStack{
                                if isForSelect && goalsVm.totalSavings(for: goal) < goal.targetAmount {
                                    Button(action: {
                                        if selectedGoal == goal {
                                            selectedGoal = nil  // Deseleccionar si ya está seleccionado
                                        } else {
                                            selectedGoal = goal  // Seleccionar si no está seleccionado
                                        }
                                    }) {
                                        Image(systemName: selectedGoal == goal ? "checkmark.circle.fill" : "circle")
                                            .foregroundStyle(selectedGoal == goal ? Color.green : Color.white)
                                            .font(.title)
                                    }
                                }

                                
                                
                                
                                GoalCellView(goal: goal)
                                   
                            } .padding(.horizontal, 15)
                            
                        }
                    }
                }.navigationTitle("Goals")
                    .navigationBarTitleDisplayMode(.inline)
                    .padding(.top)
                    .onAppear(perform: {
                       if isForSelect {
                            firstGoal = selectedGoal
                        }
                    })
                    .onDisappear(perform: {
                        if !donePressed {
                            selectedGoal = firstGoal
                        }
                    })
                
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("bg"))
                .toolbar {
                    if isForSelect {
                        ToolbarItem(placement:.topBarTrailing) {
                            Button(action: {
                                donePressed = true
                                self.presentationMode.wrappedValue.dismiss()
                            }) {
                                Text("Done")
                                    .foregroundStyle(Color("buttonPrimary"))
                            }
                        }
                        ToolbarItem(placement:.topBarLeading) {
                            Button(action: {
                                selectedGoal = firstGoal
                                self.presentationMode.wrappedValue.dismiss()
                            }) {
                                Text("Cancel")
                                    .foregroundStyle(Color.red)
                            }
                        }
                    }
                }
        }
    }
}

#Preview {
    GoalsListView(isForSelect: false, selectedGoal: Binding.constant(Goals())).preferredColorScheme(.dark)
}
