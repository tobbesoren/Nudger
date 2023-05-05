//
//  StatisticView.swift
//  Nudger
//
//  Created by Tobias Sörensson on 2023-05-05.
//

import SwiftUI

struct StatisticView: View {
    
    @ObservedObject var nudgesVM: NudgesVM
    @State var selectedTimePeriod: TimePeriod = .week
    @State var selectedDate: Date = Date()
    @Binding var showStatistics: Bool
    
    @State var dateRange: [Date] = [Date(), Date()]
    @State var calendar = Calendar(identifier: .iso8601)
    
    
    enum TimePeriod: String, CaseIterable, Identifiable {
        case week, month, year
        var id: Self { self }
    }
    
    
    
    var body: some View {
        NavigationView {
            VStack {
                
                HStack {
                        DatePicker("Choose date:", selection: $selectedDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .padding()
                    }
                    Picker("Time period:", selection: $selectedTimePeriod) {
                        Text("This Week").tag(TimePeriod.week)
                        Text("This Month").tag(TimePeriod.month)
                        Text("This Year").tag(TimePeriod.year)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    .onAppear {
                        dateRange = nudgesVM.getDateRange(selectedDate: selectedDate, range: selectedTimePeriod.rawValue)
                        nudgesVM.getNudgesRangeFromFirestore(to: dateRange[1])
                    }
                    .onChange(of: selectedTimePeriod) { _ in
                        dateRange = nudgesVM.getDateRange(selectedDate: selectedDate, range: selectedTimePeriod.rawValue)
                        nudgesVM.getNudgesRangeFromFirestore(to: dateRange[1])
                    }
                    .onChange(of: selectedDate) { _ in
                        dateRange = nudgesVM.getDateRange(selectedDate: selectedDate, range: selectedTimePeriod.rawValue)
                        nudgesVM.getNudgesRangeFromFirestore(to: dateRange[1])
                    }
                
                List {
                    ForEach(nudgesVM.nudges) { nudge in
                        VStack {
                            let numberOfDone = nudge.getDoneInDateRange(from: dateRange[0], to: dateRange[1])
                            if numberOfDone == 1 {
                                Text("\(nudge.name) has been done 1 time this \(selectedTimePeriod.rawValue)")
                            } else if numberOfDone == 0 {
                                Text("\(nudge.name) hasn't been done this \(selectedTimePeriod.rawValue).")
                            } else {
                                Text("\(nudge.name) has been done \(nudge.getDoneInDateRange(from: dateRange[0], to: dateRange[1])) times this \(selectedTimePeriod.rawValue)")
                            }
                            let streak = nudge.getStreak()
                            switch streak {
                            case 0:
                                Text("You haven't got a streak going at the moment.")
                            case 1:
                                Text("Your current streak is \(streak).")
                                Text("It's a start!")
                            case 2..<7:
                                Text("Your current streak is \(streak).")
                                Text("Not bad!")
                            case 7:
                                Text("Your current streak is \(streak).")
                                Text("One week today! Way to go!")
                            case 8..<14:
                                Text("Your current streak is \(streak).")
                                Text("Keep it up!")
                            case 14:
                                Text("Your current streak is \(streak).")
                                Text("Two weeks! Time for a celebration.")
                            case 15..<21:
                                Text("Your current streak is \(streak).")
                                Text("Go! Go! Go!")
                            case 21:
                                Text("Your current streak is \(streak).")
                                Text("Wow! Three weeks straight!")
                            case 22..<28:
                                Text("Your current streak is \(streak).")
                                Text("Nothing can stop you now!")
                            case 28:
                                Text("Your current streak is \(streak).")
                                Text("FOUR. WEEKS. AND. YOU. JUST. KEEP. GOING!")
                            default:
                                Text("Your current streak is \(streak).")
                                Text("You just keep going, like a machine!")
                            }
                        }
                    }
                }
            }
        }
        .navigationBarItems(trailing: Button {
            showStatistics = false
        } label: {
            Image(systemName: "xmark")
        })
        .navigationBarItems(leading: Text("Statistics")
            .font(.system(size: 30))
            .fontWeight(.bold)
            .padding()
        )
    }
}


struct StatisticView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticView(nudgesVM: NudgesVM(), showStatistics: .constant(true))
    }
}
