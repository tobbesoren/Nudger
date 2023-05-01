//
//  Nudge.swift
//  Nudger
//
//  Created by Tobias Sörensson on 2023-04-23.
//

import Foundation
import FirebaseFirestoreSwift

struct Nudge: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var description: String
    var dateCreated: Date
    var streak: Int = 0
    var doneDates: [Date] = []
    
    // I don't want to use this, bur whatever...
    var doneThisDay = false
}
