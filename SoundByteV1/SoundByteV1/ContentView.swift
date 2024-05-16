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
    
    var body: some View {
        // ZStack contains transparent layer to detect taps and back layer for text and images
        ZStack {
            // background color
            Color.gray
                .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            
            // VStack contains music note image and text that tells user what to do
            VStack {
                if !isTapped {
                    // music note image
                    Image("music_note")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50)
                    
                    // text tells user to tap
                    Text("Tap anywhere to start")
                        .font(.title)
                    
                    // text tells user to use landscape mode
                    Text("For best results, use landscape")
                    Image(systemName: "rectangle.landscape.rotate")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: 100)
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
