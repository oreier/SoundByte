//
//  CentsIndicator.swift
//  SoundByte2.0
//
//  Created by Jack Durfee on 6/5/24.
//

import SwiftUI

struct CentsIndicator: View {
    var cents: Double
    var note: Note
    
    let textColor = Color(red: 80/255, green: 80/255, blue: 80/255)
    let textSize = 17.5
    
    init(cents: Double = 0, note: Note = Note(note: "C", octave: 4)) {
        self.cents = -cents // setting it to the negative because we calcualte cents backwards in visualizer view
        self.note = note
    }
    
    var body: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading) {
                Text("note:")
                    .foregroundStyle(textColor)
                    .font(.system(size: textSize))
                Text("cents:")
                    .foregroundStyle(textColor)
                    .font(.system(size: textSize))
            }
            VStack {
                Text(note.note)
                    .foregroundStyle(textColor)
                    .font(.system(size: textSize))
                HStack(spacing: 0) {
                    Text(cents >= 0 ? "+" : "-")
                        .foregroundStyle(textColor)
                        .font(.system(size: textSize))
                    Text(String(format: "%.1f", abs(cents)))
                        .foregroundStyle(textColor)
                        .font(.system(size: textSize))
                }
            }
            .frame(width: textSize * 3)
        }
        .overlay() {
            RoundedRectangle(cornerRadius: 5)
                .stroke(textColor, lineWidth: 3)
                .foregroundStyle(.clear)
                .frame(width: textSize * 8)
            
        }
    }
}

#Preview {
    CentsIndicator()
}
