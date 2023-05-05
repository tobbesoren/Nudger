//
//  Nudge.swift
//  Nudger
//
//  Created by Tobias Sörensson on 2023-04-23.
//

import Foundation
import FirebaseFirestoreSwift

struct Nudge: Codable, Identifiable, Equatable {
    
    @DocumentID var id: String?
    var name: String
    var dateCreated: Date
    var doneDates: [Date] = []
    var reminderTime: String
   
    
    func getDoneInDateRange(from: Date, to: Date) -> Int {
        
        var counter = 0
        
        for date in doneDates {
            if date >= from && date <= to {
                counter += 1
            }
        }
        return counter
    }
    
    
    func getStreak() -> Int {
        var checkNext = true
        var currentStreak = 0
        let calendar = Calendar.current
        var yesterday = Date().yesterday
        
        if dateCreated > Date() {
            return 0
        }
        
        while checkNext {
            if doneDates.contains(where: { calendar.isDate($0, inSameDayAs: yesterday) }) {
                yesterday = yesterday.yesterday
                currentStreak += 1
            } else {
                checkNext = false
            }
        }
        
        if doneDates.contains(where: { calendar.isDate($0, inSameDayAs: Date()) }) {
            currentStreak += 1
        }
        return currentStreak
    }
    
    
    func getDoneThisDay(date: Date) -> Bool {
        let doneThisDay  = doneDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: date) })
        return doneThisDay
    }
}
