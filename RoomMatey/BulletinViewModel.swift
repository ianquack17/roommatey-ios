//
//  BulletinViewModel.swift
//  RoomMatey
//
//  Created by Ian Quack on 10/20/25.
//

import Foundation
import Combine
import SwiftUI
import FirebaseFirestore

class BulletinViewModel: ObservableObject {
    @Published var notes: [BulletinNote] = []
    @Published var showingAddNote = false
    @Published var selectedNote: BulletinNote?
    @Published var showingNoteDetail = false
    @Published var draggedNote: BulletinNote?
    @Published var showingDeleteZone = false
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    // Get the GroupID from UserDefaults to know which notes to fetch
    private var currentGroupID: String {
        UserDefaults.standard.string(forKey: "groupID") ?? ""
    }
    
    init() {
        startRealtimeUpdates()
    }
    
    deinit {
        listener?.remove()
    }
    
    // database logic
    
    func startRealtimeUpdates() {
        guard !currentGroupID.isEmpty else { return }
        
        // Listen to: groups -> [groupID] -> notes
        listener = db.collection("groups").document(currentGroupID).collection("notes")
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                
                // Map Firestore documents to your BulletinNote model
                self?.notes = documents.compactMap { queryDocumentSnapshot -> BulletinNote? in
                    return try? queryDocumentSnapshot.data(as: BulletinNote.self)
                }
            }
    }
    
    func addNote(_ note: BulletinNote) {
        guard !currentGroupID.isEmpty else { return }
        
        do {
            // Save to Firestore
            try db.collection("groups").document(currentGroupID).collection("notes").document(note.id.uuidString).setData(from: note)
        } catch {
            print("Error adding note: \(error)")
        }
    }
    
    func updateNotePosition(_ noteId: UUID, _ newPosition: CGPoint) {
        guard !currentGroupID.isEmpty else { return }
        
        let pointData = ["x": newPosition.x, "y": newPosition.y]
        
        // We only update the position field to avoid overwriting other edits
        db.collection("groups").document(currentGroupID).collection("notes").document(noteId.uuidString).updateData([
            "position": pointData
        ])
    }
    
    func deleteNote(_ noteId: UUID) {
        guard !currentGroupID.isEmpty else { return }
        
        db.collection("groups").document(currentGroupID).collection("notes").document(noteId.uuidString).delete()
    }
        
    // Drag helpers
    func selectNote(_ note: BulletinNote?) {
        selectedNote = note
        showingNoteDetail = note != nil
    }
    
    func showAddNote() { showingAddNote = true }
    func hideAddNote() { showingAddNote = false }
    
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
        
        let deleteZoneX = viewSize.width - 80
        let deleteZoneY = viewSize.height - 80
        
        if location.x > deleteZoneX && location.y > deleteZoneY {
            deleteNote(draggedNote.id)
            return true
        }
        return false
    }
}
