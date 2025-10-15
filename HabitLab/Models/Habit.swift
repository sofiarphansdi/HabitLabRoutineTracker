//
//  Habit.swift
//  HabitLab
//
//  Created by Вадим Дзюба on 13.10.2025.
//

import Foundation
import SwiftUI

struct Habit: Identifiable {
    let id: UUID
    var title: String
    var habitDescription: String
    var isGood: Bool
    var createdDate: Date
    var color: String
    var icon: String
    var records: [HabitRecord]
    
    init(id: UUID = UUID(), title: String, habitDescription: String = "", isGood: Bool = true, createdDate: Date = Date(), color: String = "blue", icon: String = "star.fill", records: [HabitRecord] = []) {
        self.id = id
        self.title = title
        self.habitDescription = habitDescription
        self.isGood = isGood
        self.createdDate = createdDate
        self.color = color
        self.icon = icon
        self.records = records
    }
    
    var colorValue: Color {
        switch color {
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

struct HabitRecord: Identifiable {
    let id: UUID
    var date: Date
    var isCompleted: Bool
    
    init(id: UUID = UUID(), date: Date, isCompleted: Bool = false) {
        self.id = id
        self.date = date
        self.isCompleted = isCompleted
    }
}

