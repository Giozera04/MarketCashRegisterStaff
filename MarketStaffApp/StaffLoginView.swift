//
//  StaffLoginView.swift
//  MarketStaffApp
//
//  Created by Giovane Junior on 8/6/25.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct StaffLoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    @AppStorage("isStaffLoggedIn") private var isStaffLoggedIn = false

    var body: some View {
        VStack(spacing: 24) {
            Text("Staff Login")
                .font(.largeTitle)
                .bold()

            VStack(spacing: 12) {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)

                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
            }

            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }

            if isLoading {
                ProgressView()
            } else {
                Button("Login") {
                    login()
                }
                .buttonStyle(.borderedProminent)
                .disabled(email.isEmpty || password.isEmpty)
            }
        }
        .padding()
    }

    func login() {
        errorMessage = nil
        isLoading = true

        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            isLoading = false

            if let error = error {
                errorMessage = error.localizedDescription
                return
            }

            // ✅ Login successful
            isStaffLoggedIn = true
        }
    }
}
