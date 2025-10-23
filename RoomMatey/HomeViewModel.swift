//
//  HomeViewModel.swift
//  RoomMatey
//
//  Created by Ian Quack on 10/20/25.
//

import Foundation
import Combine

struct RoommateSchedule: Identifiable, Codable {
    let id = UUID()
    let name: String
    let events: [ScheduleEvent]
}

struct ScheduleEvent: Identifiable, Codable {
    let id = UUID()
    let title: String
    let startTime: Date
    let endTime: Date
    let color: String // Hex color string
    let isAllDay: Bool
}

class HomeViewModel: ObservableObject {
    @Published var currentUser: String = ""
    @Published var roommateSchedules: [RoommateSchedule] = []
    @Published var currentWeek: [Date] = []
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadUserData()
        setupCurrentWeek()
        setupHardcodedSchedules()
    }
    
    var greetingMessage: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let timeOfDay: String
        
        switch hour {
        case 5..<12:
            timeOfDay = "Good morning"
        case 12..<17:
            timeOfDay = "Good afternoon"
        case 17..<22:
            timeOfDay = "Good evening"
        default:
            timeOfDay = "Good night"
        }
        
        return "\(timeOfDay), \(currentUser.isEmpty ? "Roommate" : currentUser)!"
    }
    
    func getEventsForDate(_ date: Date) -> [ScheduleEvent] {
        let calendar = Calendar.current
        var events: [ScheduleEvent] = []
        
        for schedule in roommateSchedules {
            for event in schedule.events {
                if calendar.isDate(event.startTime, inSameDayAs: date) {
                    events.append(event)
                }
            }
        }
        
        return events.sorted { $0.startTime < $1.startTime }
    }
    
    func getRoommatesForEvent(_ event: ScheduleEvent) -> [String] {
        var roommates: [String] = []
        
        for schedule in roommateSchedules {
            if schedule.events.contains(where: { $0.id == event.id }) {
                roommates.append(schedule.name)
            }
        }
        
        return roommates
    }
    
    private func loadUserData() {
        currentUser = userDefaults.string(forKey: "profileName") ?? ""
    }
    
    private func setupCurrentWeek() {
        let calendar = Calendar.current
        let today = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        
        currentWeek = (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek)
        }
    }
    
    private func setupHardcodedSchedules() {
        let calendar = Calendar.current
        let today = Date()
        
        // Alex's schedule
        let alexEvents = [
            ScheduleEvent(
                title: "Work",
                startTime: calendar.date(bySettingHour: 9, minute: 0, second: 0, of: today) ?? today,
                endTime: calendar.date(bySettingHour: 17, minute: 0, second: 0, of: today) ?? today,
                color: "#007AFF",
                isAllDay: false
            ),
            ScheduleEvent(
                title: "Gym",
                startTime: calendar.date(bySettingHour: 18, minute: 30, second: 0, of: today) ?? today,
                endTime: calendar.date(bySettingHour: 20, minute: 0, second: 0, of: today) ?? today,
                color: "#FF9500",
                isAllDay: false
            )
        ]
        
        // Sam's schedule
        let samEvents = [
            ScheduleEvent(
                title: "Classes",
                startTime: calendar.date(bySettingHour: 10, minute: 0, second: 0, of: today) ?? today,
                endTime: calendar.date(bySettingHour: 15, minute: 0, second: 0, of: today) ?? today,
                color: "#34C759",
                isAllDay: false
            ),
            ScheduleEvent(
                title: "Study Group",
                startTime: calendar.date(bySettingHour: 19, minute: 0, second: 0, of: today) ?? today,
                endTime: calendar.date(bySettingHour: 21, minute: 0, second: 0, of: today) ?? today,
                color: "#AF52DE",
                isAllDay: false
            )
        ]
        
        // Current user's schedule
        let userEvents = [
            ScheduleEvent(
                title: "Remote Work",
                startTime: calendar.date(bySettingHour: 8, minute: 30, second: 0, of: today) ?? today,
                endTime: calendar.date(bySettingHour: 16, minute: 30, second: 0, of: today) ?? today,
                color: "#FF3B30",
                isAllDay: false
            ),
            ScheduleEvent(
                title: "Dinner with Friends",
                startTime: calendar.date(bySettingHour: 19, minute: 30, second: 0, of: today) ?? today,
                endTime: calendar.date(bySettingHour: 22, minute: 0, second: 0, of: today) ?? today,
                color: "#FF2D92",
                isAllDay: false
            )
        ]
        
        roommateSchedules = [
            RoommateSchedule(name: "Alex", events: alexEvents),
            RoommateSchedule(name: "Sam", events: samEvents),
            RoommateSchedule(name: currentUser.isEmpty ? "You" : currentUser, events: userEvents)
        ]
    }
}
