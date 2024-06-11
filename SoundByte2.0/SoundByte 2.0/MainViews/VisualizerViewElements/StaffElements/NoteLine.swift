//
//  NoteLine.swift
//  SoundByte2.0
//
//  Created by Jack Durfee on 6/4/24.
//

import SwiftUI

// view constructs a line representing a specific note
struct NoteLine: View {
    let layout: UILayout
    let isLedger: Bool
    let isDisplayed: Bool

    // constructor for line notes
    init(layout: UILayout, isLedger: Bool = false, isDisplayed: Bool = true) {
        self.layout = layout
        self.isLedger = isLedger
        self.isDisplayed = isDisplayed
    }
    
    // builds the note line
    var body: some View {
        HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 15.0)
                .frame(width: isLedger ? layout.ledgerLineWidth : layout.staffWidth, height: layout.lineThickness)
                .offset(x: isLedger ? layout.ledgerOffset : 0)
                .opacity(isDisplayed ? 1.0 : 0.0)
                .padding([.top, .bottom], layout.whiteSpace)
        }
    }
}

#Preview {
    GeometryReader { proxy in
        NoteLine(layout: UILayout(width: proxy.size.width, height: proxy.size.height))
    }
}
