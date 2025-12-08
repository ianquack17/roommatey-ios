//
//  HomeViewModel.swift
//  RoomMatey
//
//  Created by Ian Quack on 10/20/25.
//

import Foundation
import Combine
import FirebaseFirestore
import SwiftUI

// Models
struct RoommateSchedule: Identifiable {
    let id = UUID()
    let name: String
    let events: [ScheduleEvent]
}

struct ScheduleEvent: Identifiable, Codable {
    let id: UUID
    let title: String
    let startTime: Date
    let endTime: Date
    let color: String
    let isAllDay: Bool
    let createdBy: String
    
    init(id: UUID = UUID(), title: String, startTime: Date, endTime: Date, color: String, isAllDay: Bool, createdBy: String) {
        self.id = id
        self.title = title
        self.startTime = startTime
        self.endTime = endTime
        self.color = color
        self.isAllDay = isAllDay
        self.createdBy = createdBy
    }
}

class HomeViewModel: ObservableObject {
    @Published var roommateSchedules: [RoommateSchedule] = []
    @Published var currentWeek: [Date] = []
    @Published var showingAddEvent = false
    @Published var roommates: [String] = []
    @Published var groupNameLabel: String = "My Group"
    @Published var groupCodeLabel: String = ""
    
    @AppStorage("profileName") var profileName: String = ""
    @AppStorage("groupID") var currentGroupID: String = ""
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private var groupListener: ListenerRegistration?
    private var allEvents: [ScheduleEvent] = []
    
    init() {
        setupCurrentWeek()
        startRealtimeUpdates()
        fetchGroupDetails() // Call the new fetcher
    }
    
    deinit {
        listener?.remove()
        groupListener?.remove()
    }
    
    // Firestore
    
    // Fetch existing events
    func startRealtimeUpdates() {
        guard !currentGroupID.isEmpty else { return }
        
        listener = db.collection("groups").document(currentGroupID).collection("events")
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let documents = querySnapshot?.documents else { return }
                
                let events = documents.compactMap { try? $0.data(as: ScheduleEvent.self) }
                self?.allEvents = events
                self?.groupEventsByPerson(events)
            }
    }
    
    // Fetch Group Details (members + code)
    func fetchGroupDetails() {
        guard !currentGroupID.isEmpty else { return }
        
        groupListener = db.collection("groups").document(currentGroupID)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let data = snapshot?.data() else { return }
                
                DispatchQueue.main.async {
                    // Update Members List
                    if let members = data["members"] as? [String] {
                        self?.roommates = members
                    }
                    // Update Group Name
                    if let name = data["name"] as? String {
                        self?.groupNameLabel = name
                    }
                    // Update Invite Code
                    if let code = data["code"] as? String {
                        self?.groupCodeLabel = code
                    }
                }
            }
    }
    
    func addEvent(_ event: ScheduleEvent) {
        guard !currentGroupID.isEmpty else { return }
        do {
            try db.collection("groups").document(currentGroupID).collection("events")
                .document(event.id.uuidString)
                .setData(from: event)
        } catch { print("Error adding event: \(error)") }
    }
    
    private func groupEventsByPerson(_ events: [ScheduleEvent]) {
        let grouped = Dictionary(grouping: events, by: { $0.createdBy })
        self.roommateSchedules = grouped.map { (name, userEvents) in
            RoommateSchedule(name: name, events: userEvents)
        }.sorted { $0.name < $1.name }
    }
    
    // UI Helpers
    
    var greetingMessage: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let timeOfDay: String
        switch hour {
        case 5..<12: timeOfDay = "Good morning"
        case 12..<17: timeOfDay = "Good afternoon"
        case 17..<22: timeOfDay = "Good evening"
        default: timeOfDay = "Good night"
        }
        return "\(timeOfDay), \(profileName)!"
    }
    
    func getEventsForDate(_ date: Date) -> [ScheduleEvent] {
        let calendar = Calendar.current
        return allEvents.filter { event in
            calendar.isDate(event.startTime, inSameDayAs: date)
        }.sorted { $0.startTime < $1.startTime }
    }
    
    private func setupCurrentWeek() {
        let calendar = Calendar.current
        let today = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        
        currentWeek = (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek)
        }
    }
    
    func showAddEvent() { showingAddEvent = true }
}
