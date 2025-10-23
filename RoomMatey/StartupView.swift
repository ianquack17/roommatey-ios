//
//  StartupView.swift
//  RoomMatey
//
//  Created by Ian Quack on 10/20/25.
//

import SwiftUI

struct StartupView: View {
    @EnvironmentObject var appState: AppState
    @State private var inputName = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to RoomMatey")
                .font(.largeTitle)
                .bold()
            Text("Let's get your profile set up.")
                .font(.subheadline)
            TextField("Enter your name", text: $inputName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button("Continue") {
                appState.authenticationViewModel.signIn(name: inputName)
            }
            .disabled(inputName.trimmingCharacters(in: .whitespaces).isEmpty)
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
