# roommatey-ios

**Developer:** Ian Quack
**Focus Area:** Native iOS (SwiftUi)
**Course:** Mobile Application Development CIS 357

[**Presentation Link**](https://docs.google.com/presentation/d/1sMG2BYdOMhbvv_JzcqInbTDzRY4ZJnAOQ_oIhIDovmo/edit?usp=drivesdk)

## 1. Overview
RoomMatey is a iOS application designed to solve the issues of living with a large group under one household.

**Key Features:**
* **Live Bulletin Board:** An interactive notes tab that resembles a cork board that syncs the position of the notes between multiple devices.
* **Smart Chores:** A chores management system that will automatically switch assignment to the next roommate when completed.
* **Shared Grocery List**: A live updating list of items to buy at the grocery store.
* **Home Dashboard:** A Dashboard to see what your roommates are up to and their schedule.

## 2. Getting started

To run this project locally, you will need the following environment:

* **IDE:** Xcode 15 or later.
* **iOS:** iOS 26.0 or later Sim/Device
* **Dependencies:** 'firebase-ios-sdk' via Swift Package Manager

### Installation:
1. Clone the repo
2. Verify that 'GoogleService-Info.plist' is in the root directory
3. Build and run the project.

## 3. Tutorial:
The biggest technical challenge was managing the state across different users instantly. Here is a breakdown of who the project handles real-time data synchronization using the MVVM patter discussed in class.

### Step A:
I used a centralized 'AppState' class injected into the environment. This allows any view in the app to access the current authentication state without passing data down manually.

```swift
// RoomMateyApp.swift
@main
struct RoomMateyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var appState = AppState() // The "Brain" of the app

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState) // Injected into the view hierarchy
        }
    }
}
```

### Step B: The Backend Manager
Instead of putting database calls inside the Views, we use a FirebaseManager file to handle most of the logic, such as creating groups and generating invite codes.

```swift
// FirebaseManager.swift
class FirebaseManager {
    static let shared = FirebaseManager()
    
    func createGroup(groupName: String, userName: String, completion: @escaping (String?) -> Void) {
        let code = generateInviteCode() // Generates a unique 5-digit code
        // Saves to Firestore 'groups' collection...
    }
}
```

### Step C: The Interactive Bulletin Board
The most complex UI feature is the Bulletin Board. It uses GeometryReader to find coordinates and DragGesture to update the positions in real-time.

The Logic:
1. User drags a note.
2. onEnded gesture triggers a Firestore update with new X/Y coordinates.
3. Firestore pushes the change to all other devices instantly.

```swift
// PostItNoteView.swift
.gesture(
    DragGesture()
        .onChanged { value in
            // Update local UI for smoothness
        }
        .onEnded { value in
            // Sync final position to Cloud
            viewModel.updateNotePosition(note.id, newPosition)
        }
)
```

### Step D: Smart Chore Rotation
I utilized Codable structs to map Firestore documents directly to the Swift objects. The rotation logic ensures chores are distributed fairly.

```swift
func markChoreComplete(_ chore: Chore) {
    // Find current index
    if let currentIndex = chore.assignedTo.firstIndex(of: chore.nextPerson) {
        // Calculate next index (Round Robin)
        let nextIndex = (currentIndex + 1) % chore.assignedTo.count
        updatedChore.nextPerson = chore.assignedTo[nextIndex]
    }
    // Update Firestore
    updateChore(updatedChore)
}
```

## 4. Conclusion & Future Improvements
This project demonstrates that SwiftUI combined with Firestore is a powerful stack for building reactive applications. By using SnapshotListeners, we avoided the need for manual "refresh" buttons which I thought was nice.

### Future Improvements:
1. Push Notifications: Alerting users when a chore is complete or a new activity has beeen made.
2. Expense Splitting: Integrating a payment API to split bills within the app.
3. Dark Mode: Further refining the UI for different appearance modes.

## 5. References
[SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
[Firebase Firestore for iOS](https://firebase.google.com/docs/firestore/quickstart)
[MVVM Design Pattern in iOS](https://developer.apple.com/library/archive/documentation/General/Conceptual/DevPedia-CocoaCore/Model-View-Controller.html)

