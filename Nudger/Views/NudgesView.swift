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
    @State var showingNoPermissionView = false
    @State var localNudges: [Nudge]?
    
    private static var notificationDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
    
    private func timeDisplayText(from notification: UNNotificationRequest) -> String {
        guard let nextTriggerDate = (notification.trigger as? UNCalendarNotificationTrigger)?.nextTriggerDate() else {return ""}
        return Self.notificationDateFormatter.string(from: nextTriggerDate)
    }
    
    var body: some View {
     
            VStack {
                DatePicker("", selection: $nudgesVM.date, displayedComponents: .date).onChange(of: nudgesVM.date) { date in
                    // For some reason, this isn't enough to update the already loaded rowViews.
                    // UPDATE: Now it works, see rowView
                    nudgesVM.getNudgesFromFirestore()
                }
                .padding()
                
                // Listan uppdaterar inte som den skall när man byter datum. Kan vara så att läsningen från firestore inte hänger med?
                // Det som inte hänger med är checkboxen.
                if nudgesVM.nudges.count != 0 {
                    List {
                        ForEach(nudgesVM.nudges, id: \.self.uid) { nudge in
                            RowView(nudge: nudge, vm: nudgesVM)
                        }
                        
                        .onDelete() { indexSet in
                            for index in indexSet {
                                nudgesVM.deleteFromFirestore(index: index)
                            }
                            notificationManager.deleteLocalNotifications(
                                identifiers: indexSet.map {notificationManager.notifications[$0].identifier}
                            )
                            notificationManager.reloadLocalNotifications()
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                } else {
                    List {
                        Text("No Nudges Yet")
                    }
                }
//                .onChange(of: nudgesVM.nudges) { nudges in
//                    localNudges = nudges
//
//                }
                VStack {
                    Text("(Debug) Set Reminders:")
                    List {
                        ForEach(notificationManager.notifications, id: \.identifier) { notification in
                            HStack {
                                Text(notification.content.title)
                                    .fontWeight(.semibold)
                                Text(timeDisplayText(from: notification))
                                    .fontWeight(.bold)
                                Spacer()
                            }
                        }
                    }
                }
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
                localNudges = nudgesVM.nudges
                notificationManager.reloadAuthorizationStatus()
                if notificationManager.authorizationStatus == .authorized {
                    showingNoPermissionView = false
                } else {
                    showingNoPermissionView = true
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
    @ObservedObject var vm: NudgesVM
    
    // Ok, I think I solved the problem of the check box not updating, by sending the current date as an argument to this rowView.
    // UPDATE: The weird thing is, I forgot to use this variable, and it still seems to work...
    //let date: Date
    
    
    var body: some View {
   
        HStack {
            Text(nudge.name)
            Spacer()
            Text(nudge.reminderTime)
            //Text("\(vm.date)")
            Spacer()
            Button(action: {
                vm.toggleDoneThisDay(nudge: nudge)
                
            }) {
                // I seem to have a bug: (If I create a nudge set in a future date,) the checkmark doesn't update when I change date.
                // Oh, well, nothing seem to update as it should. UPDATE: Think I got it! But it is still weird...
                
                Image(systemName: nudge.getDoneThisDay(date: vm.date) ? "checkmark.square" : "square")
                //Text("\(nudge.getDoneThisDay(date: vm.date))" as String)
                
            }.buttonStyle(.borderless) // Needed so only the button is clickable and not the entire rowView!
            Text("\(nudge.getStreak())")
        }
    }
}



struct NudgesView_Previews: PreviewProvider {
    static var previews: some View {
        NudgesView()
    }
}
