//
//  MonthCalendarView.swift
//  RoomMatey
//
//  Created by Ian Quack on 10/28/25.
//

import SwiftUI

struct MonthCalendarView: View {
    @State private var visibleMonth: Date = Date() // today by default
    private let calendar = Calendar.current
    private let weekdaySymbols = Calendar.current.shortWeekdaySymbols

    // hardcoded events
    private let demoEvents: Set<Date> = {
        let cal = Calendar.current
        func d(_ y:Int,_ m:Int,_ day:Int) -> Date { cal.date(from: DateComponents(year: y, month: m, day: day))! }
        let today = Date()
        let comps = cal.dateComponents([.year, .month], from: today)
        let y = comps.year!, m = comps.month!
        return [d(y,m,3), d(y,m,10), d(y,m,17), d(y,m,24)]
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header

            // Weekday row
            HStack {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol.uppercased())
                        .font(.caption2).fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            let days = monthGrid(for: visibleMonth)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7), spacing: 6) {
                ForEach(days, id: \.self) { day in
                    DayCell(day: day,
                            isToday: isToday(day),
                            hasEvent: day.flatMap(startOfDay) .map { demoEvents.contains($0) } ?? false)
                        .frame(minHeight: 40)
                }
            }
            .padding(.vertical, 4)
        }
        .padding(.horizontal)
    }

    // MARK: - Header
    private var header: some View {
        HStack {
            Button {
                withAnimation {
                    visibleMonth = calendar.date(byAdding: .month, value: -1, to: visibleMonth)!
                }
            } label: {
                Image(systemName: "chevron.left")
            }

            Spacer()

            Text(monthTitle(for: visibleMonth))
                .font(.title3).fontWeight(.semibold)

            Spacer()

            Button {
                withAnimation {
                    visibleMonth = calendar.date(byAdding: .month, value: +1, to: visibleMonth)!
                }
            } label: {
                Image(systemName: "chevron.right")
            }
        }
    }

    // MARK: - Helpers
    /// A day in the grid; `nil` means a blank placeholder cell.
    private func monthGrid(for month: Date) -> [Date?] {
        let start = startOfMonth(month)
        let daysIn = calendar.range(of: .day, in: .month, for: start)!.count
        let firstWeekdayIndex = (calendar.component(.weekday, from: start) - calendar.firstWeekday + 7) % 7

        var grid: [Date?] = Array(repeating: nil, count: firstWeekdayIndex)
        for day in 1...daysIn {
            grid.append(calendar.date(byAdding: .day, value: day - 1, to: start)!)
        }
        while grid.count % 7 != 0 { grid.append(nil) }
        while grid.count < 42 { grid.append(nil) }
        return grid
    }

    private func isToday(_ day: Date?) -> Bool {
        guard let d = day else { return false }
        return calendar.isDateInToday(d)
    }

    private func startOfMonth(_ date: Date) -> Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
    }

    private func startOfDay(_ date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    private func monthTitle(for date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "LLLL yyyy"
        return f.string(from: date)
    }
}

private struct DayCell: View {
    let day: Date?
    let isToday: Bool
    let hasEvent: Bool

    var body: some View {
        ZStack {
            // background for today
            RoundedRectangle(cornerRadius: 8)
                .fill(isToday ? Color.blue.opacity(0.12) : .clear)

            if let day {
                VStack(spacing: 6) {
                    Text(Self.dayNumberString(day))
                        .font(isToday ? .body.weight(.bold) : .body)
                        .foregroundStyle(isToday ? .blue : .primary)
                    Circle()
                        .frame(width: 6, height: 6)
                        .opacity(hasEvent ? 1 : 0)
                }
                .padding(.vertical, 6)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 40)
        .aspectRatio(1, contentMode: .fit)
    }

    private static func dayNumberString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "d"
        return f.string(from: date)
    }
}
