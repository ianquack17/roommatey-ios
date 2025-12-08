//
//  BulletinNote.swift
//  RoomMatey
//
//  Created by Ian Quack on 10/20/25.
//

import Foundation
import SwiftUI
import FirebaseFirestore

struct BulletinNote: Identifiable, Codable {
    let id: UUID
    var subject: String
    var content: String
    var severity: NoteSeverity
    var position: CGPoint
    var color: NoteColor
    
    // Keys to help Firestore
    enum CodingKeys: String, CodingKey {
        case id, subject, content, severity, position, color
    }
    
    // Handle CGPoint in firebase
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        subject = try container.decode(String.self, forKey: .subject)
        content = try container.decode(String.self, forKey: .content)
        severity = try container.decode(NoteSeverity.self, forKey: .severity)
        color = try container.decode(NoteColor.self, forKey: .color)
        
        // Decode CGPoint from a dictionary {x: 1, y: 2}
        let posDict = try container.decode([String: CGFloat].self, forKey: .position)
        position = CGPoint(x: posDict["x"] ?? 100, y: posDict["y"] ?? 100)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(subject, forKey: .subject)
        try container.encode(content, forKey: .content)
        try container.encode(severity, forKey: .severity)
        try container.encode(color, forKey: .color)
        
        // Encode CGPoint as dictionary
        try container.encode(["x": position.x, "y": position.y], forKey: .position)
    }
    
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
        case .low: return .green
        case .medium: return .yellow
        case .high: return .orange
        case .urgent: return .red
        }
    }
}

enum NoteColor: String, CaseIterable, Codable {
    case yellow, pink, blue, green, purple
    
    static func random() -> NoteColor {
        return NoteColor.allCases.randomElement() ?? .yellow
    }
    
    var color: Color {
        switch self {
        case .yellow: return .yellow
        case .pink: return .pink
        case .blue: return .blue
        case .green: return .green
        case .purple: return .purple
        }
    }
}
