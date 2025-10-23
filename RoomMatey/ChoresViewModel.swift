//
//  ChoresViewModel.swift
//  RoomMatey
//
//  Created by Ian Quack on 10/20/25.
//

import Foundation
import Combine

class ChoresViewModel: ObservableObject {
    @Published var chores: [Chore] = []
    @Published var showingAddChore = false
    @Published var selectedChore: Chore?
    
    private let userDefaults = UserDefaults.standard
    private let choresKey = "savedChores"
    
    init() {
        loadChores()
        if chores.isEmpty {
            setupDefaultChores()
        }
    }
    
    func addChore(_ chore: Chore) {
        chores.append(chore)
        saveChores()
    }
    
    func updateChore(_ chore: Chore) {
        if let index = chores.firstIndex(where: { $0.id == chore.id }) {
            chores[index] = chore
            saveChores()
        }
    }
    
    func deleteChore(_ chore: Chore) {
        chores.removeAll { $0.id == chore.id }
        saveChores()
    }
    
    func markChoreComplete(_ chore: Chore) {
        if let index = chores.firstIndex(where: { $0.id == chore.id }) {
            chores[index].doneBy = chore.nextPerson
            chores[index].date = Date()
            // Rotate to next person in assigned list
            if let currentIndex = chores[index].assignedTo.firstIndex(of: chore.nextPerson) {
                let nextIndex = (currentIndex + 1) % chores[index].assignedTo.count
                chores[index].nextPerson = chores[index].assignedTo[nextIndex]
            }
            saveChores()
        }
    }
    
    func showAddChore() {
        showingAddChore = true
    }
    
    func hideAddChore() {
        showingAddChore = false
    }
    
    func selectChore(_ chore: Chore?) {
        selectedChore = chore
    }
    
    private func setupDefaultChores() {
        let defaultChores = [
            Chore(
                task: "Dishes",
                doneBy: "Alex",
                date: Date(),
                nextPerson: "Sam",
                frequency: .daily,
                description: "Wash and put away all dishes",
                lastCompleted: nil,
                assignedTo: ["Alex", "Sam"]
            ),
            Chore(
                task: "Trash",
                doneBy: "Sam",
                date: Date(),
                nextPerson: "Alex",
                frequency: .weekly,
                description: "Take out all trash and recycling",
                lastCompleted: nil,
                assignedTo: ["Alex", "Sam"]
            )
        ]
        chores = defaultChores
        saveChores()
    }
    
    private func loadChores() {
        if let data = userDefaults.data(forKey: choresKey),
           let decodedChores = try? JSONDecoder().decode([Chore].self, from: data) {
            chores = decodedChores
        }
    }
    
    private func saveChores() {
        if let encoded = try? JSONEncoder().encode(chores) {
            userDefaults.set(encoded, forKey: choresKey)
        }
    }
}
