//
//  MainTabView.swift
//  HabitLab
//
//  Created by Вадим Дзюба on 13.10.2025.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var habitViewModel = HabitListViewModel()
    
    var body: some View {
        TabView {
            CalendarView()
                .environmentObject(habitViewModel)
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
            
            StatisticsView()
                .environmentObject(habitViewModel)
                .tabItem {
                    Label("Statistics", systemImage: "chart.bar.fill")
                }
            
            TipsView()
                .tabItem {
                    Label("Tips", systemImage: "lightbulb.fill")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }
}

#Preview {
    MainTabView()
}
