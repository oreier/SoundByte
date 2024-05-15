//
//  StartScree.swift
//  SoundByteV1
//
//  Created by Jack Durfee on 5/15/24.
//

import SwiftUI

struct StartScreen: View {
    var body: some View {
        VStack {
            Image("music_note")
                .resizable()
                .frame(width: 30, height: 50)
                .aspectRatio(contentMode: .fit)
            Text("Tap to start")
        }
    }
}

#Preview {
    StartScreen()
}
