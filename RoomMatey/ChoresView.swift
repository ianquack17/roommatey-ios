//
//  ChoresView.swift
//  RoomMatey
//
//  Created by Ian Quack on 10/20/25.
//

import SwiftUI

struct ChoresView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = ChoresViewModel()

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.chores) { chore in
                    Button(action: {
                        viewModel.selectChore(chore)
                    }) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(chore.task)
                                    .font(.headline)
                                Spacer()
                                Text(chore.frequency.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Text(chore.description)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .lineLimit(2)
                            
                            HStack {
                                Image(systemName: "person.fill")
                                Text("Done by \(chore.doneBy)")
                                Spacer()
                                Image(systemName: "arrow.right")
                                Text("Next: \(chore.nextPerson)")
                            }
                            .font(.caption)
                            .foregroundColor(.gray)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        viewModel.deleteChore(viewModel.chores[index])
                    }
                }
            }
            .navigationTitle("Chores")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.showAddChore()
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingAddChore) {
                AddChoreView(viewModel: viewModel)
            }
            .sheet(item: $viewModel.selectedChore) { chore in
                ChoreDetailView(chore: chore, viewModel: viewModel)
            }
        }
    }
}
