//
//  AuthenticationViewModel.swift
//  RoomMatey
//
//  Created by Ian Quack on 10/20/25.
//

import Foundation
import Combine

class AuthenticationViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var profileName: String = ""
    @Published var groupName: String = ""
    @Published var profileImageData: Data?
    @Published var hasCompletedOnboarding: Bool = false
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadUserData()
    }
    
    func signIn(name: String) {
        profileName = name.trimmingCharacters(in: .whitespaces)
        isAuthenticated = true
        saveUserData()
    }
    
    func signOut() {
        isAuthenticated = false
        hasCompletedOnboarding = false
        saveUserData()
    }
    
    func updateProfileName(_ newName: String) {
        profileName = newName.trimmingCharacters(in: .whitespaces)
        saveUserData()
    }
    
    func updateProfileImage(_ imageData: Data?) {
        profileImageData = imageData
        saveUserData()
    }
    
    func updateGroupName(_ newGroupName: String) {
        groupName = newGroupName.trimmingCharacters(in: .whitespaces)
        saveUserData()
    }
    
    func leaveGroup() {
        groupName = ""
        saveUserData()
    }
    
    func resetAllData() {
        profileName = ""
        groupName = ""
        profileImageData = nil
        isAuthenticated = false
        hasCompletedOnboarding = false
        saveUserData()
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        saveUserData()
    }
    
    private func loadUserData() {
        profileName = userDefaults.string(forKey: "profileName") ?? ""
        groupName = userDefaults.string(forKey: "groupName") ?? ""
        isAuthenticated = userDefaults.bool(forKey: "isAuthenticated")
        hasCompletedOnboarding = userDefaults.bool(forKey: "hasCompletedOnboarding")
        profileImageData = userDefaults.data(forKey: "profileImageData")
    }
    
    private func saveUserData() {
        userDefaults.set(profileName, forKey: "profileName")
        userDefaults.set(groupName, forKey: "groupName")
        userDefaults.set(isAuthenticated, forKey: "isAuthenticated")
        userDefaults.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        if let imageData = profileImageData {
            userDefaults.set(imageData, forKey: "profileImageData")
        } else {
            userDefaults.removeObject(forKey: "profileImageData")
        }
    }
}
