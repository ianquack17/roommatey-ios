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
                    // Greeting Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text(viewModel.greetingMessage)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Here's what's happening this week")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Monthly Calendar
                    VStack(alignment: .leading, spacing: 12) {
                        MonthCalendarView()
                    }
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct DayView: View {
    let date: Date
    let viewModel: HomeViewModel
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(dayName)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text(dayNumber)
                .font(.title2)
                .fontWeight(isToday ? .bold : .regular)
                .foregroundColor(isToday ? .white : .primary)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(isToday ? Color.blue : Color.clear)
                )
            
            // Events for this day
            VStack(spacing: 2) {
                ForEach(Array(viewModel.getEventsForDate(date).prefix(3)), id: \.id) { event in
                    EventDotView(event: event, viewModel: viewModel)
                }
                
                if viewModel.getEventsForDate(date).count > 3 {
                    Text("+\(viewModel.getEventsForDate(date).count - 3)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isToday ? Color.blue.opacity(0.1) : Color.clear)
        )
    }
}

struct EventDotView: View {
    let event: ScheduleEvent
    let viewModel: HomeViewModel
    
    private var color: Color {
        Color(hex: event.color) ?? .blue
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            
            Text(event.title)
                .font(.caption2)
                .lineLimit(1)
                .foregroundColor(.primary)
        }
    }
}

// Extension to create Color from hex string
extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
