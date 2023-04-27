//
//  NudgesView.swift
//  Nudger
//
//  Created by Tobias Sörensson on 2023-04-27.
//

import SwiftUI

struct NudgesView: View {
    
    @StateObject var nudgesVM = NudgesVM()
    @State var showingAddAlert = false
    @State var newNudgeName = ""
    //@State var date = Date()
    //@State var todaysNudges: [Nudge]?
    
    var body: some View {
        VStack {
            DatePicker("Hmm", selection: $nudgesVM.date).onChange(of: nudgesVM.date) { date in
                print(date)
                // Call your function here
                nudgesVM.setCurrentNudges(date: date)
            }
            List {
                ForEach(nudgesVM.currentNudges) { nudge in
                    RowView(nudge: nudge, vm: nudgesVM)
                }
                .onDelete() { indexSet in
                    for index in indexSet {
                        nudgesVM.deleteFromFirestore(index: index)
                    }
                }
            }
            Button(action: {
                showingAddAlert = true
                print("!")
            }) {
                Text("Add")
            }
            .alert("Add", isPresented: $showingAddAlert) {
                TextField("Add", text: $newNudgeName)
                Button("Add", action: { nudgesVM.saveToFirestore(nudgeName: newNudgeName, description: "---", dateCreated: nudgesVM.date)
                    newNudgeName = ""
                })
            }
        }.onAppear() {
          nudgesVM.listenToFirestore()
        }
    }
    
    private struct RowView: View {
        let nudge: Nudge
        let vm: NudgesVM
        
        var body: some View {
            HStack {
                Text(nudge.name)
                Spacer()
                Button(action: {
                    vm.setDone(nudge: nudge)
                }) {
                    // Change this to show actual date!
                    // if date in nudge.datesDone:
                    //      Image(systemName: Calendar.current.isDate(
                    //              latestDone,
                    //              inSameDayAs: Date(),
                    //              toGranularity: .day)  ? "checkmark.square" : "square")
                    
                    
                    
                    
                    if let latestDone = nudge.doneDates.last {
                        Image(systemName: Calendar.current.isDate(latestDone, equalTo: Date(), toGranularity: .day)  ? "checkmark.square" : "square")
                    } else {
                        Image(systemName: "square")
                    }
                }.buttonStyle(.borderless) // Needed so only the button is clickable and not the entire rowView!
            }
        }
    }
}


struct NudgesView_Previews: PreviewProvider {
    static var previews: some View {
        NudgesView()
    }
}
