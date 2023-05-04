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
    @State private var date = Date()
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Title", text: $title)
                    .padding()
                HStack {
                    Spacer()
                    Text("Set reminder time:")
                    DatePicker("", selection: $date, displayedComponents: .hourAndMinute)
                    Spacer()
                }
                .padding()
                Spacer()
                Button("Add", action: {
                    
                    // Save notification!
                    let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: date)
                    let dateFormatter = DateFormatter()
                    dateFormatter.timeStyle = .short
                    
                    let reminderTime = dateFormatter.string(from: date)
                    nudgesVM.saveToFirestore(nudgeName: title, dateCreated: nudgesVM.date, reminderTime: reminderTime)
                    
                    guard let hour = dateComponents.hour, let minute = dateComponents.minute else {return}
                    notificationManager.createLocalNotification(title: title, hour: hour, minute: minute) { error in
                        if let error {
                            print(error)
                        }
                    }
                isPresented = false
                })
            }
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
