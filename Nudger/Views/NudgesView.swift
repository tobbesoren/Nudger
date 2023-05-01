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
    
    var body: some View {
        VStack {
            DatePicker("Hmm", selection: $nudgesVM.date, displayedComponents: .date).onChange(of: nudgesVM.date) { date in
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
                //Text("\(vm.date)")
                Spacer()
                Button(action: {
                    vm.setDone(nudge: nudge)
                }) {
                   
                    // This only works when I update all nudges on firestore from setCurrentNudges.
                    // If I only update the currentNudges array, my List will show the correct nudges, but the
                    // individual rowViews won't update. I can't figure out why!!!
                    // (I was checking whether the selected date was in doneDates before. Now, that approach also works,
                    // but I use the stored doneThisDay instead to at least pretend it serves a purpose.)

                    Image(systemName: nudge.doneThisDay ? "checkmark.square" : "square")
                
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
