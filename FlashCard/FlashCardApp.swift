//
//  FlashCardApp.swift
//  FlashCard
//
//  Created by Kenjaboy Xajiyev on 19/06/25.
//

import SwiftUI
import Firebase

@main
struct FlashCardApp: App {
    @StateObject private var authService = AuthenticationService()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if authService.isAuthenticated {
                ContentView()
                    .environmentObject(authService)
            } else {
                LoginView()
                    .environmentObject(authService)
            }
        }
    }
}
