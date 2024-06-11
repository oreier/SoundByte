//
//  StaffView.swift
//  SoundByte2.0
//
//  Created by Jack Durfee on 6/4/24.
//

import SwiftUI

// view constructs the staff by bringing together the clef, notes and key signature
struct Staff: View {
    let currentClef: ClefType
    let currentKey: Key
    let layout: UILayout
    
    // constructor for the staff view
    init(clef: ClefType, key: Key, layout: UILayout) {
        self.currentClef = clef
        self.currentKey = key
        self.layout = layout
    }
    
    // builds the staff with the specified clef and key
    var body: some View {
        // controller for displaying the ledger lines
        let ledgerController = ledgerVisibilityController()
        
        // zstack for ovrelaying staff lines, clef and key signature
        ZStack(alignment: .leading) {
            
            // vstack for displaying all of the staff lines
            VStack(alignment: .leading, spacing: 0) {
                // upper ledger lines
                NoteLine(layout: layout, isLedger: true, isDisplayed: ledgerController.secondUpper)
                NoteLine(layout: layout, isLedger: true, isDisplayed: ledgerController.firstUpper)
                
                // staff lines
                ForEach(0..<5) { _ in NoteLine(layout: layout) }
                
                // lower ledger lines
                NoteLine(layout: layout, isLedger: true, isDisplayed: ledgerController.firstLower)
                NoteLine(layout: layout, isLedger: true, isDisplayed: ledgerController.secondLower)
            }
            // sets the width of the staff lines
            .frame(width: layout.staffWidth)
            
            // overlays the bar at the end of the staff
            .overlay(alignment: .trailing) { Rectangle().frame(width: 10, height: layout.staffHeight) }
            
            
            HStack {
                // overlays the image of the clef
                ClefImage(clef: currentClef)
                
                // overlays the key signature
                KeySignature(clef: currentClef, key: currentKey, layout: layout)
            }
        }
        // positions staff to the center of the view
        .position(x: layout.width / 2, y: layout.height / 2)
        
        // offsets staff so it's aligned to leading edge
        .offset(x: -(layout.width - layout.staffWidth) / 2)
    }
    
    // determines what ledger lines should be visible
    func ledgerVisibilityController() -> (secondUpper: Bool, firstUpper: Bool, firstLower: Bool, secondLower: Bool) {
        var results: (secondUpper: Bool, firstUpper: Bool, firstLower: Bool, secondLower: Bool) = (false, false, false, false)
        
        // first two if-statements determine the visibility of the upper ledger lines
        if layout.indicatorY < layout.centerNoteLocationY - layout.spaceBetweenLines * 3.5 { results.secondUpper = true }
        if layout.indicatorY < layout.centerNoteLocationY - layout.spaceBetweenLines * 2.5 { results.firstUpper = true }
        
        // second two if-statements determine the visibility of the lower ledger lines
        if layout.indicatorY > layout.centerNoteLocationY + layout.spaceBetweenLines * 2.5 { results.firstLower = true }
        if layout.indicatorY > layout.centerNoteLocationY + layout.spaceBetweenLines * 3.5 { results.secondLower = true }
        
        return results
    }
}

#Preview {
    GeometryReader { proxy in
        Staff(clef: ClefType.bass, key: KeyGenerator(numFlats: 3, isMajor: true).data, layout: UILayout(width: proxy.size.width, height: proxy.size.height))
    }
}
