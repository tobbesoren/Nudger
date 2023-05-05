//
//  AddNudgeView.swift
//  Nudger
//
//  Created by Tobias Sörensson on 2023-05-02.
//

import SwiftUI

struct AddNudgeView: View {
    
    @ObservedObject var notificationManager: NotificationManager
    @ObservedObject var nudgesVM: NudgesVM
    @Binding var isPresented: Bool
    @State private var title = ""
    @State private var selectedTime = Date()
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Title", text: $title)
                    .padding()
                HStack {
                    Spacer()
                    Text("Set reminder time:")
                    DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                    Spacer()
                }
                .padding()
                Spacer()
                Button("Add", action: {
                    
                    // Save notification!
                    let reminderTimeDateComponents = Calendar.current.dateComponents([.hour, .minute], from: selectedTime)
                    let dateFormatter = DateFormatter()
                    dateFormatter.timeStyle = .short
                    
                    let reminderTime = dateFormatter.string(from: selectedTime)
                    
                    guard let hour = reminderTimeDateComponents.hour, let minute = reminderTimeDateComponents.minute else {return}
                    notificationManager.createLocalNotification(title: title, hour: hour, minute: minute) { error in
                        if let error {
                            print(error)
                        }
                    }
                    
                    //Format date here! And save to firestore.
                    let selectedDayDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: nudgesVM.date)
                    if let dateCreated = Calendar.current.date(from: selectedDayDateComponents) {
                        nudgesVM.saveToFirestore(nudgeName: title, dateCreated: dateCreated, reminderTime: reminderTime)
                    }
                    
                    
                isPresented = false
                })
            }
            // Almost forgot...
            .onDisappear {
                notificationManager.reloadLocalNotifications()
            }
        }
        .navigationBarItems(trailing: Button {
                isPresented = false
            } label: {
                Image(systemName: "xmark")
            })
    }
}

struct AddNudgeView_Previews: PreviewProvider {
    static var previews: some View {
        AddNudgeView(notificationManager: NotificationManager(), nudgesVM: NudgesVM(), isPresented: .constant(true))
    }
}
