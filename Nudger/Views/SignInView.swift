//
//  SignInView.swift
//  Nudger
//
//  Created by Tobias Sörensson on 2023-04-27.
//

import SwiftUI
import Firebase

struct SignInView: View {
    @Binding var signedIn: Bool
    var auth = Auth.auth()
    
    
    var body: some View {
        VStack {
            Spacer()
            Text("Nudger")
                .fontWeight(.semibold)
                .font(.system(size: 40))
            Spacer()
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
            .onAppear {
            }
            Spacer()
        }
        
    }
}

struct SignInView_Previews: PreviewProvider {
    @State static private var dummySignedIn = false
    static var previews: some View {
        SignInView(signedIn: $dummySignedIn)
    }
}
