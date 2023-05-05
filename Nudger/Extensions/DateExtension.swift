//
//  DateExtension.swift
//  Nudger
//
//  Created by Tobias Sörensson on 2023-05-05.
//

import Foundation

// this way, we can easily get yesterday's date. Used by checkStreak() in Nudge.
extension Date {
    var yesterday: Date {
            return Calendar.current.date(byAdding: .day, value: -1, to: self)!
        }
}
