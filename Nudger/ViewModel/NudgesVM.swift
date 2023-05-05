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
    //@Published var currentNudges = [Nudge]()
    
    
    func toggleDoneThisDay(nudge: Nudge) {

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
            loadNudgesFromFirestore()
        }
    }
    
    
    func saveToFirestore(nudgeName: String, dateCreated: Date, reminderTime: String) {
        guard let user = auth.currentUser else {return}
        let nudgeRef = db.collection("users").document(user.uid).collection("nudges")
        
        let nudge = Nudge(name: nudgeName, dateCreated: dateCreated, reminderTime: reminderTime)
        do {
            let _ = try nudgeRef.addDocument(from: nudge) {_ in
                self.loadNudgesFromFirestore()
            }
        } catch {
            print("Error saving to db.\(error)")
        }
    }
    
    
    func deleteFromFirestore(index: Int) {
        
        guard let user = auth.currentUser else {return}
        let nudgeRef = db.collection("users").document(user.uid).collection("nudges")
        let nudge = nudges[index]
        
        if let id = nudge.id {
            nudgeRef.document(id).delete()
            loadNudgesFromFirestore()
        }
    }
    
    
    func getDateRange(selectedDate: Date, range: String) -> [Date] {
        
        let calendar = Calendar(identifier: .iso8601)
        var startDate = Date()
        var endDate = Date()
        
        
        enum TimePeriod: String, CaseIterable, Identifiable {
            case week, month, year
            var id: Self { self }
        }
        
        switch range {
        case "month":
      
            let interval = calendar.dateInterval(of: .month, for: selectedDate)
            startDate = interval?.start ?? Date()
            endDate = interval?.end ?? Date()
            

        case "year":
           
            let interval = calendar.dateInterval(of: .year, for: selectedDate)
            startDate = interval?.start ?? Date()
            endDate = interval?.end ?? Date()
   
        default:
          
            let interval = calendar.dateInterval(of: .weekOfYear, for: selectedDate)
            startDate = interval?.start ?? Date()
            endDate = interval?.end ?? Date()
            
        }
       
        return [startDate, endDate]
    }
    
    
    
    func getNudgesRangeFromFirestore(to: Date) {
        
        guard let user = auth.currentUser else {return}
        let nudgeRef = db.collection("users").document(user.uid).collection("nudges")
       
        let dateQuery = nudgeRef
            //.whereField("dateCreated", isGreaterThanOrEqualTo: from)
            .whereField("dateCreated", isLessThan: to)
        
        //var nudges: [Nudge] = []
       
        
        dateQuery.getDocuments() {
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
                        //print(nudge)
                    } catch {
                        print("Error generating list \(error)")
                    }
                }
                
            }
        }
        return
    }
    
    
    func loadNudgesFromFirestore() {
        // So, the dates are acting up. Seems date isn't using the correct timezone. When changing date, the nudges created the selected
        // day don't show up. However, when first starting the app, they show. Frustrating!
        guard let user = auth.currentUser else {return}
        let nudgeRef = db.collection("users").document(user.uid).collection("nudges")
        //guard let rawDate = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: date)) else {return}
        let dateQuery = nudgeRef.whereField("dateCreated", isLessThanOrEqualTo: date)
        //print(date)
        //print(rawDate)
        
        dateQuery.getDocuments() {
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
                
            }
        }
    }
}

