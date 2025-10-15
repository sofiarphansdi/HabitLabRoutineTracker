//
//  NotificationsSettingsView.swift
//  HabitLab
//
//  Created by Вадим Дзюба on 13.10.2025.
//

import SwiftUI

struct NotificationsSettingsView: View {
    @StateObject private var notificationService = NotificationService.shared
    
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("morningReminderEnabled") private var morningReminderEnabled = false
    @AppStorage("eveningReminderEnabled") private var eveningReminderEnabled = false
    @AppStorage("morningReminderHour") private var morningReminderHour = 9
    @AppStorage("morningReminderMinute") private var morningReminderMinute = 0
    @AppStorage("eveningReminderHour") private var eveningReminderHour = 21
    @AppStorage("eveningReminderMinute") private var eveningReminderMinute = 0
    
    @State private var showMorningTimePicker = false
    @State private var showEveningTimePicker = false
    @State private var tempMorningDate = Date()
    @State private var tempEveningDate = Date()
    @State private var showPermissionAlert = false
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        List {
            Section {
                Toggle(isOn: $notificationsEnabled) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Enable Notifications")
                            .font(horizontalSizeClass == .regular ? .body : .body)
                        Text("Receive reminders about your habits")
                            .font(horizontalSizeClass == .regular ? .subheadline : .caption)
                            .foregroundColor(.gray)
                    }
                }
                .onChange(of: notificationsEnabled) { newValue in
                    if newValue && !notificationService.isAuthorized {
                        notificationService.requestAuthorization { granted in
                            if !granted {
                                notificationsEnabled = false
                                showPermissionAlert = true
                            }
                        }
                    } else if !newValue {
                        NotificationService.shared.removeAllNotifications()
                        morningReminderEnabled = false
                        eveningReminderEnabled = false
                    }
                }
            } footer: {
                if !notificationService.isAuthorized && notificationsEnabled {
                    Text("Please enable notifications in Settings to receive reminders.")
                        .foregroundColor(.red)
                }
            }
            
            if notificationsEnabled {
                Section("Daily Reminders") {
                    // Morning Reminder
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle(isOn: $morningReminderEnabled) {
                            Text("Morning Reminder")
                                .font(horizontalSizeClass == .regular ? .body : .body)
                        }
                        .onChange(of: morningReminderEnabled) { newValue in
                            if newValue {
                                scheduleMorningReminder()
                            } else {
                                NotificationService.shared.removeNotification(identifier: "morning_reminder")
                            }
                        }
                        
                        if morningReminderEnabled {
                            Button(action: {
                                tempMorningDate = createDate(hour: morningReminderHour, minute: morningReminderMinute)
                                showMorningTimePicker = true
                            }) {
                                HStack {
                                    Image(systemName: "clock")
                                        .foregroundColor(.blue)
                                    Text(timeString(hour: morningReminderHour, minute: morningReminderMinute))
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                    
                    // Evening Reminder
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle(isOn: $eveningReminderEnabled) {
                            Text("Evening Reminder")
                                .font(horizontalSizeClass == .regular ? .body : .body)
                        }
                        .onChange(of: eveningReminderEnabled) { newValue in
                            if newValue {
                                scheduleEveningReminder()
                            } else {
                                NotificationService.shared.removeNotification(identifier: "evening_reminder")
                            }
                        }
                        
                        if eveningReminderEnabled {
                            Button(action: {
                                tempEveningDate = createDate(hour: eveningReminderHour, minute: eveningReminderMinute)
                                showEveningTimePicker = true
                            }) {
                                HStack {
                                    Image(systemName: "clock")
                                        .foregroundColor(.blue)
                                    Text(timeString(hour: eveningReminderHour, minute: eveningReminderMinute))
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showMorningTimePicker) {
            TimePickerSheet(
                selectedDate: $tempMorningDate,
                title: "Morning Reminder Time",
                onSave: {
                    let components = Calendar.current.dateComponents([.hour, .minute], from: tempMorningDate)
                    morningReminderHour = components.hour ?? 9
                    morningReminderMinute = components.minute ?? 0
                    scheduleMorningReminder()
                }
            )
        }
        .sheet(isPresented: $showEveningTimePicker) {
            TimePickerSheet(
                selectedDate: $tempEveningDate,
                title: "Evening Reminder Time",
                onSave: {
                    let components = Calendar.current.dateComponents([.hour, .minute], from: tempEveningDate)
                    eveningReminderHour = components.hour ?? 21
                    eveningReminderMinute = components.minute ?? 0
                    scheduleEveningReminder()
                }
            )
        }
        .alert("Notifications Permission Required", isPresented: $showPermissionAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Open Settings") {
                if let request = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(request)
                }
            }
        } message: {
            Text("Please enable notifications in Settings to receive habit reminders.")
        }
    }
    
    private func scheduleMorningReminder() {
        NotificationService.shared.scheduleNotification(
            title: "Good Morning! 🌅",
            body: "Start your day by checking your habits",
            hour: morningReminderHour,
            minute: morningReminderMinute,
            identifier: "morning_reminder"
        )
    }
    
    private func scheduleEveningReminder() {
        NotificationService.shared.scheduleNotification(
            title: "Evening Check-in 🌙",
            body: "Don't forget to track your habits today",
            hour: eveningReminderHour,
            minute: eveningReminderMinute,
            identifier: "evening_reminder"
        )
    }
    
    private func timeString(hour: Int, minute: Int) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let date = createDate(hour: hour, minute: minute)
        return formatter.string(from: date)
    }
    
    private func createDate(hour: Int, minute: Int) -> Date {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components) ?? Date()
    }
}

struct TimePickerSheet: View {
    @Binding var selectedDate: Date
    let title: String
    let onSave: () -> Void
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                DatePicker(
                    "Select Time",
                    selection: $selectedDate,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                
                Spacer()
            }
            .padding()
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave()
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    NotificationsSettingsView()
}

