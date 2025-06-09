//
//  SongGrader.swift
//  SoundByte2.0
//
//  Created by Kieran Yanaway (Student) on 6/8/25.
//

import Foundation

class SongGrader {
    
    var intervalNotes: [Note] = []
    var targetPitches: [Double] = []
    var historyPitches: [Double] = []
    var correctPitches: [Double] = []
    var currentGrade: Double = 0.0
    var sumCorrectPitches: Double = 0.0
    var sumTotalPitches: Double = 0.0
    var notesToGraphMapper = NotesToGraphMapper()
    
    func loadNotes(filename: String) {
        intervalNotes = load(filename)
    }
    
    func calculateTargetPitches(targetNotes: [Note]) {
        // Get all frequencies of notes for all intervals
        for note: Note in targetNotes {
            targetPitches.append(notesToGraphMapper.calculateFreqency(of: note))
        }
    }
    
    func updateHistoryPitches(currentPitch: Double) {
        historyPitches.append(currentPitch)
    }
    
    func graderCentHelper(historyPitch: Double, targetPitch: Double) -> Double {
        return 1200 * log2(targetPitch / historyPitch)
    }
    
    func gradeCurrentInterval(cents: Double) -> Double {
        if cents < 40 {
            return 1.0
        }
        return 0.0
    }
    
    func updateGrading(currentPitch: Double) {
        updateHistoryPitches(currentPitch: currentPitch)
        // Get cent difference to grade current interval
        let cents = abs(graderCentHelper(historyPitch: currentPitch, targetPitch: targetPitches[historyPitches.count - 1]))
        let intervalGrade = gradeCurrentInterval(cents: cents)
        // Update grading variables and array
        sumCorrectPitches += intervalGrade
        correctPitches.append(intervalGrade)
        sumTotalPitches += 1.0
        currentGrade = 100 * sumCorrectPitches / sumTotalPitches
    }

}

func load<T: Decodable>(_ filename: String) -> T {
    let data: Data
    
    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
    else {
        fatalError("Couldn't find \(filename) in main bundle.")
    }
    
    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }
    
    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self ):\n\(error)")
    }
}
