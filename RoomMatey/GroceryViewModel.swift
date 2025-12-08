//
//  GroceryViewModel.swift
//  RoomMatey
//
//  Created by Ian Quack on 10/20/25.
//

import Foundation
import Combine
import FirebaseFirestore
import SwiftUI

class GroceryViewModel: ObservableObject {
    @Published var groceries: [GroceryItem] = []
    @Published var showingAddItem = false
    @AppStorage("profileName") var profileName: String = ""
    @AppStorage("groupID") var currentGroupID: String = ""
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    init() {
        startRealtimeUpdates()
    }
    
    deinit {
        listener?.remove()
    }
    
    // Firestore Sync
    func startRealtimeUpdates() {
        guard !currentGroupID.isEmpty else { return }
        
        listener = db.collection("groups").document(currentGroupID).collection("groceries")
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching groceries: \(error?.localizedDescription ?? "Unknown")")
                    return
                }
                
                self?.groceries = documents.compactMap { document -> GroceryItem? in
                    try? document.data(as: GroceryItem.self)
                }
            }
    }
    
    // User Actions
    
    func addGroceryItem(_ item: GroceryItem) {
        guard !currentGroupID.isEmpty else { return }
        do {
            try db.collection("groups").document(currentGroupID).collection("groceries")
                .document(item.id.uuidString)
                .setData(from: item)
        } catch {
            print("Error adding grocery: \(error)")
        }
    }
    
    func togglePurchaseStatus(for item: GroceryItem) {
        guard !currentGroupID.isEmpty else { return }
        
        // Toggle local value then send to DB
        let newValue = !item.isPurchased
        
        db.collection("groups").document(currentGroupID).collection("groceries")
            .document(item.id.uuidString)
            .updateData(["isPurchased": newValue])
    }
    
    func assignItem(_ item: GroceryItem, to roommate: String?) {
        guard !currentGroupID.isEmpty else { return }
        
        db.collection("groups").document(currentGroupID).collection("groceries")
            .document(item.id.uuidString)
            .updateData(["assignedTo": roommate as Any])
    }
    
    func deleteItem(_ item: GroceryItem) {
        guard !currentGroupID.isEmpty else { return }
        
        db.collection("groups").document(currentGroupID).collection("groceries")
            .document(item.id.uuidString)
            .delete()
    }
    
    // Helpers
    func showAddItem() { showingAddItem = true }
    func hideAddItem() { showingAddItem = false }
    
    // Placeholder!!!
    var availableRoommates: [String] {
        return [profileName, "Roommate"]
    }
}
