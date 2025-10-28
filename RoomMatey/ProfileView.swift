//
//  ProfileView.swift
//  RoomMatey
//
//  Created by Ian Quack on 10/20/25.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    @AppStorage("profileName") var profileName: String = ""
    @AppStorage("groupName") var groupName: String = ""
    @AppStorage("profileImageData") var profileImageData: Data?
    @AppStorage("isAuthenticated") var isAuthenticated: Bool = false
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false

    @State private var newName: String = ""
    @State private var showingCopiedAlert = false
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var showingShareSheet = false

    var inviteLink: String {
        "roommatey://join/\(groupName.replacingOccurrences(of: " ", with: "%20"))"
    }

    func resetAllData() {
        profileName = ""
        groupName = ""
        profileImageData = nil
        isAuthenticated = false
        hasCompletedOnboarding = false
    }

    var body: some View {
        NavigationView {
            ScrollView {
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
                    // Profile Section
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

                    // Group Section
                    GroupBox {
                        VStack(alignment: .leading, spacing: 16) {
                            Label("Group", systemImage: "person.3.fill")
                                .font(.headline)
                                .foregroundColor(.blue)
                            
                            Text("Current Group: \(groupName)")
                                .font(.subheadline)
                            
                            Button(action: {
                                groupName = ""
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

                    // Invite Section
                    GroupBox {
                        VStack(alignment: .leading, spacing: 16) {
                            Label("Invite to Group", systemImage: "link")
                                .font(.headline)
                                .foregroundColor(.blue)
                            
                            HStack(spacing: 12) {
                                Button(action: {
//                                    UIPasteboard.general.string = inviteLink
                                    showingCopiedAlert = true
                                }) {
                                    HStack {
                                        Image(systemName: "doc.on.doc")
                                        Text("Copy Link")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                }
                                
                                Button(action: {
                                    showingShareSheet = true
                                }) {
                                    HStack {
                                        Image(systemName: "message.fill")
                                        Text("Send Link")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }

                    // Reset Section
                    GroupBox {
                        VStack(alignment: .leading, spacing: 16) {
                            Label("Reset", systemImage: "arrow.uturn.left")
                                .font(.headline)
                                .foregroundColor(.blue)
                            
                            Button(action: {
                                resetAllData()
                            }) {
                                Text("Reset All Data")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(Color.red.opacity(0.1))
                                    .foregroundColor(.red)
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
            }
            .onChange(of: selectedItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        profileImageData = data
                    }
                }
            }
            .alert("Link Copied!", isPresented: $showingCopiedAlert) {
                Button("OK", role: .cancel) { }
            }
//            .sheet(isPresented: $showingShareSheet) {
//                if let url = URL(string: inviteLink) {
//                    ShareSheet(items: [url])
//                }
//            }
        }
    }
}

//struct ShareSheet: UIViewControllerRepresentable {
//    let items: [Any]
//    
//    func makeUIViewController(context: Context) -> UIActivityViewController {
//        UIActivityViewController(activityItems: items, applicationActivities: nil)
//    }
//    
//    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
//}

struct AuthenticationView: View {
    @AppStorage("isAuthenticated") var isAuthenticated: Bool = false
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    func signOut() {
        isAuthenticated = false
        hasCompletedOnboarding = false
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Logo and Welcome Text
                VStack(spacing: 16) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                        .symbolEffect(.bounce, options: .repeating)
                    
                    Text("Welcome to RoomMatey")
                        .font(.largeTitle)
                        .bold()
                    
                    Text("Your ultimate roommate companion")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.top, 40)
                
                // Authentication Form
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
                        // Simulate authentication
                        if email.isEmpty || password.isEmpty {
                            errorMessage = "Please fill in all fields"
                            showingError = true
                        } else {
                            isAuthenticated = true
                        }
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
                
                // Add sign out button
                Button(action: signOut) {
                    Text("Sign Out")
                        .foregroundColor(.red)
                }
                .padding(.top)
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
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
                        profileName = inputName.trimmingCharacters(in: .whitespaces)
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
    @State private var newGroupName = ""
    @State private var showingCopiedAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                        .symbolEffect(.bounce, options: .repeating)
                    
                    Text("Create New Group")
                        .font(.title)
                        .bold()
                    
                    Text("Give your group a name to get started")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                // Form
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Group Name")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        TextField("Enter group name", text: $newGroupName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.title3)
                    }
                    
                    Button(action: {
                        groupName = newGroupName.trimmingCharacters(in: .whitespaces)
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Create Group")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 2)
                    }
                    .disabled(newGroupName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct JoinGroupView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var groupName: String
    @State private var inviteCode = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "person.badge.plus.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                        .symbolEffect(.bounce, options: .repeating)
                    
                    Text("Join Existing Group")
                        .font(.title)
                        .bold()
                    
                    Text("Enter the invite code to join your group")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                // Form
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Invite Code")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        TextField("Enter invite code", text: $inviteCode)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.title3)
                            .autocapitalization(.none)
                            .textInputAutocapitalization(.never)
                    }
                    
                    Button(action: {
                        if inviteCode.isEmpty {
                            showingError = true
                        } else {
                            groupName = "Test Group" // For demo purposes
                            dismiss()
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.circle.fill")
                            Text("Join Group")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: .green.opacity(0.3), radius: 5, x: 0, y: 2)
                    }
                    .disabled(inviteCode.isEmpty)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please enter a valid invite code")
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
