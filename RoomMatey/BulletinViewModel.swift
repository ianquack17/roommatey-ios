//
//  BulletinViewModel.swift
//  RoomMatey
//
//  Created by Ian Quack on 10/20/25.
//

import Foundation
import Combine
import SwiftUI

class BulletinViewModel: ObservableObject {
    @Published var notes: [BulletinNote] = []
    @Published var showingAddNote = false
    @Published var selectedNote: BulletinNote?
    @Published var showingNoteDetail = false
    @Published var draggedNote: BulletinNote?
    @Published var showingDeleteZone = false
    
    private let userDefaults = UserDefaults.standard
    private let notesKey = "savedBulletinNotes"
    
    init() {
        loadNotes()
    }
    
    func addNote(_ note: BulletinNote) {
        notes.append(note)
        saveNotes()
    }
    
    func updateNotePosition(_ noteId: UUID, _ newPosition: CGPoint) {
        if let index = notes.firstIndex(where: { $0.id == noteId }) {
            notes[index].position = newPosition
            saveNotes()
        }
    }
    
    func deleteNote(_ noteId: UUID) {
        notes.removeAll { $0.id == noteId }
        saveNotes()
    }
    
    func selectNote(_ note: BulletinNote?) {
        selectedNote = note
        showingNoteDetail = note != nil
    }
    
    func showAddNote() {
        showingAddNote = true
    }
    
    func hideAddNote() {
        showingAddNote = false
    }
    
    func startDrag(_ note: BulletinNote) {
        draggedNote = note
        showingDeleteZone = true
    }
    
    func endDrag() {
        draggedNote = nil
        showingDeleteZone = false
    }
    
    func handleDrop(at location: CGPoint, viewSize: CGSize) -> Bool {
        guard let draggedNote = draggedNote else { return false }
        
        // Check if dropped in delete zone
        // The delete zone is positioned in the bottom-right corner
        // with trailing: 20, bottom: 20, and a 60x60 circle
        let deleteZoneX = viewSize.width - 80  // 20 (padding) + 60 (circle) = 80
        let deleteZoneY = viewSize.height - 80 // 20 (padding) + 60 (circle) = 80
        
        if location.x > deleteZoneX && location.y > deleteZoneY {
            deleteNote(draggedNote.id)
            return true
        }
        
        return false
    }
    
    private func loadNotes() {
        if let data = userDefaults.data(forKey: notesKey),
           let decodedNotes = try? JSONDecoder().decode([BulletinNote].self, from: data) {
            notes = decodedNotes
        }
    }
    
    private func saveNotes() {
        if let encoded = try? JSONEncoder().encode(notes) {
            userDefaults.set(encoded, forKey: notesKey)
        }
    }
}
