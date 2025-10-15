//
//  TipsView.swift
//  HabitLab
//
//  Created by Вадим Дзюба on 13.10.2025.
//

import SwiftUI

struct TipsView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    let tips = [
        Tip(icon: "star.fill", title: "Start Small", description: "Begin with easy habits and gradually increase difficulty", color: .yellow),
        Tip(icon: "clock.fill", title: "Be Consistent", description: "Practice your habit at the same time every day", color: .blue),
        Tip(icon: "target", title: "Set Clear Goals", description: "Define specific and measurable objectives", color: .green),
        Tip(icon: "chart.line.uptrend.xyaxis", title: "Track Progress", description: "Monitor your achievements to stay motivated", color: .purple),
        Tip(icon: "heart.fill", title: "Reward Yourself", description: "Celebrate your successes, no matter how small", color: .pink),
        Tip(icon: "person.2.fill", title: "Find Accountability", description: "Share your goals with friends or family", color: .orange),
        Tip(icon: "exclamationmark.triangle.fill", title: "Avoid Triggers", description: "Identify and minimize situations that lead to bad habits", color: .red),
        Tip(icon: "lightbulb.fill", title: "Stay Positive", description: "Focus on progress, not perfection", color: .cyan)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                if horizontalSizeClass == .regular {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 350))], spacing: 20) {
                        ForEach(tips) { tip in
                            TipCard(tip: tip)
                        }
                    }
                    .padding(20)
                } else {
                    LazyVStack(spacing: 15) {
                        ForEach(tips) { tip in
                            TipCard(tip: tip)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Tips")
        }
    }
}

struct Tip: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let color: Color
}

struct TipCard: View {
    let tip: Tip
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var iconSize: CGFloat {
        horizontalSizeClass == .regular ? 60 : 50
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: horizontalSizeClass == .regular ? 20 : 15) {
            Image(systemName: tip.icon)
                .font(.system(size: horizontalSizeClass == .regular ? 26 : 22))
                .foregroundColor(.white)
                .frame(width: iconSize, height: iconSize)
                .background(tip.color)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: horizontalSizeClass == .regular ? 8 : 5) {
                Text(tip.title)
                    .font(horizontalSizeClass == .regular ? .title3 : .headline)
                
                Text(tip.description)
                    .font(horizontalSizeClass == .regular ? .body : .subheadline)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(horizontalSizeClass == .regular ? 20 : 15)
        .background(Color(.systemGray6))
        .cornerRadius(horizontalSizeClass == .regular ? 20 : 15)
    }
}

#Preview {
    TipsView()
}

