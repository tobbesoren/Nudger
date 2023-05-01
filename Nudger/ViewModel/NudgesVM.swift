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
        //It seems like it is possible to set done for different dates now.
        // Need to make it possible to toggle.

        guard let user = auth.currentUser else {return}
        let nudgeRef = db.collection("users").document(user.uid).collection("nudges")
        
        let calendar = Calendar.current
        if let id = nudge.id {
            if nudge.doneDates.contains(where: { calendar.isDate($0, inSameDayAs: date) }) {
                return
            }
            // If the date isn't set, set it!
            nudgeRef.document(id).updateData(["doneDates" : FieldValue.arrayUnion([self.date])])
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
        // Should return the streak up to (the day before?) the selected day. The ability to setDone to
        // past dates will complicate things.
    }
    
    func deleteDate(date: Date, nudgeRef: CollectionReference) {
        // Easier said than done!
        // Not needed if I go for the dictionary.
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let user = auth.currentUser else {return}
        let nudgeRef = db.collection("users").document(user.uid).collection("nudges")
        
        let calendar = Calendar.current
        
        for nudge in nudges {
            
            // Sets all nudges created before or at this date to currentNudges.
            // Converts dates to String to be able to compare them.
            // Maybe I could do this without the recasting, but not a priority right now.
            let dateCreatedString = dateFormatter.string(from: nudge.dateCreated)
            let setDateString = dateFormatter.string(from: date)
            
            if dateCreatedString <= setDateString {
                currentNudges.append(nudge)
                
                // For some reason, only if I update firestore will my rowViews update the button image in nudgesView/rowView.
                // That's why I have this code here. VERY frustrating!!!
                if let id = nudge.id {
                    if nudge.doneDates.contains(where: { calendar.isDate($0, inSameDayAs: date) }) {
                        print("Ohoj")
                        nudgeRef.document(id).updateData(["doneThisDay" : true])
                    } else {
                        nudgeRef.document(id).updateData(["doneThisDay" : false])
                    }
                }
            }
        }
    }
    
    
    func listenToFirestore() {
        guard let user = auth.currentUser else {return}
        let nudgeRef = db.collection("users").document(user.uid).collection("nudges")
        
        nudgeRef.addSnapshotListener() {
            snapshot, error in
            
            guard let snapshot = snapshot else {return}
            
            if let error = error {
                print("Error getting document \(error)")
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
                //print(self.nudges)
            }
        }
    }
}

