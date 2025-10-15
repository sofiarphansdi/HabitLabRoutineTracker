//
//  HabitLabApp.swift
//  HabitLab
//
//  Created by Вадим Дзюба on 13.10.2025.
//

import SwiftUI
import CoreData

@main
struct HabitLabApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var appViewModel = AppViewModel()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("appTheme") private var appTheme: String = "system"
    
    var currentTheme: ColorScheme? {
        switch appTheme {
        case "dark": return .dark
        case "light": return .light
        default: return nil
        }
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                switch appViewModel.appState {
                case .loading:
                    LoadingView()
                case .habitView:
                    HabitView()
                case .mainApp:
                    MainTabView()
                }
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .preferredColorScheme(currentTheme)
            .onAppear {
                appViewModel.checkInitialState()
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationLock = UIInterfaceOrientationMask.portrait
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}
