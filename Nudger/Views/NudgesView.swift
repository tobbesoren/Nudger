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
    
    @State var showingAddSheet = false
    @State var showingNoPermissionView = false
    @State var showStatistics = false
    
    
    var body: some View {
     
        VStack {
            
            HStack {
                Text("Nudges")
                    .font(.system(size: 30))
                    .fontWeight(.bold)
                    .padding()
                Spacer()
                DatePicker("", selection: $nudgesVM.date, displayedComponents: .date)
                    .onChange(of: nudgesVM.date) { _ in
                        nudgesVM.loadNudgesFromFirestore()
                    }
                    .padding()
                    .datePickerStyle(.compact)
            }
            
            HStack {
                Spacer()
                Button(action: {
                    showingAddSheet = true
                    print("!")
                }) {
                    Image(systemName: "plus.circle")
                        .imageScale(.large)
                }
                .buttonStyle(.borderless)
                .padding([.trailing], 20)
                
            }
            
            if nudgesVM.nudges.count != 0 {
                List {
                    ForEach(nudgesVM.nudges) { nudge in
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

            
            HStack {
                Button(action: {
                    showStatistics = true
                    
                }) {
                    Text("Statistics")
                }
                .buttonStyle(.borderless)
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
        .sheet(isPresented: $showStatistics, onDismiss: {nudgesVM.loadNudgesFromFirestore()}) {
            NavigationView {
                StatisticView(nudgesVM: nudgesVM, showStatistics: $showStatistics)
            }
        }
        .onAppear {
            notificationManager.reloadAuthorizationStatus()
            if notificationManager.authorizationStatus == .authorized {
                showingNoPermissionView = false
            } else {
                showingNoPermissionView = true
            }
            nudgesVM.loadNudgesFromFirestore()
        }
        .onChange(of: notificationManager.authorizationStatus) { authorizationStatus in
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
        VStack {
            HStack {
                Text(nudge.name)
                    .fontWeight(.semibold)
                    .padding([.leading, .trailing, .bottom])
                Spacer()
                Text(nudge.reminderTime)
                    .padding([.leading, .trailing, .bottom])
            }
            
            HStack {
                Text("Current streak: \(nudge.getStreak())")
                    .padding([.leading, .trailing, .bottom])
                Spacer()
                Button(action: {
                    vm.toggleDoneThisDay(nudge: nudge)
                }) {
                    Image(systemName: nudge.getDoneThisDay(date: vm.date) ? "checkmark.square" : "square")
                }
                .buttonStyle(.borderless) // Needed so only the button is clickable and not the entire rowView!
                .padding([.leading, .trailing, .bottom])
            }
        }
    }
}


struct NudgesView_Previews: PreviewProvider {
    static var previews: some View {
        NudgesView()
    }
}
