//
//  HomeView.swift
//  RoomMatey
//
//  Created by Ian Quack on 10/20/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    groupHeaderSection
                    roommateListSection
                    greetingSection
                    calendarSection
                    eventsListSection
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.showAddEvent() }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingAddEvent) {
                AddEventView(viewModel: viewModel)
            }
        }
    }
    
    // Sub-Views
    
    private var groupHeaderSection: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(viewModel.groupNameLabel)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    private var roommateListSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(viewModel.roommates, id: \.self) { person in
                    VStack {
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Text(String(person.prefix(1))) // First letter of user
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.blue)
                            )
                        Text(person)
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var greetingSection: some View {
        Text(viewModel.greetingMessage)
            .font(.largeTitle)
            .fontWeight(.bold)
            .padding(.horizontal)
            .padding(.top, 10)
    }
    
    private var calendarSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            MonthCalendarView()
        }
        .padding(.bottom)
    }
    
    private var eventsListSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !viewModel.roommateSchedules.isEmpty {
                Text("Upcoming Events")
                    .font(.headline)
                    .padding(.horizontal)
                
                ForEach(viewModel.roommateSchedules) { schedule in
                    VStack(alignment: .leading) {
                        Text(schedule.name)
                            .font(.caption)
                            .bold()
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(schedule.events) { event in
                                    VStack(alignment: .leading) {
                                        Text(event.title)
                                            .font(.caption)
                                            .bold()
                                        Text(event.startTime.formatted(date: .omitted, time: .shortened))
                                            .font(.caption2)
                                    }
                                    .padding(8)
                                    .background(Color(hex: event.color)?.opacity(0.2) ?? Color.blue.opacity(0.2))
                                    .cornerRadius(8)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 8)
                }
            }
        }
    }
}

// Helper views!
struct AddEventView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: HomeViewModel
    @State private var title = ""
    @State private var startTime = Date()
    @State private var endTime = Date().addingTimeInterval(3600)
    @State private var selectedColor = "#007AFF"
    let colors = ["#007AFF", "#FF9500", "#34C759", "#AF52DE", "#FF3B30"]
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Event Title", text: $title)
                DatePicker("Start", selection: $startTime)
                DatePicker("End", selection: $endTime)
                Section("Color") {
                    HStack {
                        ForEach(colors, id: \.self) { colorHex in
                            Circle().fill(Color(hex: colorHex) ?? .blue).frame(width: 30, height: 30)
                                .overlay(Circle().stroke(Color.primary, lineWidth: selectedColor == colorHex ? 2 : 0))
                                .onTapGesture { selectedColor = colorHex }
                        }
                    }
                }
            }
            .navigationTitle("Add Event")
            .toolbar {
                Button("Cancel") { dismiss() }
                Button("Add") {
                    let newEvent = ScheduleEvent(title: title, startTime: startTime, endTime: endTime, color: selectedColor, isAllDay: false, createdBy: viewModel.profileName)
                    viewModel.addEvent(newEvent)
                    dismiss()
                }
                .disabled(title.isEmpty)
            }
        }
    }
}

struct DayView: View {
    let date: Date
    let viewModel: HomeViewModel
    private var isToday: Bool { Calendar.current.isDateInToday(date) }
    private var dayNumber: String { let f = DateFormatter(); f.dateFormat = "d"; return f.string(from: date) }
    private var dayName: String { let f = DateFormatter(); f.dateFormat = "E"; return f.string(from: date) }
    var body: some View {
        VStack(spacing: 4) {
            Text(dayName).font(.caption).fontWeight(.medium).foregroundColor(.secondary)
            Text(dayNumber).font(.title2).fontWeight(isToday ? .bold : .regular).foregroundColor(isToday ? .white : .primary).frame(width: 32, height: 32).background(Circle().fill(isToday ? Color.blue : Color.clear))
            VStack(spacing: 2) {
                ForEach(Array(viewModel.getEventsForDate(date).prefix(3)), id: \.id) { event in EventDotView(event: event) }
            }
        }
        .frame(maxWidth: .infinity).padding(.vertical, 8).background(RoundedRectangle(cornerRadius: 8).fill(isToday ? Color.blue.opacity(0.1) : Color.clear))
    }
}

struct EventDotView: View {
    let event: ScheduleEvent
    var color: Color { Color(hex: event.color) ?? .blue }
    var body: some View { HStack(spacing: 4) { Circle().fill(color).frame(width: 6, height: 6); Text(event.title).font(.caption2).lineLimit(1).foregroundColor(.primary) } }
}

extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: return nil
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue:  Double(b) / 255, opacity: Double(a) / 255)
    }
}
