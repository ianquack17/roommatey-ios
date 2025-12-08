//
//  FirebaseManager.swift
//  RoomMatey
//
//  Created by Ian Quack on 11/15/25.
//


import Foundation
import FirebaseFirestore
import FirebaseAuth

class FirebaseManager {
    static let shared = FirebaseManager()
    let db = Firestore.firestore()
    
    // Create a Household
    func createGroup(groupName: String, userName: String, completion: @escaping (String?) -> Void) {
        let code = generateInviteCode()
        let groupId = UUID().uuidString
        
        let groupData: [String: Any] = [
            "id": groupId,
            "name": groupName,
            "code": code,
            "members": [userName],
            "dateCreated": Timestamp()
        ]
        
        // Save to Firestore 'groups' collection
        db.collection("groups").document(groupId).setData(groupData) { error in
            if let error = error {
                print("Error creating group: \(error)")
                completion(nil)
            } else {
                self.updateUserRecord(groupID: groupId)
                completion(groupId)
            }
        }
    }
    
    // Join a Household
    func joinGroup(inviteCode: String, userName: String, completion: @escaping (String?, String?) -> Void) {
        // Code to query for the group
        db.collection("groups").whereField("code", isEqualTo: inviteCode).getDocuments { snapshot, error in
            guard let document = snapshot?.documents.first, error == nil else {
                print("No group found or error: \(String(describing: error))")
                completion(nil, nil)
                return
            }
            
            let groupId = document.documentID
            let groupName = document.data()["name"] as? String ?? ""
            
            // Update the members array
            self.db.collection("groups").document(groupId).updateData([
                "members": FieldValue.arrayUnion([userName])
            ]) { err in
                if let err = err {
                    print("Error joining: \(err)")
                    completion(nil, nil)
                } else {
                    self.updateUserRecord(groupID: groupId)
                    completion(groupId, groupName)
                }
            }
        }
    }
    
    // Helper: 5 Character Code for joining groups
    private func generateInviteCode() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<5).map { _ in letters.randomElement()! })
        
        func updateUserRecord(groupID: String) {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            // Save the group ID to the USER'S document
            db.collection("users").document(uid).setData([
                "groupID": groupID
            ], merge: true)
        }
    }
    
    func updateUserRecord(groupID: String) {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            // Save the group ID to the USER'S document
            db.collection("users").document(uid).setData([
                "groupID": groupID
            ], merge: true)
        }
}
