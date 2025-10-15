//
//  OrientationManager.swift
//  HabitLab
//
//  Created by Вадим Дзюба on 13.10.2025.
//

import SwiftUI

struct OrientationManager: ViewModifier {
    let orientation: UIInterfaceOrientationMask
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                AppDelegate.orientationLock = orientation
                // Принудительно обновляем ориентацию
                updateOrientation()
            }
            .onDisappear {
                AppDelegate.orientationLock = .portrait
                // Возвращаем портретную ориентацию
                updateOrientation()
            }
    }
    
    private func updateOrientation() {
        if #available(iOS 16.0, *) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: orientation))
            
            // Для iOS 16+ используем новый API
            DispatchQueue.main.async {
                windowScene.windows.first?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
            }
        } else {
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }
}

extension View {
    func supportedOrientation(_ orientation: UIInterfaceOrientationMask) -> some View {
        self.modifier(OrientationManager(orientation: orientation))
    }
}

