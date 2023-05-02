//
//  NudgesVM.swift
//  Nudger
//
//  Created by Tobias Sörensson on 2023-04-23.
//

import Foundation
import Firebase

// this way, we can easily get yesterday's date. Used by checkStreak.
extension Date {
    var yesterday: Date {
            return Calendar.current.date(byAdding: .day, value: -1, to: self)!
        }
}


class NudgesVM: ObservableObject {
    @Published var nudges = [Nudge]()
    @Published var date = Date()
    let db = Firestore.firestore()
    let auth = Auth.auth()
    @Published var currentNudges = [Nudge]()
    
    
    func setDone(nudge: Nudge) {
        //It seems like it is possible to set done for different dates now.
        // Now it is possible to toggle, but I need to figure out a way
        // to update firestore without calling functions multiple times. I seem to have set up
        // some kind of ring. When this function updates firestore,
        // snapShotlistener is triggered and calls setCurrentNudges, which updates firestore again...

        guard let user = auth.currentUser else {return}
        let nudgeRef = db.collection("users").document(user.uid).collection("nudges")
        
        let calendar = Calendar.current
        
        var doneDates = nudge.doneDates
        
        if let id = nudge.id {
            if nudge.doneDates.contains(where: { calendar.isDate($0, inSameDayAs: date) }) {
                let dateToDelete = nudge.doneDates.first(where: {calendar.isDate($0, inSameDayAs: date)})
                doneDates.removeAll{ $0 == dateToDelete }
                
            } else {
                // Append new date and sort list before updating firestore. We want those dates in order!
                
                doneDates.append(date)
                doneDates.sort()
            }
            nudgeRef.document(id).updateData(["doneDates" : doneDates])
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
    
    func checkStreak(nudge: Nudge) -> Int {
        // Return the streak up to (the day before) and/or the CURRENT day, an Int. This means the streak won't
        // be resetted until tomorrow; you have the entire day to finish the task.
        // At the moment, it IS possible to select days in the future and set Done for those days.
        // Those future Done days will not be counted until we reach the days in question.
        
        // I'm thinking this function could also set the color of the tasks: Maybe green for tasks done today;
        // yellow for tasks with a streak over 1 but not yet done today;
        // and red or orange (or maybe the less aggressive blue) for tasks with a streak of 0.
        var checkNext = true
        var currentStreak = 0
        let calendar = Calendar.current

        var yesterday = Date().yesterday
        
        while checkNext {
            if nudge.doneDates.contains(where: { calendar.isDate($0, inSameDayAs: yesterday) }) {
                yesterday = yesterday.yesterday
                currentStreak += 1
            } else {
                checkNext = false
            }
        }
        if nudge.doneDates.contains(where: { calendar.isDate($0, inSameDayAs: Date()) }) {
            currentStreak += 1
        }
        
        print("\(nudge.name) \(currentStreak)")
        return currentStreak
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

        for nudge in nudges {
            
            // Sets all nudges created before or at this date to currentNudges.
            // Converts dates to String to be able to compare them.
            // Maybe I could do this without the recasting, but not a priority right now.
            let dateCreatedString = dateFormatter.string(from: nudge.dateCreated)
            let setDateString = dateFormatter.string(from: date)
            
            if dateCreatedString <= setDateString {
                currentNudges.append(nudge)
                // Checks streak and updates firestore
                let streak = checkStreak(nudge: nudge)
                if let id = nudge.id {
                   nudgeRef.document(id).updateData(["streak" : streak])
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

