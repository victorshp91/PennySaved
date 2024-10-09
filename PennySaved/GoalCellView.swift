//
//  GoalCellView.swift
//  PennySaved
//
//  Created by Victor Saint Hilaire on 8/16/24.
//

import SwiftUI

struct GoalCellView: View {
    @State private var progress: Double = 0.0 // Progress of deck completion
    @State var goal: Goals
    @EnvironmentObject var goalsVm: GoalsVm  // Access the GoalsVm instance
    @State var isForSelect: Bool
    
    var targetProgress: Double {
        return Double(goalsVm.totalSavings(for: goal)) / Double(goal.targetAmount)
    } // Target progress based on owned and total cards
    var body: some View {
  
        return HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 10){
                Text("\(goal.name ?? "NO DATA")")
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .bold()
                
                Text("Date Started\n\(goal.date ?? Date(), style: .date)").font(.footnote)
                    .multilineTextAlignment(.leading)
                
                // Add target amount here
                Text("Target: $\(goal.targetAmount, specifier: "%.2f")")
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                VStack(alignment: .leading){
                    if goalsVm.totalSavings(for: goal) != goal.targetAmount && goal.completed == false {
                        HStack{
                            Text("Remainig")
                            
                            Text("$\(goal.targetAmount - goalsVm.totalSavings(for: goal), specifier: "%.2f")").bold()
                        }
                        Text("Keep going, you're making progress!")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            
                    } else {
                    
                      
                            Text("🎉 Goal achieved! Great job!")
                                .font(.subheadline)
                                .foregroundColor(.green)
                       
                        
                    }
                  
                }
                   
                if !isForSelect {
                    NavigationLink(destination: NewGoalView(isForEdit: true, goalForEdit: goal)) {
                        
                        Text("Details")
                            .foregroundStyle(Color("buttonPrimary"))
                    }
                }
               
              
            }
            Spacer()
            ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 10)
                            .frame(width: 80, height: 80)
                        
                        Circle()
                    .trim(from: 0.0, to: CGFloat(min(goal.completed ? 1.0 : progress, 1.0)))
                            .stroke(Color("buttonPrimary"), lineWidth: 10)
                            .frame(width: 80, height: 80)
                            .rotationEffect(Angle(degrees: -90))
                            .padding()
                            .overlay(
                                Text(goal.completed ? "100%" : String(format: "%.0f%%", progress * 100))
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)


                            )
                            .animation(.easeInOut, value: progress)
                    }
            
            
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure the size matches StatisticView
        .background(Color("boxesBg")) // Background color
        .cornerRadius(16) // Corner radius for rounded corners
        .onAppear {
            withAnimation {
                progress = targetProgress // Animate progress on appear
            }
        }
        .onChange(of: goal.currentAmount) {
            withAnimation {
                progress = targetProgress // Update progress when target changes
            }
        }
    }
}

#Preview {
    GoalCellView(goal: Goals.init(), isForSelect: false)
}
