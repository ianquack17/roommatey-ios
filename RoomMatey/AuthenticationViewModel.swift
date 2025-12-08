//
//  AuthenticationViewModel.swift
//  RoomMatey
//
//  Created by Ian Quack on 10/20/25.
//

import Foundation
import Combine
import FirebaseAuth
import SwiftUI
import FirebaseFirestore

class AuthenticationViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage = ""
    @Published var showingError = false
    
    // Update AppStorage directly so the rest of the app knows we are in
    @AppStorage("isAuthenticated") var storedIsAuthenticated: Bool = false
    @AppStorage("profileName") var storedProfileName: String = ""
    @AppStorage("groupID") var storedGroupID: String = ""

    init() {
        // Check if Firebase remembers the user from last time
        if Auth.auth().currentUser != nil {
            self.isAuthenticated = true
            self.storedIsAuthenticated = true
        }
    }
    
    func authenticate(email: String, password: String, isSignUp: Bool) {
        if isSignUp {
            // Create Account
            Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
                if let error = error {
                    // If creation fails, user may already have an account
                    self?.errorMessage = error.localizedDescription
                    self?.showingError = true
                    return
                }
                // Success path
                self?.finishSignIn()
            }
        } else {
            // Sign In
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    self?.showingError = true
                    return
                }
                // Success path
                self?.finishSignIn()
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            // Clear local states
            withAnimation {
                storedIsAuthenticated = false
                isAuthenticated = false
                storedGroupID = "" // Clear the group so they don't see old data
                storedProfileName = ""
            }
        } catch {
            print("Error signing out: \(error)")
        }
    }
    
    private func finishSignIn() {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            // Fetch User Data from Firestore before letting them in
            let db = Firestore.firestore()
            db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
                
                if let data = snapshot?.data() {
                    // Restore persisted data
                    if let savedName = data["name"] as? String {
                        DispatchQueue.main.async {
                            self?.storedProfileName = savedName
                        }
                    }
                    if let savedGroupID = data["groupID"] as? String {
                        DispatchQueue.main.async {
                            self?.storedGroupID = savedGroupID
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    self?.isAuthenticated = true
                    self?.storedIsAuthenticated = true
                }
            }
        }
    }
