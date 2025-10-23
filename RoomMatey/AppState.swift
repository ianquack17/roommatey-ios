//
//  AppState.swift
//  RoomMatey
//
//  Created by Ian Quack on 10/20/25.
//

import Foundation
import Combine

class AppState: ObservableObject {
    @Published var isAuthenticated: Bool = false
    
    // ViewModels
    let authenticationViewModel = AuthenticationViewModel()
    let choresViewModel = ChoresViewModel()
    let bulletinViewModel = BulletinViewModel()
    let groceryViewModel = GroceryViewModel()
    let profileViewModel = ProfileViewModel()
    let homeViewModel = HomeViewModel()
    
    init() {
        // Sync authentication state
        authenticationViewModel.$isAuthenticated
            .assign(to: &$isAuthenticated)
    }
    
    func signIn() {
        authenticationViewModel.signIn(name: "")
        self.isAuthenticated = true
    }
}
