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
    var targetIndex = 0
    
    func loadNotes(filename: String) {
        intervalNotes = load(filename)
    }
    
    func calculateTargetPitches(targetNotes: [Note]) {
        // Get all frequencies of notes for all intervals
        for note: Note in targetNotes {
            targetPitches.append(notesToGraphMapper.calculateFreqency(of: note))
        }
    }
    
    private func updateHistoryPitches(currentPitch: Double) {
        historyPitches.append(currentPitch)
    }
    
    func graderCentHelper(historyPitch: Double) -> Double {
        if targetPitches.count > 0 && targetPitches.count < targetIndex {
            let targetPitch = targetPitches[targetIndex]
            if historyPitch != 0 {
                return 1200 * log2(targetPitch / historyPitch)
            }
        }
        return 0.0
    }
    
    func gradeCurrentInterval(historyPitch: Double) -> Double {
        let cents = graderCentHelper(historyPitch: historyPitch)
        let centLimit = 40.0
        // If cents are within centLimit, then note was hit
        if abs(cents) < centLimit {
            return 1.0
        }
        return 0.0
    }
    
    func updateGrading(currentPitch: Double) {
        updateHistoryPitches(currentPitch: currentPitch)
        // Grade current interval
        let intervalGrade = gradeCurrentInterval(historyPitch: currentPitch)
        // Update grading variables and array
        sumCorrectPitches += intervalGrade
        correctPitches.append(intervalGrade)
        sumTotalPitches += 1.0
        currentGrade = 100 * sumCorrectPitches / sumTotalPitches
        targetIndex += 1
    }
    
    func reset() {
        intervalNotes = []
        targetPitches = []
        historyPitches = []
        correctPitches = []
        currentGrade = 0.0
        sumCorrectPitches = 0.0
        sumTotalPitches = 0.0
        targetIndex = 0
    }
}

func load<T: Decodable>(_ filename: String) -> T {
    let data: Data
    
    guard let file = Bundle.main.url(forResource: filename, withExtension: "json")
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
