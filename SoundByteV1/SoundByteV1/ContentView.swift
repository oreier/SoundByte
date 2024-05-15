//
//  ContentView.swift
//  SoundByteV1
//
//  Created by Delaney Lim (Student) on 5/15/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Visual()
            StartView()
        }
    }
}

// start view tells user how to start recording
struct StartView: View {
    // state variable tells us if the user has tapped the screen yet
    @State private var isTapped = false
    
    private let BACKGROUND_COLOR = Color(red: 0.0, green: 0.8, blue: 0.8)
    
    var body: some View {
        // ZStack contains transparent layer to detect taps and back layer for text and images
        ZStack {
            // background color
            BACKGROUND_COLOR
                .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            
            // VStack contains music note image and text that tells user what to do
            VStack {
                if !isTapped {
                    // music note image
                    Image("music_note")
                        .resizable()
                        .frame(width: 30, height: 50)
                        .aspectRatio(contentMode: .fit)
                    
                    // text tells user to tap
                    Text("Tap anywhere to start")
                        .font(.title)
                }
            }
            
            // clear layer to deteck taps
            Color.clear
                .contentShape(Rectangle())
        }
        
        // if ZStack is tapped, set transparancy of body to 0
        .onTapGesture {
            withAnimation {
                self.isTapped.toggle()
            }
        }
        
        .opacity(isTapped ? 0 : 1)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
