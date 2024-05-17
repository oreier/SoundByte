//
//  ContentView.swift
//  SoundByteV1
//
//  Created by Delaney Lim (Student) on 5/15/24.
//

import SwiftUI

/*
 main view for the app that brings all individual views into one
 */
struct ContentView: View {
    // constructs app UI
    var body: some View {
        ZStack {
            ToolBar()
            StartScreen()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
