//
//  NetworkService.swift
//  HabitLab
//
//  Created by Вадим Дзюба on 13.10.2025.
//

import Foundation
import SwiftUI

enum NetworkError: Error {
    case invalidResponse
    case noData
    case requestFailed
}

final class NetworkService {
    static let shared = NetworkService()
    
    private init() {}
    
    func performServerRequest(completion: @escaping (Result<String, NetworkError>) -> Void) {
        let country = (Locale.current.region?.identifier) ?? "rr"
        
        
        let language = Locale.preferredLanguages.first?.components(separatedBy: "-").first ?? "hh"
        
        guard var components = URLComponents(string: "https://wallen-eatery.space/ios-vdm-6/server.php") else {
            completion(.failure(.invalidResponse))
            return
        }
        
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        components.queryItems = [
            URLQueryItem(name: "p", value: "Bs2675kDjkb5Ga"),
            URLQueryItem(name: "os", value: UIDevice.current.systemVersion),
            URLQueryItem(name: "lng", value: language),
            URLQueryItem(name: "devicemodel", value: identifier),
            URLQueryItem(name: "county", value: country)
        ]
        
        guard let requestPath = components.url else {
            completion(.failure(.invalidResponse))
            return
        }
        
        var request = URLRequest(url: requestPath)
        request.httpMethod = "GET"
        request.timeoutInterval = 30
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                DispatchQueue.main.async {
                    completion(.failure(.requestFailed))
                }
                return
            }
            
            guard let data = data, let responseString = String(data: data, encoding: .utf8) else {
                DispatchQueue.main.async {
                    completion(.failure(.noData))
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(.success(responseString))
            }
        }
        
        task.resume()
    }
    
    func parseResponse(_ response: String) -> (token: String?, link: String?) {
        if response.contains("#") {
            let components = response.components(separatedBy: "#")
            if components.count >= 2 {
                let token = components[0]
                let link = components[1]
                return (token, link)
            }
        }
        return (nil, nil)
    }
}

