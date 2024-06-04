//
//  NoteLine.swift
//  SoundByte2.0
//
//  Created by Jack Durfee on 6/4/24.
//

import SwiftUI

// view constructs a line representing a specific note
struct NoteLine: View {
    let spacing: Spacing
    let isLedger: Bool
    let isDisplayed: Bool

    // constructor for line notes
    init(spacing: Spacing, isLedger: Bool = false, isDisplayed: Bool = true) {
        self.spacing = spacing
        self.isLedger = isLedger
        self.isDisplayed = isDisplayed
    }
    
    // builds the note line
    var body: some View {
        HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 15.0)
                .frame(width: isLedger ? spacing.ledgerLineWidth : .infinity, height: spacing.lineThickness)
                .offset(x: isLedger ? spacing.ledgerOffset : 0)
                .opacity(isDisplayed ? 1.0 : 0.0)
                .padding([.top, .bottom], spacing.whiteSpace)
        }
    }
}

#Preview {
    NoteLine(spacing: Spacing())
}
