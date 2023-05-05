//
//  NoNotificationsPermission.swift
//  Nudger
//
//  Created by Tobias Sörensson on 2023-05-02.
//

import SwiftUI

struct NoNotificationsPermission: View {
    
    @ObservedObject var notificationManager: NotificationManager
    @Binding var showingNoPermissionView: Bool
    
    var body: some View {
        VStack {
            Spacer()
            Text("You Must Enable Notifications To Use This App")
            Spacer()
            Button {
                if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            } label: {
                Label("Open settings", systemImage: "gear")
            }
            .onChange(of: notificationManager.authorizationStatus) { authorizationStatus in
                print("!!!!!!")
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
        .interactiveDismissDisabled()
    }
}

struct NoNotificationsPermission_Previews: PreviewProvider {
    static var previews: some View {
        NoNotificationsPermission(notificationManager: NotificationManager(), showingNoPermissionView: .constant(true))
    }
}
