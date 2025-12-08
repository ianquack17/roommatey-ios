//
//  ProfileView.swift
//  RoomMatey
//
//  Created by Ian Quack on 10/20/25.
//

import SwiftUI
import PhotosUI
import FirebaseAuth
import FirebaseFirestore

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    
    @AppStorage("profileName") var profileName: String = ""
    @AppStorage("groupName") var groupName: String = ""
    @AppStorage("groupID") var groupID: String = ""
    @AppStorage("profileImageData") var profileImageData: Data?
    
    @State private var newName: String = ""
    @State private var showingCopiedAlert = false
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var groupInviteCode: String = "Loading..."
    
    var body: some View {
        NavigationView {
            ScrollView {
                // Header Image
                GeometryReader { geo in
                    let offset = max(-geo.frame(in: .global).minY, 0)
                    let scale = max(1 - (offset / 500), 0.7)
                    let opacity = max(1 - (offset / 200), 0.8)
                    let yOffset = min(offset * 0.5, 100)

                    VStack(spacing: 8) {
                        if let data = profileImageData, let image = UIImage(data: data) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150 * scale, height: 150 * scale)
                                .clipShape(Circle())
                                .opacity(opacity)
                                .offset(y: yOffset)
                        } else {
                            Image(systemName: "person.crop.circle")
                                .resizable()
                                .frame(width: 150 * scale, height: 150 * scale)
                                .foregroundColor(.gray)
                                .opacity(opacity)
                                .offset(y: yOffset)
                        }

                        PhotosPicker("Tap to change photo", selection: $selectedItem, matching: .images)
                            .font(.caption)
                            .opacity(opacity)
                            .offset(y: yOffset)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 24)
                }
                .frame(height: 200)

                VStack(spacing: 20) {
                    // Profile Name
                    GroupBox {
                        VStack(alignment: .leading, spacing: 16) {
                            Label("Profile", systemImage: "person.fill")
                                .font(.headline)
                                .foregroundColor(.blue)
                            
                            TextField("Change Name", text: $newName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button(action: {
                                profileName = newName.trimmingCharacters(in: .whitespaces)
                            }) {
                                Text("Update Name")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                        .padding(.vertical, 8)
                    }

                    // Group Management
                    GroupBox {
                        VStack(alignment: .leading, spacing: 16) {
                            Label("Group", systemImage: "person.3.fill")
                                .font(.headline)
                                .foregroundColor(.blue)
                            
                            Text("Current Group: \(groupName)")
                                .font(.subheadline)
                            
                            Button(action: {
                                groupName = ""
                                groupID = ""
                            }) {
                                Text("Leave Group")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(Color.red.opacity(0.1))
                                    .foregroundColor(.red)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.vertical, 8)
                    }

                    // Invite section (fix the copy button)
                    GroupBox {
                        VStack(alignment: .center, spacing: 16) {
                            HStack {
                                Label("Invite Roommates", systemImage: "link")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                Spacer()
                            }
                            
                            VStack(spacing: 8) {
                                Text("Share this code with your roommates:")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Text(groupInviteCode)
                                    .font(.system(size: 32, weight: .heavy, design: .monospaced))
                                    .foregroundColor(.primary)
                                    .padding(.vertical, 4)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                            
                            Button(action: {
                                // Fix this to actually copy the update code...
                                // UIPasteboard.general.string = groupInviteCode
                                showingCopiedAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "doc.on.doc")
                                    Text("Copy Code")
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                        }
                        .padding(.vertical, 8)
                    }

                    // Sign Out
                    GroupBox {
                        VStack(alignment: .leading, spacing: 16) {
                            Label("Account", systemImage: "rectangle.portrait.and.arrow.right")
                                .font(.headline)
                                .foregroundColor(.red)
                            
                            Button(action: {
                                appState.authenticationViewModel.signOut()
                            }) {
                                Text("Sign Out")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                .padding()
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                newName = profileName
                fetchGroupCode() // Fetch the code when view appears
            }
            .onChange(of: selectedItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        profileImageData = data
                    }
                }
            }
            .alert("Code Copied!", isPresented: $showingCopiedAlert) {
                Button("OK", role: .cancel) { }
            }
        }
    }
    
    private func fetchGroupCode() {
        guard !groupID.isEmpty else { return }
        
        let db = Firestore.firestore()
        db.collection("groups").document(groupID).getDocument { snapshot, error in
            if let data = snapshot?.data(), let code = data["code"] as? String {
                DispatchQueue.main.async {
                    self.groupInviteCode = code
                }
            }
        }
    }
}

struct AuthenticationView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                        .symbolEffect(.bounce, options: .repeating)
                    
                    Text("Welcome to RoomMatey")
                        .font(.largeTitle)
                        .bold()
                }
                .padding(.top, 40)
                
                // Form
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(isSignUp ? .newPassword : .password)
                    
                    Button(action: {
                        // Call the Real Firebase Auth
                        viewModel.authenticate(email: email, password: password, isSignUp: isSignUp)
                    }) {
                        Text(isSignUp ? "Create Account" : "Sign In")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        withAnimation {
                            isSignUp.toggle()
                        }
                    }) {
                        Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .alert("Error", isPresented: $viewModel.showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

struct ProfileSetupView: View {
    @AppStorage("profileName") var profileName: String = ""
    @AppStorage("profileImageData") var profileImageData: Data?
    @State private var inputName = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var showingImagePicker = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Profile Picture Section
                VStack(spacing: 16) {
                    if let data = profileImageData, let image = UIImage(data: data) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.blue, lineWidth: 2)
                            )
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.gray)
                            .overlay(
                                Circle()
                                    .stroke(Color.blue, lineWidth: 2)
                            )
                    }
                    
                    PhotosPicker("Choose Profile Picture", selection: $selectedItem, matching: .images)
                        .buttonStyle(.bordered)
                }
                .padding(.top, 40)
                
                // Name Input Section
                VStack(spacing: 16) {
                    Text("What should we call you?")
                        .font(.title2)
                        .bold()
                    
                    TextField("Enter your name", text: $inputName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    Button(action: {
                        let finalName = inputName.trimmingCharacters(in: .whitespaces)
                                            
                        // Save Locally
                        profileName = finalName
                                            
                        // Save to Firestore Cloud
                        if let uid = Auth.auth().currentUser?.uid {
                            Firestore.firestore().collection("users").document(uid).setData([
                                "name": finalName
                            ], merge: true)
                        }
                    }) {
                        Text("Continue")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(inputName.trimmingCharacters(in: .whitespaces).isEmpty)
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .onChange(of: selectedItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        profileImageData = data
                    }
                }
            }
        }
    }
}

struct GroupSetupView: View {
    @AppStorage("groupName") var groupName: String = ""
    @AppStorage("profileName") var profileName: String = ""
    @State private var showingCreateGroup = false
    @State private var showingJoinGroup = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Welcome Section
                VStack(spacing: 16) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                        .symbolEffect(.bounce, options: .repeating)
                    
                    Text("Let's Get You Connected")
                        .font(.title)
                        .bold()
                    
                    Text("Join or create a group to start managing your shared space")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 40)
                
                // Action Buttons
                VStack(spacing: 16) {
                    Button(action: {
                        showingCreateGroup = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Create New Group")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 2)
                    }
                    
                    Button(action: {
                        showingJoinGroup = true
                    }) {
                        HStack {
                            Image(systemName: "person.badge.plus.fill")
                            Text("Join Existing Group")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: .green.opacity(0.3), radius: 5, x: 0, y: 2)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .sheet(isPresented: $showingCreateGroup) {
                CreateGroupView(groupName: $groupName)
            }
            .sheet(isPresented: $showingJoinGroup) {
                JoinGroupView(groupName: $groupName)
            }
        }
    }
}

struct CreateGroupView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var groupName: String
    
    @AppStorage("groupID") var groupID: String = ""
    @AppStorage("profileName") var profileName: String = ""
    
    @State private var newGroupName = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header Icon
                Image(systemName: "house.lodge.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                    .padding(.top, 20)
                
                Text("Name Your Household")
                    .font(.title2)
                    .bold()
                
                // Styled Input Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("GROUP NAME")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                    
                    TextField("e.g. Apt 4B, The Castle, etc.", text: $newGroupName)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Big Action Button
                if isLoading {
                    ProgressView()
                } else {
                    Button(action: {
                        isLoading = true
                        FirebaseManager.shared.createGroup(groupName: newGroupName, userName: profileName) { newGroupID in
                            isLoading = false
                            if let id = newGroupID {
                                groupName = newGroupName
                                groupID = id
                                dismiss()
                            }
                        }
                    }) {
                        Text("Create Group")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                            .shadow(radius: 2)
                    }
                    .padding(.horizontal)
                    .disabled(newGroupName.trimmingCharacters(in: .whitespaces).isEmpty)
                    .opacity(newGroupName.trimmingCharacters(in: .whitespaces).isEmpty ? 0.6 : 1.0)
                }
            }
            .padding(.bottom, 20)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

struct JoinGroupView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var groupName: String
    
    @AppStorage("groupID") var groupID: String = ""
    @AppStorage("profileName") var profileName: String = ""
    
    @State private var inviteCode = ""
    @State private var showingError = false
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header Icon
                Image(systemName: "person.3.sequence.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                    .padding(.top, 20)
                
                Text("Join a Household")
                    .font(.title2)
                    .bold()
                
                Text("Enter the 5-character code from your roommate.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Styled Input Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("INVITE CODE")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                    
                    TextField("X7Y2Z", text: $inviteCode)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        .textInputAutocapitalization(.characters) // Force caps for invite code
                        .disableAutocorrection(true)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Big Action Button
                if isLoading {
                    ProgressView()
                } else {
                    Button(action: {
                        isLoading = true
                        FirebaseManager.shared.joinGroup(inviteCode: inviteCode.uppercased(), userName: profileName) { id, name in
                            isLoading = false
                            if let id = id, let name = name {
                                groupID = id
                                groupName = name
                                dismiss()
                            } else {
                                showingError = true
                            }
                        }
                    }) {
                        Text("Join Group")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(12)
                            .shadow(radius: 2)
                    }
                    .padding(.horizontal)
                    .disabled(inviteCode.isEmpty)
                    .opacity(inviteCode.isEmpty ? 0.6 : 1.0)
                }
            }
            .padding(.bottom, 20)
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Could not find a group with that code.")
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @AppStorage("profileName") var profileName: String = ""
    @AppStorage("groupName") var groupName: String = ""
    @AppStorage("isAuthenticated") var isAuthenticated: Bool = false
    @AppStorage("profileImageData") var profileImageData: Data?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to RoomMatey")
                .font(.largeTitle)
                .bold()
            
            Text("Let's get started with a fresh setup")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Button(action: {
                // Reset all stored values
                profileName = ""
                groupName = ""
                isAuthenticated = false
                profileImageData = nil
                hasCompletedOnboarding = true
            }) {
                Text("Start Fresh")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}
