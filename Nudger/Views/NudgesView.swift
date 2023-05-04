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
    @StateObject private var notificationManager = NotificationManager()
    @State var showingNoPermissionView = true
    
    var body: some View {
     
            VStack {
                DatePicker("", selection: $nudgesVM.date, displayedComponents: .date).onChange(of: nudgesVM.date) { date in
                    // For some reason, this isn't enough to update the already loaded rowViews.
                    nudgesVM.getNudgesFromFirestore()
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
                .sheet(isPresented: $showingNoPermissionView) {
                    NavigationView {
                        NoNotificationsPermission(notificationManager: notificationManager, showingNoPermissionView: $showingNoPermissionView)
                    }
                }
                .sheet(isPresented: $showingAddSheet) {
                    NavigationView {
                        AddNudgeView(notificationManager: notificationManager, nudgesVM: nudgesVM, isPresented: $showingAddSheet)
                    }
                }
            }.onAppear {
                notificationManager.reloadAuthorizationStatus()
                if notificationManager.authorizationStatus == .authorized {
                    showingNoPermissionView = false
                }
                nudgesVM.getNudgesFromFirestore()
            }
            .onChange(of: notificationManager.authorizationStatus) { authorizationStatus in
                print("!!!!!!")
                if authorizationStatus == .authorized {
                    notificationManager.reloadLocalNotifications()
                    showingNoPermissionView = false
                } else {
                    notificationManager.requestAuthorization()
                    showingNoPermissionView = true
                }
                
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                notificationManager.reloadAuthorizationStatus()
            }
        
        
    }
}

private struct RowView: View {
    let nudge: Nudge
    let vm: NudgesVM
    @State var done: Bool?
    var body: some View {
        
        HStack {
            Text(nudge.name)
            Spacer()
            Text("\(nudge.getStreak())")
                .onAppear{
                    //print(nudge.doneDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: vm.date) }))
                }
            //Text("\(vm.date)")
            Spacer()
            Button(action: {
            //done = !nudge.doneDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: vm.date) })
                //print(done)
                vm.setDone(nudge: nudge)
                
            }) {
                // I seem to have a bug: If I create a nudge set in a future date, the checkmark doesn't update when I change date.
                // Oh, well, nothing seem to update as it should.
                
                Image(systemName: nudge.getDoneThisDay(date: vm.date) ? "checkmark.square" : "square")
                //Text("\(nudge.getDoneThisDay(date: vm.date))" as String)
                
            }.buttonStyle(.borderless) // Needed so only the button is clickable and not the entire rowView!
            Text(nudge.reminderTime)
        }
    }
}



struct NudgesView_Previews: PreviewProvider {
    static var previews: some View {
        NudgesView()
    }
}
