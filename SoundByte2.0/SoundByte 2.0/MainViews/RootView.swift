//
//  RootView.swift
//  SoundByte2.0
//
//  Created by Samvat Dangol on 5/29/25.
//

import SwiftUI

struct RootView: View {
    @State private var showStartView = true

    var body: some View {
        ZStack {
            if showStartView {
                StartView {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showStartView = false
                    }
                }
                .transition(.opacity)
            } else {
                ContentView()
                    .transition(.opacity)
            }
        }
    }
}

#Preview {
    RootView()
}
