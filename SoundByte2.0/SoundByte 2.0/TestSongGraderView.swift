//
//  TestSongGraderView.swift
//  SoundByte2.0
//
//  Created by Kieran Yanaway (Student) on 6/9/25.
//

import SwiftUI




struct TestSongGraderView: View {
    var filename: String
    var songGrader: SongGrader
    
    
    
    var body: some View {
        VStack{
            HStack {
                Text(songGrader.intervalNotes[0].note)
                Text(String(songGrader.intervalNotes[0].octave))
                Text(String(songGrader.targetPitches[0]))
            }
            HStack {
                Text(songGrader.intervalNotes[1].note)
                Text(String(songGrader.intervalNotes[1].octave))
                Text(String(songGrader.targetPitches[1]))
            }
            HStack {
                Text(songGrader.intervalNotes[2].note)
                Text(String(songGrader.intervalNotes[2].octave))
                Text(String(songGrader.targetPitches[2]))
            }
            HStack {
                Text(songGrader.intervalNotes[3].note)
                Text(String(songGrader.intervalNotes[3].octave))
                Text(String(songGrader.targetPitches[3]))
            }
            Text(String(songGrader.currentGrade))
            Text(String(songGrader.sumCorrectPitches))
            Text(String(songGrader.sumTotalPitches))
        }
    }
    
    init(filename: String) {
        self.filename = filename
        songGrader = SongGrader()
        songGrader.loadNotes(filename: filename)
        songGrader.calculateTargetPitches(targetNotes: songGrader.intervalNotes)
        for i in 0..<songGrader.targetPitches.count {
            songGrader.updateGrading(currentPitch: songGrader.targetPitches[i])
            //songGrader.updateGrading(currentPitch: 200000.0)
        }
    }
}

#Preview {
    
    TestSongGraderView(filename: "test-2")
}
