	//
//  AddChoreView.swift
//  RoomMatey
//
//  Created by Ian Quack on 10/20/25.
//

import SwiftUI

struct Chore: Identifiable, Codable {
    var id: UUID = UUID()
    var task: String
    var doneBy: String
    var date: Date
    var nextPerson: String
    var frequency: ChoreFrequency
    var description: String
    var lastCompleted: Date?
    var assignedTo: [String]
}

enum ChoreFrequency: String, Codable, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case biweekly = "Bi-weekly"
    case monthly = "Monthly"
    case custom = "Custom"
}

struct AddChoreView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var chores: [Chore]
    @State private var task = ""
    @State private var description = ""
    @State private var frequency: ChoreFrequency = .weekly
    @State private var selectedRoommates: [String] = []
    @AppStorage("profileName") var profileName: String = ""
    @AppStorage("groupName") var groupName: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section("Chore Details") {
                    TextField("Task Name", text: $task)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    Picker("Frequency", selection: $frequency) {
                        ForEach(ChoreFrequency.allCases, id: \.self) { freq in
                            Text(freq.rawValue).tag(freq)
                        }
                    }
                }
                
                Section("Assign To") {
                    if groupName == "Test Group" {
                        ForEach(["Alex", "Sam", profileName], id: \.self) { roommate in
                            Button(action: {
                                if selectedRoommates.contains(roommate) {
                                    selectedRoommates.removeAll { $0 == roommate }
                                } else {
                                    selectedRoommates.append(roommate)
                                }
                            }) {
                                HStack {
                                    Text(roommate)
                                    Spacer()
                                    if selectedRoommates.contains(roommate) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    } else {
                        Text(profileName)
                            .onAppear {
                                selectedRoommates = [profileName]
                            }
                    }
                }
            }
            .navigationTitle("New Chore")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let newChore = Chore(
                            task: task,
                            doneBy: profileName,
                            date: Date(),
                            nextPerson: selectedRoommates.first ?? profileName,
                            frequency: frequency,
                            description: description,
                            assignedTo: selectedRoommates
                        )
                        chores.append(newChore)
                        dismiss()
                    }
                    .disabled(task.isEmpty || description.isEmpty || selectedRoommates.isEmpty)
                }
            }
        }
    }
}

struct ChoreDetailView: View {
    let chore: Chore
    @Binding var chores: [Chore]
    @Environment(\.dismiss) var dismiss
    @AppStorage("profileName") var profileName: String = ""
    
    var body: some View {
        NavigationView {
            List {
                Section("Details") {
                    LabeledContent("Task", value: chore.task)
                    LabeledContent("Frequency", value: chore.frequency.rawValue)
                    LabeledContent("Description", value: chore.description)
                }
                
                Section("Status") {
                    LabeledContent("Last Done By", value: chore.doneBy)
                    LabeledContent("Next Up", value: chore.nextPerson)
                    if let lastCompleted = chore.lastCompleted {
                        LabeledContent("Last Completed", value: lastCompleted.formatted(date: .abbreviated, time: .shortened))
                    }
                }
                
                Section("Assigned To") {
                    ForEach(chore.assignedTo, id: \.self) { person in
                        HStack {
                            Text(person)
                            if person == chore.nextPerson {
                                Image(systemName: "arrow.right")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                
                if chore.nextPerson == profileName {
                    Section {
                        Button("Mark as Complete") {
                            if let index = chores.firstIndex(where: { $0.id == chore.id }) {
                                var updatedChore = chore
                                updatedChore.doneBy = profileName
                                updatedChore.lastCompleted = Date()
                                
                                // Find next person in rotation
                                if let currentIndex = chore.assignedTo.firstIndex(of: profileName) {
                                    let nextIndex = (currentIndex + 1) % chore.assignedTo.count
                                    updatedChore.nextPerson = chore.assignedTo[nextIndex]
                                }
                                
                                chores[index] = updatedChore
                                dismiss()
                            }
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("Chore Details")
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
