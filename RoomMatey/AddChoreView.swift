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
    @ObservedObject var viewModel: ChoresViewModel
    
    @State private var task = ""
    @State private var description = ""
    @State private var frequency: ChoreFrequency = .weekly
    @State private var selectedRoommates: [String] = []
    
    @AppStorage("profileName") var profileName: String = ""

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
                
                Section("Assign To (Who rotates?)") {
                    if viewModel.roommates.isEmpty {
                        Text("Loading roommates...")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(viewModel.roommates, id: \.self) { roommate in
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
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively) // fix keyboard getting stuck
            .navigationTitle("New Chore")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
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
                        viewModel.addChore(newChore)
                        dismiss()
                    }
                    .disabled(task.isEmpty || description.isEmpty || selectedRoommates.isEmpty)
                }
            }
            .onAppear {
                viewModel.fetchRoommates()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if selectedRoommates.isEmpty {
                        selectedRoommates = viewModel.roommates
                    }
                }
            }
        }
    }
}

struct ChoreDetailView: View {
    let chore: Chore
    @ObservedObject var viewModel: ChoresViewModel
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
                    
                    HStack {
                        Text("Next Up")
                        Spacer()
                        Text(chore.nextPerson)
                            .bold()
                            .foregroundColor(chore.nextPerson == profileName ? .blue : .primary)
                    }
                    
                    if let lastCompleted = chore.lastCompleted {
                        LabeledContent("Last Completed", value: lastCompleted.formatted(date: .abbreviated, time: .shortened))
                    }
                }
                
                Section("Assigned To") {
                    ForEach(chore.assignedTo, id: \.self) { person in
                        HStack {
                            Text(person)
                            Spacer()
                            if person == chore.nextPerson {
                                Text("Next")
                                    .font(.caption)
                                    .padding(4)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(4)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                
                Section {
                    Button(action: {
                        viewModel.markChoreComplete(chore)
                        dismiss()
                    }) {
                        HStack {
                            Spacer()
                            Text("Mark as Complete")
                                .bold()
                            Spacer()
                        }
                    }
                    .foregroundColor(.white)
                    .listRowBackground(Color.blue)
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
