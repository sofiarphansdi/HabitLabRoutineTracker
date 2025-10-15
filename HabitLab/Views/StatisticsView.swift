//
//  StatisticsView.swift
//  HabitLab
//
//  Created by Вадим Дзюба on 13.10.2025.
//

import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var viewModel: HabitListViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: horizontalSizeClass == .regular ? 25 : 20) {
                    if viewModel.habits.isEmpty {
                        emptyStateView
                    } else {
                        // Overall Statistics
                        overallStatsView
                        
                        // Habits Statistics
                        if horizontalSizeClass == .regular {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))], spacing: 20) {
                                ForEach(viewModel.habits) { habit in
                                    HabitStatCard(habit: habit)
                                }
                            }
                        } else {
                            ForEach(viewModel.habits) { habit in
                                HabitStatCard(habit: habit)
                            }
                        }
                    }
                }
                .padding(horizontalSizeClass == .regular ? 25 : 15)
            }
            .navigationTitle("Statistics")
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No statistics yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Add habits to see your progress")
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
    }
    
    private var overallStatsView: some View {
        VStack(spacing: 15) {
            Text("Overall Progress")
                .font(horizontalSizeClass == .regular ? .title2 : .headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if horizontalSizeClass == .regular {
                HStack(spacing: 20) {
                    StatBox(title: "Total Habits", value: "\(viewModel.habits.count)", color: .blue)
                    StatBox(title: "Good Habits", value: "\(viewModel.habits.filter { $0.isGood }.count)", color: .green)
                    StatBox(title: "Bad Habits", value: "\(viewModel.habits.filter { !$0.isGood }.count)", color: .red)
                }
            } else {
                HStack(spacing: 15) {
                    StatBox(title: "Total Habits", value: "\(viewModel.habits.count)", color: .blue)
                    StatBox(title: "Good Habits", value: "\(viewModel.habits.filter { $0.isGood }.count)", color: .green)
                    StatBox(title: "Bad Habits", value: "\(viewModel.habits.filter { !$0.isGood }.count)", color: .red)
                }
            }
        }
        .padding(horizontalSizeClass == .regular ? 20 : 15)
        .background(Color(.systemGray6))
        .cornerRadius(horizontalSizeClass == .regular ? 20 : 15)
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let color: Color
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var boxHeight: CGFloat {
        horizontalSizeClass == .regular ? 120 : 100
    }
    
    var body: some View {
        VStack(spacing: horizontalSizeClass == .regular ? 10 : 8) {
            Text(value)
                .font(horizontalSizeClass == .regular ? .largeTitle : .title)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(horizontalSizeClass == .regular ? .subheadline : .caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: boxHeight, maxHeight: boxHeight)
        .padding(horizontalSizeClass == .regular ? 20 : 15)
        .background(Color(.systemBackground))
        .cornerRadius(horizontalSizeClass == .regular ? 15 : 10)
    }
}

struct HabitStatCard: View {
    let habit: Habit
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var completionRate: Double {
        let last30Days = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let recentRecords = habit.records.filter { $0.date >= last30Days }
        let completedCount = recentRecords.filter { $0.isCompleted }.count
        return recentRecords.isEmpty ? 0 : Double(completedCount) / Double(recentRecords.count)
    }
    
    var currentStreak: Int {
        var streak = 0
        var date = Date()
        let calendar = Calendar.current
        
        for _ in 0..<365 {
            let dayStart = calendar.startOfDay(for: date)
            let hasRecord = habit.records.contains { record in
                calendar.isDate(record.date, inSameDayAs: dayStart) && record.isCompleted
            }
            
            if hasRecord {
                streak += 1
                date = calendar.date(byAdding: .day, value: -1, to: date) ?? date
            } else {
                break
            }
        }
        
        return streak
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: horizontalSizeClass == .regular ? 18 : 15) {
            HStack {
                Image(systemName: habit.icon)
                    .font(.system(size: horizontalSizeClass == .regular ? 22 : 18))
                    .foregroundColor(habit.colorValue)
                
                Text(habit.title)
                    .font(horizontalSizeClass == .regular ? .title3 : .headline)
                
                Spacer()
            }
            
            HStack(spacing: horizontalSizeClass == .regular ? 25 : 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Current Streak")
                        .font(horizontalSizeClass == .regular ? .subheadline : .caption)
                        .foregroundColor(.gray)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(currentStreak)")
                            .font(horizontalSizeClass == .regular ? .title : .title2)
                            .fontWeight(.bold)
                        Text("days")
                            .font(horizontalSizeClass == .regular ? .subheadline : .caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Divider()
                    .frame(height: horizontalSizeClass == .regular ? 50 : 40)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Completion Rate")
                        .font(horizontalSizeClass == .regular ? .subheadline : .caption)
                        .foregroundColor(.gray)
                    
                    Text("\(Int(completionRate * 100))%")
                        .font(horizontalSizeClass == .regular ? .title : .title2)
                        .fontWeight(.bold)
                }
            }
        }
        .padding(horizontalSizeClass == .regular ? 20 : 15)
        .background(Color(.systemGray6))
        .cornerRadius(horizontalSizeClass == .regular ? 20 : 15)
    }
}

#Preview {
    StatisticsView()
        .environmentObject(HabitListViewModel())
}

