//
//  RoomMateyApp.swift
//  RoomMatey
//
//  Created by Ian Quack on 10/20/25.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct RoomMateyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // Initialize the AppState here so its available for the whoel cycle
    @StateObject var appState = AppState()

    @AppStorage("profileName") var profileName: String = ""
    @AppStorage("groupName") var groupName: String = ""
    @AppStorage("isAuthenticated") var isAuthenticated: Bool = false
    @AppStorage("profileImageData") var profileImageData: Data?
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @AppStorage("groupID") var groupID: String = ""

    var body: some Scene {
        WindowGroup {
            if !hasCompletedOnboarding {
                OnboardingView()
            } else if !isAuthenticated {
                AuthenticationView()
            } else if profileName.isEmpty {
                ProfileSetupView()
            } else if groupID.isEmpty {
                GroupSetupView()
            } else {
                ContentView()
                    .environmentObject(appState) // Pass it down to the views!
            }
        }
    }
}
