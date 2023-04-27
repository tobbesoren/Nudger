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


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NudgesView()
    }
}

