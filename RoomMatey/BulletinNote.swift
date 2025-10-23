//
//  BulletinNote.swift
//  RoomMatey
//
//  Created by Ian Quack on 10/20/25.
//

import Foundation
import SwiftUI

struct BulletinNote: Identifiable, Codable {
    let id: UUID
    var subject: String
    var content: String
    var severity: NoteSeverity
    var position: CGPoint
    var color: NoteColor
    
    init(subject: String, content: String, severity: NoteSeverity, position: CGPoint = CGPoint(x: 100, y: 100)) {
        self.id = UUID()
        self.subject = subject
        self.content = content
        self.severity = severity
        self.position = position
        self.color = NoteColor.random()
    }
}

enum NoteSeverity: String, CaseIterable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case urgent = "Urgent"
    
    var color: Color {
        switch self {
        case .low:
            return .green
        case .medium:
            return .yellow
        case .high:
            return .orange
        case .urgent:
            return .red
        }
    }
}

enum NoteColor: String, CaseIterable, Codable {
    case yellow = "yellow"
    case pink = "pink"
    case blue = "blue"
    case green = "green"
    case purple = "purple"
    
    static func random() -> NoteColor {
        return NoteColor.allCases.randomElement() ?? .yellow
    }
    
    var color: Color {
        switch self {
        case .yellow:
            return .yellow
        case .pink:
            return .pink
        case .blue:
            return .blue
        case .green:
            return .green
        case .purple:
            return .purple
        }
    }
}
