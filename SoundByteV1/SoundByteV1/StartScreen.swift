//
//  StartScreen.swift
//  SoundByteV1
//
//  Created by Jack Durfee on 5/15/24.
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
struct StartScreen: View {
    // state variable tells us if the user has tapped the screen yet
    @State private var isTapped: Bool = false
    @State private var landscapeImgScale: CGFloat = 1.0
    
    // tracks the orientation of the device
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    // tracks the color scheme of the device
    @Environment(\.colorScheme) var colorScheme
    
    // constructs the start screen
    var body: some View {
        ZStack {
            // sets the background color based off device color scheme
            Color(uiColor: colorScheme == .dark ? .black : .white)
                .ignoresSafeArea()
            
            // VStack contains music note image and text that tells user what to do
            VStack {
                // music note image
                Image(systemName: "music.note")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50)
                
                // text tells user to tap
                Text("Tap anywhere to start")
                    .font(.title)
                
                // displays text to rotate screen if device is in portrait mode
                if verticalSizeClass != .compact {
                    Text("For best results use landscape")
                    Image(systemName: "rectangle.landscape.rotate")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: 100)
                        .scaleEffect(CGSize(width: landscapeImgScale, height: landscapeImgScale))
                        .onAppear() {
                            withAnimation(.bouncy(duration: 1, extraBounce: 0.5).repeatForever()) {
                                landscapeImgScale = 1.1
                            }
                        }
                }
            }
            
            // clear layer to deteck taps
            Color.clear
                .ignoresSafeArea()
        }
            .onTapGesture {
                withAnimation {
                    self.isTapped.toggle()
                }
            }
            .opacity(isTapped ? 0 : 1)
    }
}

#Preview {
    StartScreen()
}
