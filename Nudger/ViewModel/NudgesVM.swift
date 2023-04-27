//
//  NudgesVM.swift
//  Nudger
//
//  Created by Tobias Sörensson on 2023-04-23.
//

import Foundation
import Firebase

class NudgesVM: ObservableObject {
    @Published var nudges = [Nudge]()
    @Published var date = Date()
    let db = Firestore.firestore()
    let auth = Auth.auth()
    @Published var currentNudges = [Nudge]()
    
    
    func setDone(nudge: Nudge) {
        guard let user = auth.currentUser else {return}
        let nudgeRef = db.collection("users").document(user.uid).collection("nudges")

        if let id = nudge.id {
            if let latestDone = nudge.doneDates.last {
                if !Calendar.current.isDate(latestDone, equalTo: Date(), toGranularity: .day) {
                    nudgeRef.document(id).updateData(["doneDates" : FieldValue.arrayUnion([Date()])])
                    return // Added missing return statement
                } else {
                    // Here i should add code for removing the last Date object for the list. Tricky, since Firebase doesn't save
                    // them in the same format as Swift uses. If I get this to work, change func name to 'toggleDone'.
                    return
                }
            }
            nudgeRef.document(id).updateData(["doneDates" : FieldValue.arrayUnion([Date()])])
        }
    }
    
    
    func saveToFirestore(nudgeName: String, description: String, dateCreated: Date) {
        guard let user = auth.currentUser else {return}
        let nudgeRef = db.collection("users").document(user.uid).collection("nudges")
        
        let nudge = Nudge(name: nudgeName, description: description, dateCreated: dateCreated)
        do {
            let _ = try nudgeRef.addDocument(from: nudge)
        } catch {
            print("Error saving to db.\(error)")
        }
    }
    
    
    func checkStreak() {
        
    }
    
    func deleteDate(date: Date, nudgeRef: CollectionReference) {
        // Easier said than done!
    }
    
    
    func deleteFromFirestore(index: Int) {
        
        guard let user = auth.currentUser else {return}
        let nudgeRef = db.collection("users").document(user.uid).collection("nudges")
        let nudge = nudges[index]
        
        if let id = nudge.id {
            nudgeRef.document(id).delete()
        }
    }
    
    func setCurrentNudges(date: Date) {
        currentNudges = []
        
        for nudge in nudges {
            // If the nudge should be triggered today, add it to currentNudges
            if Calendar.current.isDate(nudge.dateCreated, equalTo: date, toGranularity: .day) {
                currentNudges.append(nudge)
            }
        
            
//            if date == nudge.dateCreated {
//                currentNudges.append(nudge)
//            }
        }
        print("\(currentNudges.count)")
        
    }
    
    
    func listenToFirestore() {
        guard let user = auth.currentUser else {return}
        let nudgeRef = db.collection("users").document(user.uid).collection("nudges")
        
        nudgeRef.addSnapshotListener() {
            snapshot, err in
            
            guard let snapshot = snapshot else {return}
            
            if let err = err {
                print("Error getting document \(err)")
            } else {
                self.nudges.removeAll()
                for document in snapshot.documents {
                    do {
                        let nudge = try document.data(as: Nudge.self)
                        self.nudges.append(nudge)
                    } catch {
                        print("Error generating list \(error)")
                    }
                }
                self.setCurrentNudges(date: self.date)
                print(self.nudges)
            }
        }
    }
}

