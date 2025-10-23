//
//  NoteDetailView.swift
//  RoomMatey
//
//  Created by Ian Quack on 10/20/25.
//


import SwiftUI

struct NoteDetailView: View {
    @Environment(\.dismiss) private var dismiss
    
    let note: BulletinNote
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // Header with note color and severity
                HStack {
                    VStack(alignment: .leading) {
                        Text("Subject")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(note.subject)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("Severity")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        HStack {
                            Circle()
                                .fill(note.severity.color)
                                .frame(width: 12, height: 12)
                            Text(note.severity.rawValue)
                                .fontWeight(.medium)
                        }
                    }
                }
                .padding()
                .background(note.color.color.opacity(0.3))
                .cornerRadius(12)
                
                // Content
                VStack(alignment: .leading, spacing: 8) {
                    Text("Content")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    ScrollView {
                        Text(note.content)
                            .font(.body)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                
                Spacer()
                
                // Note info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.secondary)
                        Text("Created: \(Date().formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "paintbrush")
                            .foregroundColor(.secondary)
                        Text("Color: \(note.color.rawValue.capitalized)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top)
            }
            .padding()
            .navigationTitle("Note Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NoteDetailView(note: BulletinNote(
        subject: "Sample Note",
        content: "This is a sample note content that demonstrates how the detail view will look when displaying note information.",
        severity: .high
    ))
}