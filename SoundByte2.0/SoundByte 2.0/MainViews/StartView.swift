//
//  StartView.swift
//  SoundByte2.0
//
//  Created by Jack Durfee on 6/11/24.
//

/*
 TO-DO:
 - Fix bug where landscape image stops animating when you swtich from lanspace orientation to portrait
 - Change animation of landscape icon to be smother (see animation in SFSymbols)
 */

import SwiftUI

/*
 struct creates the start screen that is displayed when
 the user first opens the app
 */
struct StartView: View {
    // state variable tells us if the user has tapped the screen yet
    @State var isTapped: Bool = false
        
    let backgroundColor = Color(red: 250 / 255, green: 248 / 255, blue: 243 / 255)
    
    // constructs the start screen
    var body: some View {
        ZStack {
            
            // vstack contains music note image and text that tells user what to do
            VStack {
                // music note image
                Image(systemName: "music.note")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50)
                
                // text tells user to tap
                Text("Tap anywhere to start")
                    .font(.title)
            }
            
            // clear layer to deteck taps
            Color.clear
                .ignoresSafeArea()
        }
        .background(backgroundColor)
        .opacity(isTapped ? 0 : 1)
        .onTapGesture {
            withAnimation {
                self.isTapped.toggle()
            }
        }
    }
}

#Preview {
    StartView()
}
