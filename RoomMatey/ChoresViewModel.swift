//
//  ChoresViewModel.swift
//  RoomMatey
//
//  Created by Ian Quack on 10/20/25.
//

import Foundation
import Combine
import FirebaseFirestore

class ChoresViewModel: ObservableObject {
    @Published var chores: [Chore] = []
    @Published var showingAddChore = false
    @Published var selectedChore: Chore?
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    private var currentGroupID: String {
        UserDefaults.standard.string(forKey: "groupID") ?? ""
    }
    
    init() {
        startRealtimeUpdates()
    }
    
    deinit {
        listener?.remove()
    }
    
    // Firestore Sync
    
    func startRealtimeUpdates() {
        guard !currentGroupID.isEmpty else { return }
        
        // Listen to: groups -> [groupID] -> chores
        listener = db.collection("groups").document(currentGroupID).collection("chores")
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching chores: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                self?.chores = documents.compactMap { document -> Chore? in
                    try? document.data(as: Chore.self)
                }
            }
    }
    
    // User Actions
    
    func addChore(_ chore: Chore) {
        guard !currentGroupID.isEmpty else { return }
        
        do {
            try db.collection("groups").document(currentGroupID).collection("chores")
                .document(chore.id.uuidString)
                .setData(from: chore)
        } catch {
            print("Error adding chore: \(error)")
        }
    }
    
    func updateChore(_ chore: Chore) {
        guard !currentGroupID.isEmpty else { return }
        
        do {
            try db.collection("groups").document(currentGroupID).collection("chores")
                .document(chore.id.uuidString)
                .setData(from: chore)
        } catch {
            print("Error updating chore: \(error)")
        }
    }
    
    func deleteChore(_ chore: Chore) {
        guard !currentGroupID.isEmpty else { return }
        
        db.collection("groups").document(currentGroupID).collection("chores")
            .document(chore.id.uuidString)
            .delete()
    }
    
    // Firebase Logic
    
    // This calculates the new state locally, then saves it to Firestore
    func markChoreComplete(_ chore: Chore) {
        var updatedChore = chore
        
        // Mark current person as the "doer"
        updatedChore.doneBy = chore.nextPerson
        updatedChore.date = Date()
        updatedChore.lastCompleted = Date()
        
        // Calculate next person for chore
        if let currentIndex = chore.assignedTo.firstIndex(of: chore.nextPerson) {
            let nextIndex = (currentIndex + 1) % chore.assignedTo.count
            updatedChore.nextPerson = chore.assignedTo[nextIndex]
        }
        
        // Send update to database
        updateChore(updatedChore)
    }
    
    // UI Helpers
    func showAddChore() { showingAddChore = true }
    func hideAddChore() { showingAddChore = false }
    
    func selectChore(_ chore: Chore?) {
        selectedChore = chore
    }
}
