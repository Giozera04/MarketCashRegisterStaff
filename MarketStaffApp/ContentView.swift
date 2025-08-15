//
//  ContentView.swift
//  MarketStaffApp
//
//  Created by Giovane Junior on 6/22/25.
//

import SwiftUI
import FirebaseAuth


struct ContentView: View {
    
    @AppStorage("isStaffLoggedIn") private var isStaffLoggedIn = false

    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("📲 Market Staff App")
                    .font(.title)

                NavigationLink("Open Scanner") {
                    StaffScannerScreen()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                
                Button("Logout"){
                    do {
                        try Auth.auth().signOut()
                        isStaffLoggedIn = false
                    } catch {
                        print("❌ Error signing out:", error.localizedDescription)
                    }
                }
                .foregroundColor(.red)
                .padding(.top, 20)
            }
        }
    }
}
