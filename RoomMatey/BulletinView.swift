//
//  BulletinView.swift
//  RoomMatey
//
//  Created by Ian Quack on 10/20/25.
//

import SwiftUI
internal import UniformTypeIdentifiers

struct BulletinView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = BulletinViewModel()
    
    var body: some View {
        ZStack {
            // Background
            Color.gray.opacity(0.1)
                .ignoresSafeArea()
            
            // Bulletin board
            GeometryReader { geometry in
                ZStack {
                    // Cork board texture background
                    Rectangle()
                        .fill(Color.brown.opacity(0.3))
                        .overlay(
                            Rectangle()
                                .stroke(Color.brown, lineWidth: 2)
                        )
                    
                    // Notes
                    ForEach(viewModel.notes) { note in
                        PostItNoteView(
                            note: note,
                            onTap: {
                                viewModel.selectNote(note)
                            },
                            onDrag: { newPosition in
                                viewModel.updateNotePosition(note.id, newPosition)
                            },
                            onDragStart: {
                                viewModel.startDrag(note)
                            },
                            onDragEnd: {
                                viewModel.endDrag()
                            },
                            onDelete: {
                                viewModel.deleteNote(note.id)
                            }
                        )
                    }
                    
                    // Delete zone (X icon)
                    if viewModel.showingDeleteZone {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                ZStack {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 60, height: 60)
                                    Image(systemName: "xmark")
                                        .foregroundColor(.white)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                }
                                .padding(.trailing, 20)
                                .padding(.bottom, 20)
                            }
                        }
                    }
                }
            }
            
            // Add note button
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        viewModel.showAddNote()
                    }) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 3)
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 20)
                }
                Spacer()
            }
        }
        .sheet(isPresented: $viewModel.showingAddNote) {
            AddBulletinNoteView { newNote in
                viewModel.addNote(newNote)
            }
        }
        .sheet(isPresented: $viewModel.showingNoteDetail) {
            if let note = viewModel.selectedNote {
                NoteDetailView(note: note)
            }
        }
        .onDrop(of: [.text], delegate: DeleteDropDelegate(
            onDrop: { location in
                return viewModel.handleDrop(at: location)
            }
        ))
    }
}

struct PostItNoteView: View {
    let note: BulletinNote
    let onTap: () -> Void
    let onDrag: (CGPoint) -> Void
    let onDragStart: () -> Void
    let onDragEnd: () -> Void
    let onDelete: () -> Void
    
    @State private var dragOffset = CGSize.zero
    @State private var isDragging = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(note.subject)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .lineLimit(2)
            
            Spacer()
            
            // Severity indicator
            HStack {
                Circle()
                    .fill(note.severity.color)
                    .frame(width: 8, height: 8)
                Text(note.severity.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .padding(12)
        .frame(width: 120, height: 120)
        .background(note.color.color)
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.2), radius: 2, x: 1, y: 1)
        .position(
            x: note.position.x + dragOffset.width,
            y: note.position.y + dragOffset.height
        )
        .scaleEffect(isDragging ? 1.1 : 1.0)
        .rotationEffect(.degrees(isDragging ? Double.random(in: -2...2) : 0))
        .onTapGesture {
            onTap()
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    if !isDragging {
                        isDragging = true
                        onDragStart()
                    }
                    dragOffset = value.translation
                }
                .onEnded { value in
                    let newPosition = CGPoint(
                        x: note.position.x + value.translation.width,
                        y: note.position.y + value.translation.height
                    )
                    
                    // Check if dropped in delete zone (bottom-right corner)
                    let screenWidth = UIScreen.main.bounds.width
                    let screenHeight = UIScreen.main.bounds.height
                    let deleteZoneX = screenWidth - 80
                    let deleteZoneY = screenHeight - 80
                    
                    if newPosition.x > deleteZoneX && newPosition.y > deleteZoneY {
                        // Note is in delete zone - trigger delete
                        onDelete()
                        return // Don't update position if deleting
                    }
                    
                    onDrag(newPosition)
                    dragOffset = .zero
                    isDragging = false
                    onDragEnd()
                }
        )
    }
}

struct DeleteDropDelegate: DropDelegate {
    let onDrop: (CGPoint) -> Bool
    
    func performDrop(info: DropInfo) -> Bool {
        return onDrop(info.location)
    }
}

#Preview {
    BulletinView()
}
