	//
//  AddChoreView.swift
//  RoomMatey
//
//  Created by Ian Quack on 10/20/25.
//

import SwiftUI
import FirebaseFirestore

// Chore struct for firebase
struct Chore: Identifiable, Codable {
    let id: UUID
    var task: String
    var doneBy: String
    var date: Date
    var nextPerson: String
    var frequency: ChoreFrequency
    var description: String
    var lastCompleted: Date?
    var assignedTo: [String]
    
    // init to help with creation of chore
    init(id: UUID = UUID(), task: String, doneBy: String, date: Date, nextPerson: String, frequency: ChoreFrequency, description: String, lastCompleted: Date? = nil, assignedTo: [String]) {
        self.id = id
        self.task = task
        self.doneBy = doneBy
        self.date = date
        self.nextPerson = nextPerson
        self.frequency = frequency
        self.description = description
        self.lastCompleted = lastCompleted
        self.assignedTo = assignedTo
    }
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
    @ObservedObject var viewModel: ChoresViewModel // Access the database logic
    
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
                    HStack {
                        Text(profileName)
                        Spacer()
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                    .onAppear {
                        if selectedRoommates.isEmpty {
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
                        // call database function
                        viewModel.addChore(newChore)
                        dismiss()
                    }
                    .disabled(task.isEmpty || description.isEmpty)
                }
            }
        }
    }
}

struct ChoreDetailView: View {
    let chore: Chore
    @ObservedObject var viewModel: ChoresViewModel // Access the database logic
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
                            // CRITICAL: Call the database function!
                            viewModel.markChoreComplete(chore)
                            dismiss()
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
