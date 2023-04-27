//
//  ContentView.swift
//  Nudger
//
//  Created by Tobias Sörensson on 2023-04-23.
//

import SwiftUI
import Firebase

struct ContentView: View {
    @State var signedIn = false
    var body: some View {
        if !signedIn {
            SignInView(signedIn: $signedIn)
        } else {
            NudgesView()
        }
    }
}


struct SignInView: View {
    @Binding var signedIn: Bool
    var auth = Auth.auth()
    
    var body: some View {
        Button(action: {
            auth.signInAnonymously { result, error in
                if let error {
                    print(error)
                } else {
                    signedIn = true
                }
            }
        }) {
            Text("Sign in")
        }
    }
}


struct NudgesView: View {
    
    @StateObject var nudgesVM = NudgesVM()
    @State var showingAddAlert = false
    @State var newNudgeName = ""
    @State var date = Date()
    @State var todaysNudges: [Nudge]?
    
    var body: some View {
        VStack {
            DatePicker("Hmm", selection: $date)
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
            Button(action: {
                showingAddAlert = true
            }) {
                Text("Add")
            }
            .alert("Add", isPresented: $showingAddAlert) {
                TextField("Add", text: $newNudgeName)
                Button("Add", action: { nudgesVM.saveToFirestore(nudgeName: newNudgeName, description: "---", dateCreated: date)
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
                    if let latestDone = nudge.doneDates.last {
                        Image(systemName: Calendar.current.isDate(latestDone, equalTo: Date(), toGranularity: .day)  ? "checkmark.square" : "square")
                    } else {
                        Image(systemName: "square")
                    }
                }.buttonStyle(.borderless)
            }
        }
    }
}





struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NudgesView()
    }
}

