//
//  NudgesView.swift
//  Nudger
//
//  Created by Tobias Sörensson on 2023-04-27.
//

import SwiftUI

struct NudgesView: View {
    
    @StateObject var nudgesVM = NudgesVM()
    @StateObject private var notificationManager = NotificationManager()
    @State var localNudges: [Nudge]?
    
    @State var showingAddSheet = false
    @State var showingNoPermissionView = false
    @State var showStatistics = false
    
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
            HStack {
                Text("Nudges")
                    .font(.system(size: 30))
                    .fontWeight(.bold)
                    .padding()
                DatePicker("", selection: $nudgesVM.date, displayedComponents: .date)
                    .onChange(of: nudgesVM.date) { date in
                        nudgesVM.loadNudgesFromFirestore()
                    }
                    .padding()
            }
            
            
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

            // Will be removed later
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
            
            HStack {
                Spacer()
                Button(action: {
                    showingAddSheet = true
                    print("!")
                }) {
                    Text("Add")
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button(action: {
                    showStatistics = true
                    
                }) {
                    Text("Stats")
                }
                .buttonStyle(.borderless)
                Spacer()
                
            }
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
        .sheet(isPresented: $showStatistics) {
            NavigationView {
                StatisticView(nudgesVM: nudgesVM, showStatistics: $showStatistics)
            }
        }
        
        .onAppear {
                localNudges = nudgesVM.nudges
                notificationManager.reloadAuthorizationStatus()
                if notificationManager.authorizationStatus == .authorized {
                    showingNoPermissionView = false
                } else {
                    showingNoPermissionView = true
                }
                nudgesVM.loadNudgesFromFirestore()
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
                Image(systemName: nudge.getDoneThisDay(date: vm.date) ? "checkmark.square" : "square")
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
