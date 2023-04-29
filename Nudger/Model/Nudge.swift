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
    // Kanske skall ha ett endDate också? Så att nudge:en finns kvar även efter att man avslutat påminnelser etc.
    // Så att man kan se historiken.
    //var endDate: Date

    
    //Alt. 1:
    var streak: Int = 0
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
    
    //Som det är nu så är det möjligt att lägga till nudges i efterhand. Om man också skall kunna bocka för dem i efterhand
    // så funkar det inte med en array eftersom datumen inte nödvändigtvis kommer i ordning.
    //Kanske blir det enklare ändå om jag använder en dictionary? Då kan jag toggla Date: Bool till true eller false.
    //Kanske skall jag i så fall låta key vara en Int? Milliseconds since etc... Borde vara enklare att kolla efter en viss key då,
    // funkar nog inte att ha en Date som key... Aaarggh. Eller vänta, har vi det lokalt så borde det ju gå! Hmmm
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
