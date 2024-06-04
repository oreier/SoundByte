//
//  ContentView.swift
//  test2
//
//  Created by Delaney Lim (Student) on 6/3/24.
//

import SwiftUI

struct ContentView: View {
//    @StateObject var userSettings = UserSettings()
//    @State private var goToSettings = false
    
    var body: some View {
        
        VisualView()
        
//        NavigationStack {
//            VStack {
//                Button(action: {
//                    goToSettings.toggle()
//                }) {
//                    Text("Settings")
//                }
//                
//                if userSettings.noteNamesEnabled {
//                    Text("NOTES YAAA")
//                }
//            }
//            .navigationDestination(isPresented: $goToSettings){
//                SettingsView(userSettings: userSettings, selectedKeyIndex: 0)
//                    .environment(\.colorScheme, userSettings.darkModeEnabled ? .dark : .light)
//            }
//        }
    }
}

#Preview {
    ContentView()
}
