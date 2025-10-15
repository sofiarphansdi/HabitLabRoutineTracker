//
//  HabitListViewModel.swift
//  HabitLab
//
//  Created by Вадим Дзюба on 13.10.2025.
//

import Foundation
import CoreData
import SwiftUI
import Combine

final class HabitListViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    
    private let persistenceController = PersistenceController.shared
    private let context: NSManagedObjectContext
    
    init() {
        self.context = persistenceController.container.viewContext
        fetchHabits()
    }
    
    func fetchHabits() {
        let request: NSFetchRequest<HabitEntity> = HabitEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \HabitEntity.createdDate, ascending: false)]
        
        do {
            let entities = try context.fetch(request)
            habits = entities.compactMap { entity in
                convertToHabit(entity: entity)
            }
        } catch {
            print("Failed to fetch habits: \(error)")
        }
    }
    
    func addHabit(title: String, description: String, isGood: Bool, color: String, icon: String) {
        let newHabit = HabitEntity(context: context)
        newHabit.id = UUID()
        newHabit.title = title
        newHabit.habitDescription = description
        newHabit.isGood = isGood
        newHabit.createdDate = Date()
        newHabit.color = color
        newHabit.icon = icon
        
        saveContext()
        fetchHabits()
    }
    
    func deleteHabit(habit: Habit) {
        let request: NSFetchRequest<HabitEntity> = HabitEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", habit.id as CVarArg)
        
        do {
            let entities = try context.fetch(request)
            if let entity = entities.first {
                context.delete(entity)
                saveContext()
                fetchHabits()
            }
        } catch {
            print("Failed to delete habit: \(error)")
        }
    }
    
    func toggleHabitCompletion(habit: Habit, date: Date) {
        let request: NSFetchRequest<HabitEntity> = HabitEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", habit.id as CVarArg)
        
        do {
            let entities = try context.fetch(request)
            if let habitEntity = entities.first {
                let calendar = Calendar.current
                let startOfDay = calendar.startOfDay(for: date)
                
                let recordRequest: NSFetchRequest<HabitRecordEntity> = HabitRecordEntity.fetchRequest()
                recordRequest.predicate = NSPredicate(format: "habit == %@ AND date >= %@ AND date < %@", 
                                                     habitEntity,
                                                     startOfDay as CVarArg,
                                                     calendar.date(byAdding: .day, value: 1, to: startOfDay)! as CVarArg)
                
                let records = try context.fetch(recordRequest)
                
                if let existingRecord = records.first {
                    existingRecord.isCompleted.toggle()
                } else {
                    let newRecord = HabitRecordEntity(context: context)
                    newRecord.id = UUID()
                    newRecord.date = startOfDay
                    newRecord.isCompleted = true
                    newRecord.habit = habitEntity
                }
                
                saveContext()
                fetchHabits()
            }
        } catch {
            print("Failed to toggle habit: \(error)")
        }
    }
    
    func isHabitCompleted(habit: Habit, date: Date) -> Bool {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        return habit.records.contains { record in
            calendar.isDate(record.date, inSameDayAs: startOfDay) && record.isCompleted
        }
    }
    
    private func convertToHabit(entity: HabitEntity) -> Habit? {
        guard let id = entity.id,
              let title = entity.title,
              let createdDate = entity.createdDate,
              let color = entity.color else {
            return nil
        }
        
        let records = (entity.records?.allObjects as? [HabitRecordEntity])?.compactMap { recordEntity -> HabitRecord? in
            guard let recordId = recordEntity.id, let date = recordEntity.date else { return nil }
            return HabitRecord(id: recordId, date: date, isCompleted: recordEntity.isCompleted)
        } ?? []
        
        return Habit(
            id: id,
            title: title,
            habitDescription: entity.habitDescription ?? "",
            isGood: entity.isGood,
            createdDate: createdDate,
            color: color,
            icon: entity.icon ?? "star.fill",
            records: records
        )
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}

