//
//  VisualView.swift
//  test2
//
//  Created by Delaney Lim (Student) on 6/4/24.
//

import SwiftUI

struct VisualView: View {
    
    @StateObject var userSettings = UserSettings()
    
    @State private var goToSettings = false
    
    var body: some View {
        
        NavigationStack {
            VStack {
                Button(action: {
                    goToSettings.toggle()
                }) {
                    Label("", systemImage: "gear")
                        .foregroundColor(userSettings.darkModeEnabled ? .white : .black)
                        .padding()
                        .cornerRadius(8)
                }
                
                if userSettings.noteNamesEnabled {
                    Text("NOTES YAAA")
                }
                
                Text("Graph and staff and notes yay")
                Image("C_treble")
                    .resizable()
                    .scaledToFit()
            }
            .navigationDestination(isPresented: $goToSettings){
                SettingsView(userSettings: userSettings, selectedKeyIndex: 0)
                    .environment(\.colorScheme, userSettings.darkModeEnabled ? .dark : .light)
            }
        }
        .environment(\.colorScheme, userSettings.darkModeEnabled ? .dark : .light)
    }
}

#Preview {
    VisualView()
}
