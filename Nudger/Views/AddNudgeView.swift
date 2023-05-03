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
                Button("Add", action: { nudgesVM.saveToFirestore(nudgeName: title, dateCreated: nudgesVM.date)
                // Save notification!
                isPresented = false
                })
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
