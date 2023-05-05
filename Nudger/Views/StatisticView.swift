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
    //@State var nudgesToShow: [Nudge] = []

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
                        print(dateRange)
                        print(nudgesVM.nudges)
                        
                    }
                    .onChange(of: selectedTimePeriod) { _ in
                        dateRange = nudgesVM.getDateRange(selectedDate: selectedDate, range: selectedTimePeriod.rawValue)
                        nudgesVM.getNudgesRangeFromFirestore(to: dateRange[1])
                        print(dateRange)
                    }
                    .onChange(of: selectedDate) { _ in
                        dateRange = nudgesVM.getDateRange(selectedDate: selectedDate, range: selectedTimePeriod.rawValue)
                        nudgesVM.getNudgesRangeFromFirestore(to: dateRange[1])
                        print(dateRange)
                    }
                
                
                List {
                    ForEach(nudgesVM.nudges, id: \.self.uid) { nudge in
                        HStack {
                            if nudge.getDoneInDateRange(from: dateRange[0], to: dateRange[1]) == 1 {
                                Text("\(nudge.name) has been done 1 time this \(selectedTimePeriod.rawValue)")
                            } else if nudge.getDoneInDateRange(from: dateRange[0], to: dateRange[1]) == 0 {
                                Text("\(nudge.name) hasn't been done yet this \(selectedTimePeriod.rawValue)")
                            } else {
                                Text("\(nudge.name) has been done \(nudge.getDoneInDateRange(from: dateRange[0], to: dateRange[1])) times this \(selectedTimePeriod.rawValue)")
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

func getTimeSpan() {
    
}

struct StatisticView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticView(nudgesVM: NudgesVM(), showStatistics: .constant(true))
    }
}
