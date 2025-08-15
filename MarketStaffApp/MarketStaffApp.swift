//
//  MarketStaffAppApp.swift
//  MarketStaffApp
//
//  Created by Giovane Junior on 6/22/25.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct MarketStaffApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @AppStorage("isStaffLoggedIn") var isStaffLoggedIn = false

    var body: some Scene {
        WindowGroup {
            Group {
                if isStaffLoggedIn {
                    ContentView()
                } else {
                    StaffLoginView()
                }
            }
            .preferredColorScheme(.light)
        }
    }
}
