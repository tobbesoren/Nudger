//
//  NudgesView.swift
//  Nudger
//
//  Created by Tobias Sörensson on 2023-04-27.
//

import SwiftUI

struct NudgesView: View {
    
    @StateObject var nudgesVM = NudgesVM()
    @State var showingAddSheet = false
    //@State var newNudgeName = ""
    @StateObject private var notificationManager = NotificationManager()
    //@State var timeSet = Date()
    
    var body: some View {
        VStack {
            DatePicker("", selection: $nudgesVM.date, displayedComponents: .date).onChange(of: nudgesVM.date) { date in
                //nudgesVM.setCurrentNudges(date: date)
            }
            .padding()
            List {
                ForEach(nudgesVM.nudges) { nudge in
                    RowView(nudge: nudge, vm: nudgesVM)
                }
                .onDelete() { indexSet in
                    for index in indexSet {
                        nudgesVM.deleteFromFirestore(index: index)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            Button(action: {
                showingAddSheet = true
                print("!")
            }) {
                Text("Add")
            }
            .sheet(isPresented: $showingAddSheet) {
                NavigationView {
                    AddNudgeView(notificationManager: notificationManager, nudgesVM: nudgesVM, isPresented: $showingAddSheet)
                }
            }
        }.onAppear {
            notificationManager.reloadAuthorizationStatus()
            nudgesVM.listenToFirestore()
        }
        .onChange(of: notificationManager.authorizationStatus) { authorizationStatus in
            switch authorizationStatus {
            case .notDetermined:
                notificationManager.requestAuthorization()
            case .authorized:
                notificationManager.reloadLocalNotifications()
            default:
                break
            }
        }
        
    }
}

private struct RowView: View {
    let nudge: Nudge
    let vm: NudgesVM
    //@State var done = false
    var body: some View {
        
        HStack {
            Text(nudge.name)
            Spacer()
            Text("Streak: \(nudge.getStreak())")
            //Text("\(vm.date)")
            Spacer()
            Button(action: {
            //done = !nudge.doneDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: vm.date) })
                //print(done)
                vm.setDone(nudge: nudge)
            }) {
                // I seem to have a bug: If I create a nudge set in a future date, the checkmark doesn't update when I change date.
                // Oh, well, nothing seem to update as it should.
                Image(systemName: nudge.doneDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: vm.date) }) ? "checkmark.square" : "square")
                
            }.buttonStyle(.borderless) // Needed so only the button is clickable and not the entire rowView!
        }
    }
}



struct NudgesView_Previews: PreviewProvider {
    static var previews: some View {
        NudgesView()
    }
}
