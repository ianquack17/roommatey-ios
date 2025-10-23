//
//  GroceryViewModel.swift
//  RoomMatey
//
//  Created by Ian Quack on 10/20/25.
//

import Foundation
import Combine

class GroceryViewModel: ObservableObject {
    @Published var groceries: [GroceryItem] = []
    @Published var showingAddItem = false
    @Published var groupName: String = ""
    @Published var profileName: String = ""
    
    private let userDefaults = UserDefaults.standard
    private let groceriesKey = "savedGroceries"
    
    init() {
        loadUserData()
        loadGroceries()
    }
    
    var availableRoommates: [String] {
        if groupName == "Test Group" {
            return ["Alex", "Sam", profileName]
        } else {
            return [profileName]
        }
    }
    
    func addGroceryItem(_ item: GroceryItem) {
        groceries.append(item)
        saveGroceries()
    }
    
    func togglePurchaseStatus(for item: GroceryItem) {
        if let index = groceries.firstIndex(where: { $0.id == item.id }) {
            groceries[index].isPurchased.toggle()
            saveGroceries()
        }
    }
    
    func assignItem(_ item: GroceryItem, to roommate: String?) {
        if let index = groceries.firstIndex(where: { $0.id == item.id }) {
            groceries[index].assignedTo = roommate
            saveGroceries()
        }
    }
    
    func deleteItem(_ item: GroceryItem) {
        groceries.removeAll { $0.id == item.id }
        saveGroceries()
    }
    
    func showAddItem() {
        showingAddItem = true
    }
    
    func hideAddItem() {
        showingAddItem = false
    }
    
    func updateUserData(profileName: String, groupName: String) {
        self.profileName = profileName
        self.groupName = groupName
        saveUserData()
    }
    
    private func loadUserData() {
        profileName = userDefaults.string(forKey: "profileName") ?? ""
        groupName = userDefaults.string(forKey: "groupName") ?? ""
    }
    
    private func saveUserData() {
        userDefaults.set(profileName, forKey: "profileName")
        userDefaults.set(groupName, forKey: "groupName")
    }
    
    private func loadGroceries() {
        if let data = userDefaults.data(forKey: groceriesKey),
           let decodedGroceries = try? JSONDecoder().decode([GroceryItem].self, from: data) {
            groceries = decodedGroceries
        }
    }
    
    private func saveGroceries() {
        if let encoded = try? JSONEncoder().encode(groceries) {
            userDefaults.set(encoded, forKey: groceriesKey)
        }
    }
}
