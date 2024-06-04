//
//  StaffView.swift
//  SoundByte2.0
//
//  Created by Jack Durfee on 6/4/24.
//

import SwiftUI

/*
 TO-DO:
 - Change all of the overlays into a zstack, except for the end bar
 - Make staff take the key as a parameter and pass that to all child views
 - Remove error checking in the key class
 */

// view constructs the staff by bringing together the clef, notes and key signature
struct Staff: View {
    let currentClef: String
    let keyData: KeyData
    let spacing: Spacing
    
    // constructor for the staff view
    init(clef: String, keyData: KeyData, spacing: Spacing) {
        self.currentClef = clef
        self.keyData = keyData
        self.spacing = spacing
    }
    
    // builds the staff with the specified clef and key
    var body: some View {
        // controller for displaying the ledger lines
        let ledgerLineController = ledgerLineVisibilityController()
        
        // vstack for displaying all of the staff lines
        VStack(alignment: .leading, spacing: 0) {
            // upper ledger lines
            NoteLine(spacing: spacing, isLedger: true, isDisplayed: ledgerLineController.secondUpper)
            NoteLine(spacing: spacing, isLedger: true, isDisplayed: ledgerLineController.firstUpper)
            
            // staff lines
            ForEach(0..<5) { _ in NoteLine(spacing: spacing) }
            
            // lower ledger lines
            NoteLine(spacing: spacing, isLedger: true, isDisplayed: ledgerLineController.firstLower)
            NoteLine(spacing: spacing, isLedger: true, isDisplayed: ledgerLineController.secondLower)
        }
        // sets the width of the staff lines
        .frame(width: spacing.staffWidth)
        
        // overlays the bar at the end of the staff
        .overlay(alignment: .trailing) {
            Rectangle().frame(width: 10, height: spacing.staffHeight)
        }
        
        // overlays the image of the clef
        .overlay(alignment: .leading) {
            ClefImage(clef: currentClef, numSharps: keyData.numSharps, numFlats: keyData.numFlats, spacing: spacing)
        }
        
        // overlays the key signature
        .overlay(alignment: .leading) {
            KeySignature(clef: currentClef, key: keyData, spacing: spacing)
        }
        
        // positions staff to the center of the view
        .position(x: spacing.spaceWidth / 2, y: spacing.spaceHeight / 2)
        
        // offsets staff so it's aligned to leading edge
        .offset(x: -(spacing.spaceWidth - spacing.staffWidth) / 2)
    }
    
    // determines what ledger lines should be visible
    func ledgerLineVisibilityController() -> (secondUpper: Bool, firstUpper: Bool, firstLower: Bool, secondLower: Bool) {
        var results: (secondUpper: Bool, firstUpper: Bool, firstLower: Bool, secondLower: Bool) = (false, false, false, false)
        
        // first two if-statements determine the visibility of the upper ledger lines
        if spacing.indicatorY < spacing.centerNoteLocationY - spacing.whiteSpaceBetweenLines * 3.5 { results.secondUpper = true }
        if spacing.indicatorY < spacing.centerNoteLocationY - spacing.whiteSpaceBetweenLines * 2.5 { results.firstUpper = true }
        
        // second two if-statements determine the visibility of the lower ledger lines
        if spacing.indicatorY > spacing.centerNoteLocationY + spacing.whiteSpaceBetweenLines * 2.5 { results.firstLower = true }
        if spacing.indicatorY > spacing.centerNoteLocationY + spacing.whiteSpaceBetweenLines * 3.5 { results.secondLower = true }
        
        return results
    }
}

#Preview {
    GeometryReader { proxy in
        Staff(clef: "treble", keyData: Key().data, spacing: Spacing(width: proxy.size.width, height: proxy.size.height))
    }
}
