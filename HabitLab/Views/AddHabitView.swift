//
//  AddHabitView.swift
//  HabitLab
//
//  Created by Вадим Дзюба on 13.10.2025.
//

import SwiftUI

struct AddHabitView: View {
    @EnvironmentObject var viewModel: HabitListViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State private var title = ""
    @State private var habitDescription = ""
    @State private var isGood = true
    @State private var selectedColor = "blue"
    @State private var selectedIcon = "star.fill"
    
    let colors = ["blue", "green", "red", "orange", "purple", "pink", "yellow"]
    let icons = ["star.fill", "heart.fill", "flame.fill", "bolt.fill", "leaf.fill", "book.fill", "dumbbell.fill", "cup.and.saucer.fill"]
    
    var iconSize: CGFloat {
        horizontalSizeClass == .regular ? 54 : 44
    }
    
    var colorCircleSize: CGFloat {
        horizontalSizeClass == .regular ? 54 : 44
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Habit Information") {
                    TextField("Title", text: $title)
                    
                    TextField("Description (optional)", text: $habitDescription, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Habit Type") {
                    Picker("Type", selection: $isGood) {
                        Text("Good Habit").tag(true)
                        Text("Bad Habit").tag(false)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Color") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: horizontalSizeClass == .regular ? 20 : 15) {
                            ForEach(colors, id: \.self) { color in
                                Circle()
                                    .fill(colorForString(color))
                                    .frame(width: colorCircleSize, height: colorCircleSize)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.primary, lineWidth: selectedColor == color ? 3 : 0)
                                    )
                                    .onTapGesture {
                                        selectedColor = color
                                    }
                            }
                        }
                        .padding(.vertical, horizontalSizeClass == .regular ? 12 : 8)
                    }
                }
                
                Section("Icon") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: horizontalSizeClass == .regular ? 20 : 15) {
                            ForEach(icons, id: \.self) { icon in
                                Image(systemName: icon)
                                    .font(.system(size: horizontalSizeClass == .regular ? 24 : 20))
                                    .foregroundColor(selectedIcon == icon ? .white : .primary)
                                    .frame(width: iconSize, height: iconSize)
                                    .background(selectedIcon == icon ? colorForString(selectedColor) : Color.gray.opacity(0.2))
                                    .clipShape(Circle())
                                    .onTapGesture {
                                        selectedIcon = icon
                                    }
                            }
                        }
                        .padding(.vertical, horizontalSizeClass == .regular ? 12 : 8)
                    }
                }
            }
            .navigationTitle("Add Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveHabit()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func saveHabit() {
        viewModel.addHabit(
            title: title,
            description: habitDescription,
            isGood: isGood,
            color: selectedColor,
            icon: selectedIcon
        )
        dismiss()
    }
    
    private func colorForString(_ string: String) -> Color {
        switch string {
        case "blue": return .blue
        case "green": return .green
        case "red": return .red
        case "orange": return .orange
        case "purple": return .purple
        case "pink": return .pink
        case "yellow": return .yellow
        default: return .blue
        }
    }
}

#Preview {
    AddHabitView()
        .environmentObject(HabitListViewModel())
}

