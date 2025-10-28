//
//  ProfileViewModel.swift
//  RoomMatey
//
//  Created by Ian Quack on 10/20/25.
//

import Foundation
import Combine

class ProfileViewModel: ObservableObject {
    @Published var profileName: String = ""
    @Published var groupName: String = ""
    @Published var profileImageData: Data?
    @Published var isAuthenticated: Bool = false
    @Published var hasCompletedOnboarding: Bool = false
    @Published var showingCopiedAlert = false
    @Published var showingShareSheet = false
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadUserData()
    }
    
    var inviteLink: String {
        "roommatey://join/\(groupName.replacingOccurrences(of: " ", with: "%20"))"
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
    
    func copyInviteLink() {
        // In MVVM, the ViewModel should not directly interact with UI components like UIPasteboard.
        // The View layer should handle the actual copying operation.
        // This method just signals that a copy action should occur.
        showingCopiedAlert = true
    }
    
    func showShareSheet() {
        showingShareSheet = true
    }
    
    func hideShareSheet() {
        showingShareSheet = false
    }
    
    func hideCopiedAlert() {
        showingCopiedAlert = false
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
