//
//  RecordingIndicator.swift
//  SoundByte2.0
//
//  Created by Jack Durfee on 6/4/24.
//

import SwiftUI

// view creates a dot that indicates when the app is recording audio
struct RecordingIndicator: View {
    // binding variable to track when the app is recording audio
    @Binding var isRecording: Bool
    
    // state variable to track opacity of the dot
    @State var recDotOpacVal = 1.0
    
    // constant to set recording indicator parameters
    let dotSize = 20.0

    // builds the recording dot
    var body: some View {
        Image(systemName: "record.circle.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: dotSize)
            .foregroundStyle(isRecording ? .red : .secondary)
            .opacity(recDotOpacVal)
            .onChange(of: isRecording) {
                if isRecording { animate() }
                else { recDotOpacVal = 1.0 }
            }
    }
    
    // function to animate the recording dot when the app is recording audio
    func animate() {
        withAnimation(.easeInOut(duration: 0.75).repeatForever(autoreverses: true)) {
            recDotOpacVal = 0.5
        }
    }
}

#Preview {
    RecordingIndicator(isRecording: .constant(true))
}
