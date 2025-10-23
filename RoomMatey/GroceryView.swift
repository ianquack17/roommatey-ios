//
//  GroceryView.swift
//  RoomMatey
//
//  Created by Ian Quack on 10/20/25.
//

import SwiftUI

struct GroceryItem: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var quantity: String
    var addedBy: String
    var isPurchased: Bool = false
    var assignedTo: String?
}

struct GroceryView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = GroceryViewModel()

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.groceries) { item in
                    GroceryItemRow(item: item, viewModel: viewModel)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                withAnimation {
                                    viewModel.deleteItem(item)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
            .navigationTitle("Grocery List")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { 
                        viewModel.showAddItem()
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingAddItem) {
                AddGroceryItemView(viewModel: viewModel)
            }
        }
    }
}

struct GroceryItemRow: View {
    let item: GroceryItem
    let viewModel: GroceryViewModel
    @State private var isShowingAssignment = false
    
    var body: some View {
        HStack {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    viewModel.togglePurchaseStatus(for: item)
                }
            }) {
                Image(systemName: item.isPurchased ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(item.isPurchased ? .green : .gray)
                    .symbolEffect(.bounce, value: item.isPurchased)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .strikethrough(item.isPurchased)
                
                HStack {
                    Text("Qty: \(item.quantity)")
                    Text("•")
                    Text("Added by: \(item.addedBy)")
                    if let assignedTo = item.assignedTo {
                        Text("•")
                        Text("Assigned to: \(assignedTo)")
                            .foregroundColor(.blue)
                    }
                }
                .font(.caption)
                .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: {
                isShowingAssignment = true
            }) {
                Image(systemName: "person.crop.circle.badge.plus")
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .confirmationDialog("Assign to", isPresented: $isShowingAssignment) {
            Button("Unassign") {
                viewModel.assignItem(item, to: nil)
            }
            
            ForEach(viewModel.availableRoommates, id: \.self) { roommate in
                Button(roommate) {
                    viewModel.assignItem(item, to: roommate)
                }
            }
            
            Button("Cancel", role: .cancel) { }
        }
    }
}

struct AddGroceryItemView: View {
    @Environment(\.dismiss) var dismiss
    let viewModel: GroceryViewModel
    @State private var name = ""
    @State private var quantity = ""
    @State private var assignedTo: String?

    var body: some View {
        NavigationView {
            Form {
                Section("Item Details") {
                    TextField("Item Name", text: $name)
                    TextField("Quantity", text: $quantity)
                }
                
                Section("Assign To") {
                    Picker("Assign To", selection: $assignedTo) {
                        Text("No Assignment").tag(nil as String?)
                        ForEach(viewModel.availableRoommates, id: \.self) { roommate in
                            Text(roommate).tag(roommate as String?)
                        }
                    }
                }
            }
            .navigationTitle("Add Grocery Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let newItem = GroceryItem(
                            name: name,
                            quantity: quantity,
                            addedBy: viewModel.profileName,
                            assignedTo: assignedTo
                        )
                        viewModel.addGroceryItem(newItem)
                        dismiss()
                    }
                    .disabled(name.isEmpty || quantity.isEmpty)
                }
            }
        }
    }
}
