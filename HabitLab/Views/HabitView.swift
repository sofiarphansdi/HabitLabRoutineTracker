//
//  HabitView.swift
//  HabitLab
//
//  Created by Вадим Дзюба on 13.10.2025.
//

import SwiftUI
import WebKit

struct HabitView: View {
    @State private var isLoading = true
    private let storageService = StorageService.shared
    
    var body: some View {
        ZStack {
            if let linkString = storageService.serverLink,
               let linkPath = URL(string: linkString) {
                ContentDisplayView(path: linkPath, isLoading: $isLoading)
                    .ignoresSafeArea()
            } else {
                Text("No link available")
                    .foregroundColor(.white)
            }
            
            if isLoading {
                Color.black
                    .ignoresSafeArea()
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
        }
        .statusBar(hidden: true)
        .supportedOrientation(.all)
    }
}

struct ContentDisplayView: UIViewRepresentable {
    let path: URL
    @Binding var isLoading: Bool
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        let display = WKWebView(frame: .zero, configuration: configuration)
        display.navigationDelegate = context.coordinator
        display.allowsBackForwardNavigationGestures = true
        display.scrollView.contentInsetAdjustmentBehavior = .never
        
        return display
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if uiView.url == nil {
            let request = URLRequest(url: path)
            uiView.load(request)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: ContentDisplayView
        
        init(_ parent: ContentDisplayView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
        }
    }
}

#Preview {
    HabitView()
}

