//
//  AddBulletinNoteView.swift
//  RoomMatey
//
//  Created by Ian Quack on 10/20/25.
//

import SwiftUI

struct AddBulletinNoteView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var subject = ""
    @State private var content = ""
    @State private var selectedSeverity: NoteSeverity = .medium
    
    let onSave: (BulletinNote) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Note Details")) {
                    TextField("Subject", text: $subject)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    VStack(alignment: .leading) {
                        Text("Content")
                            .font(.headline)
                        TextEditor(text: $content)
                            .frame(minHeight: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
                
                Section(header: Text("Severity")) {
                    Picker("Severity", selection: $selectedSeverity) {
                        ForEach(NoteSeverity.allCases, id: \.self) { severity in
                            HStack {
                                Circle()
                                    .fill(severity.color)
                                    .frame(width: 12, height: 12)
                                Text(severity.rawValue)
                            }
                            .tag(severity)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                }
                
                Section {
                    HStack {
                        Spacer()
                        Text("Preview")
                            .font(.headline)
                        Spacer()
                    }
                    
                    // Preview of the note
                    VStack(alignment: .leading, spacing: 4) {
                        Text(subject.isEmpty ? "Subject" : subject)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .lineLimit(2)
                        
                        Spacer()
                        
                        HStack {
                            Circle()
                                .fill(selectedSeverity.color)
                                .frame(width: 8, height: 8)
                            Text(selectedSeverity.rawValue)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    }
                    .padding(12)
                    .frame(width: 120, height: 120)
                    .background(Color.yellow)
                    .cornerRadius(8)
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 1, y: 1)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("New Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveNote()
                    }
                    .disabled(subject.isEmpty || content.isEmpty)
                }
            }
        }
    }
    
    private func saveNote() {
        let newNote = BulletinNote(
            subject: subject,
            content: content,
            severity: selectedSeverity,
            position: CGPoint(
                x: CGFloat.random(in: 50...300),
                y: CGFloat.random(in: 100...500)
            )
        )
        onSave(newNote)
        dismiss()
    }
}

#Preview {
    AddBulletinNoteView { _ in }
}
