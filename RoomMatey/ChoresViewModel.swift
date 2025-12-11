//
//  ChoresViewModel.swift
//  RoomMatey
//
//  Created by Ian Quack on 10/20/25.
//

import Foundation
import Combine
import FirebaseFirestore
import SwiftUI

class ChoresViewModel: ObservableObject {
    @Published var chores: [Chore] = []
    @Published var roommates: [String] = [] // This needs to be populated!
    @Published var showingAddChore = false
    @Published var selectedChore: Chore?
    
    // DIRECT ACCESS to the Group ID
    @AppStorage("groupID") var currentGroupID: String = ""
    @AppStorage("profileName") var profileName: String = ""
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private var memberListener: ListenerRegistration?
    
    init() {
        // We defer these slightly to ensure AppStorage is ready
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.startRealtimeUpdates()
            self.fetchRoommates()
        }
    }
    
    deinit {
        listener?.remove()
        memberListener?.remove()
    }
    
    // MARK: - Fetch Data
    
    func startRealtimeUpdates() {
        guard !currentGroupID.isEmpty else { return }
        
        // Fetch Chores
        listener = db.collection("groups").document(currentGroupID).collection("chores")
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let documents = querySnapshot?.documents else { return }
                self?.chores = documents.compactMap { try? $0.data(as: Chore.self) }
            }
    }
    
    func fetchRoommates() {
        guard !currentGroupID.isEmpty else {
            print("❌ Error: No Group ID found in ChoresViewModel")
            return
        }
        
        print("🔍 Fetching roommates for Group ID: \(currentGroupID)")
        
        // Listen to the GROUP document to get the 'members' array
        memberListener = db.collection("groups").document(currentGroupID)
            .addSnapshotListener { [weak self] documentSnapshot, error in
                guard let document = documentSnapshot, document.exists,
                      let data = document.data() else {
                    print("❌ Error fetching group data: \(String(describing: error))")
                    return
                }
                
                if let members = data["members"] as? [String] {
                    print("✅ Found Members: \(members)")
                    DispatchQueue.main.async {
                        self?.roommates = members
                    }
                } else {
                    print("⚠️ Group exists but has no 'members' field.")
                }
            }
    }
    
    // MARK: - User Actions
    
    func addChore(_ chore: Chore) {
        guard !currentGroupID.isEmpty else { return }
        do {
            try db.collection("groups").document(currentGroupID).collection("chores")
                .document(chore.id.uuidString)
                .setData(from: chore)
        } catch { print("Error adding chore: \(error)") }
    }
    
    func updateChore(_ chore: Chore) {
        guard !currentGroupID.isEmpty else { return }
        do {
            try db.collection("groups").document(currentGroupID).collection("chores")
                .document(chore.id.uuidString)
                .setData(from: chore)
        } catch { print("Error updating chore: \(error)") }
    }
    
    func deleteChore(_ chore: Chore) {
        guard !currentGroupID.isEmpty else { return }
        db.collection("groups").document(currentGroupID).collection("chores")
            .document(chore.id.uuidString)
            .delete()
    }
    
    // MARK: - Smart Rotation Logic
    
    func markChoreComplete(_ chore: Chore) {
        var updatedChore = chore
        let personWhoDidIt = chore.nextPerson
        
        updatedChore.doneBy = personWhoDidIt
        updatedChore.date = Date()
        updatedChore.lastCompleted = Date()
        
        // LOGIC: Rotate to the next person
        if chore.assignedTo.count > 1 {
            if let currentIndex = chore.assignedTo.firstIndex(of: personWhoDidIt) {
                let nextIndex = (currentIndex + 1) % chore.assignedTo.count
                updatedChore.nextPerson = chore.assignedTo[nextIndex]
            } else {
                // If the current person isn't in the list, restart at 0
                updatedChore.nextPerson = chore.assignedTo.first ?? personWhoDidIt
            }
        } else {
            print("⚠️ Only 1 person assigned. Cannot rotate.")
        }
        
        updateChore(updatedChore)
    }
    
    // MARK: - Helpers
    func showAddChore() {
        fetchRoommates() // Force refresh when opening the sheet
        showingAddChore = true
    }
    func hideAddChore() { showingAddChore = false }
    func selectChore(_ chore: Chore?) { selectedChore = chore }
}
