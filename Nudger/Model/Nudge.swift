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

    
    //Alt. 1:
    var streak: Int = 1
    //var latestDone: Date
    //var nextDate: Date // Kanske bra att ha....?
       
    //Alt. 2:
    //1: Kolla om dagens datum finns:
    //  om inte: -> lägg till
    //  annars: -> gör ingenting (eller ta bort, så att man kan ångra feltryckning)
    
    // Hur hantera streaks?
    // Sätt streak till 1
    //  Varje gång ett datum läggs till:
    //      Iterera baklänges genom listan. Jämför datumet med föregående datum.
    //          Om datumet är ett mindre, lägg till ett till streak.
    //          Om skillnaden är större, bryt loopen
    
    //Kanske blir det enklare ändå om jag använder en dictionary? Då kan jag toggla Date: Bool till true eller false.
    var doneDates: [Date] = []
    
    // Alt. 3: Kombinera 1 och två:
    //  Använd alt. 1 men ha en lista som i alt 2.
    
    //------------------maybe later------------------------------------------------------------------------------
    //Each day of the week holds an Int which represent how many times that day the user will be Nudged. Not used
    // at the moment! Should be two weeks, to enable every other day as an option.
    var frequency: [String: Int] = ["monday": 0,
                                     "tuesday": 0,
                                     "wednesday": 0,
                                     "thursday": 0,
                                     "friday": 0,
                                     "saturday": 0,
                                     "sunday": 0]
    
    //var notifications:
    //var done: Bool = false
    
   
}
