//
//  RoomMateyApp.swift
//  RoomMatey
//
//  Created by Ian Quack on 10/20/25.
//

import SwiftUI

@main
struct RoomMateyApp: App {
    @AppStorage("profileName") var profileName: String = ""
    @AppStorage("groupName") var groupName: String = ""
    @AppStorage("isAuthenticated") var isAuthenticated: Bool = false
    @AppStorage("profileImageData") var profileImageData: Data?
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false

    var body: some Scene {
        WindowGroup {
            if !hasCompletedOnboarding {
                OnboardingView()
            } else if !isAuthenticated {
                AuthenticationView()
            } else if profileName.isEmpty {
                ProfileSetupView()
            } else if groupName.isEmpty {
                GroupSetupView()
            } else {
                ContentView()
            }
        }
    }
}
