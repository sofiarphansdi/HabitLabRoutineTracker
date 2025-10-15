//
//  CalendarView.swift
//  HabitLab
//
//  Created by Вадим Дзюба on 13.10.2025.
//

import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var viewModel: HabitListViewModel
    @State private var selectedDate = Date()
    @State private var showAddHabit = false
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Date Picker
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding(horizontalSizeClass == .regular ? 20 : 15)
                
                Divider()
                
                // Habits List
                if viewModel.habits.isEmpty {
                    emptyStateView
                } else {
                    List {
                        ForEach(viewModel.habits) { habit in
                            HabitRowView(habit: habit, selectedDate: selectedDate)
                                .environmentObject(viewModel)
                        }
                        .onDelete(perform: deleteHabits)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Calendar")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddHabit = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddHabit) {
                AddHabitView()
                    .environmentObject(viewModel)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "checkmark.circle")
                .font(.system(size: horizontalSizeClass == .regular ? 80 : 60))
                .foregroundColor(.gray)
            
            Text("No habits yet")
                .font(horizontalSizeClass == .regular ? .title : .title2)
                .fontWeight(.semibold)
            
            Text("Tap + to add your first habit")
                .font(horizontalSizeClass == .regular ? .body : .subheadline)
                .foregroundColor(.gray)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func deleteHabits(at offsets: IndexSet) {
        for index in offsets {
            let habit = viewModel.habits[index]
            viewModel.deleteHabit(habit: habit)
        }
    }
}

struct HabitRowView: View {
    @EnvironmentObject var viewModel: HabitListViewModel
    let habit: Habit
    let selectedDate: Date
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var isCompleted: Bool {
        viewModel.isHabitCompleted(habit: habit, date: selectedDate)
    }
    
    var iconSize: CGFloat {
        horizontalSizeClass == .regular ? 50 : 40
    }
    
    var body: some View {
        HStack(spacing: horizontalSizeClass == .regular ? 20 : 15) {
            // Icon
            Image(systemName: habit.icon)
                .font(.system(size: horizontalSizeClass == .regular ? 24 : 20))
                .foregroundColor(habit.colorValue)
                .frame(width: iconSize, height: iconSize)
                .background(habit.colorValue.opacity(0.2))
                .clipShape(Circle())
            
            // Habit Info
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.title)
                    .font(horizontalSizeClass == .regular ? .title3 : .headline)
                    .lineLimit(2)
                
                Text(habit.isGood ? "Good Habit" : "Bad Habit")
                    .font(horizontalSizeClass == .regular ? .subheadline : .caption)
                    .foregroundColor(.gray)
            }
            
            Spacer(minLength: 10)
            
            // Completion Button
            Button(action: {
                viewModel.toggleHabitCompletion(habit: habit, date: selectedDate)
            }) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: horizontalSizeClass == .regular ? 32 : 28))
                    .foregroundColor(isCompleted ? .green : .gray)
            }
        }
        .padding(.vertical, horizontalSizeClass == .regular ? 12 : 8)
    }
}

#Preview {
    CalendarView()
        .environmentObject(HabitListViewModel())
}

