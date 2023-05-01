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
                Spacer()
                Text("Latest streak: \(nudge.streak)")
                //Text("\(vm.date)")
                Spacer()
                Button(action: {
                    vm.setDone(nudge: nudge)
                }) {
                   
                    // This only works when I update all nudges on firestore from setCurrentNudges.
                    // If I only update the currentNudges array, my List will show the correct nudges, but the
                    // individual rowViews won't update.
                    // (I was checking whether the selected date was in doneDates before. Now, that approach also works,
                    // but I use the stored doneThisDay instead to at least pretend it serves a purpose.)
                    
                    // I think this has to do with the way forEach works - since the structs are the same unless I re-create them reading
                    // from firestore, the rowViews won't update. Maybe. But on the other hand, I thought structs were copy-by-value,
                    // and since I re-create currentNudges each time I select a date, it should be new objects. But, wasn't there something
                    // about copying not occuring until one actually changed a value?! Complicated...

                    Image(systemName: nudge.doneDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: vm.date) }) ? "checkmark.square" : "square")
                
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
