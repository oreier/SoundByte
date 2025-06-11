//
//  GraderDisplay.swift
//  SoundByte2.0
//
//  Created by Kieran Yanaway (Student) on 6/10/25.
//

import SwiftUI

struct GraderDisplay: View {
    var songGrade: String
    var fontSize: Double
    
    var body: some View {
        ZStack {
//            RoundedRectangle(cornerRadius: 5)
//                .stroke(Color.primary, lineWidth: 4)
//                .foregroundStyle(.clear)
//                .frame(width: 4*fontSize , height: fontSize)
            Text(songGrade + "%")
                .font(.system(size: fontSize))
                .foregroundStyle(Color(.black))
        }
    }
}

#Preview {
    GraderDisplay(songGrade: String(100.0), fontSize: 48.0)
}
