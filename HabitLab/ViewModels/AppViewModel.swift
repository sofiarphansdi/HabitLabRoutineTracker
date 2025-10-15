//
//  AppViewModel.swift
//  HabitLab
//
//  Created by Вадим Дзюба on 13.10.2025.
//

import Foundation
import SwiftUI
import Combine

enum AppState {
    case loading
    case habitView
    case mainApp
}

final class AppViewModel: ObservableObject {
    @Published var appState: AppState = .loading
    
    private let networkService = NetworkService.shared
    private let storageService = StorageService.shared
    
    func checkInitialState() {
        if storageService.hasToken() {
            appState = .habitView
        } else {
            performInitialRequest()
        }
    }
    
    private func performInitialRequest() {
        networkService.performServerRequest { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                let (token, link) = self.networkService.parseResponse(response)
                
                if let token = token, let link = link {
                    self.storageService.token = token
                    self.storageService.serverLink = link
                    self.appState = .habitView
                } else {
                    self.appState = .mainApp
                }
                
            case .failure:
                self.appState = .mainApp
            }
        }
    }
}

