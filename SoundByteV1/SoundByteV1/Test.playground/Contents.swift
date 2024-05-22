import UIKit

class FreqGraphMapper {
    private var startNote: (note: String, octave: Int)
    private var graphBounds: (upper: Double, lower: Double)
    private var numNotes: Int
    
    private var baseNotes: Dictionary = ["C":   (0, 16.35),
                                         "C#":  (1, 17.32),
                                         "D":   (2, 18.35),
                                         "D#":  (3, 19.45),
                                         "E":   (4, 20.60),
                                         "F":   (5, 21.83),
                                         "F#":  (6, 23.12),
                                         "G":   (7, 24.50),
                                         "G#":  (8, 25.96),
                                         "A":   (9, 27.50),
                                         "A#":  (10, 29.14),
                                         "B":   (11, 30.87)]
    
    private var notes: [String] = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    
    init(startNote: (note: String, octave: Int), graphBounds: (upper: Double, lower: Double), numNotes: Int) {
        self.startNote = startNote
        self.graphBounds = graphBounds
        self.numNotes = numNotes
    }
    
    func mapToGraph() -> [(String, Double)] {
        var results: [(String, Double)] = []
        var currY: Double = 0
        
        let SCREEN_SPACE: Double = graphBounds.lower - graphBounds.upper
        let WHITE_SPACE: Double = SCREEN_SPACE / Double(numNotes + 1)
        
        for i in (baseNotes[startNote.note]!.0) ..< (baseNotes[startNote.note]!.0 + numNotes) {
            var currNote = notes[i%notes.count]
            var currFreq = baseNotes[currNote]!.1 * pow(2, Double(startNote.octave) + ((i >= notes.count) ? 1 : 0))
            
            currY += WHITE_SPACE
            results.append((currNote, currY))
        }
        return results.reversed()
    }
}

var newGraphMapper = FreqGraphMapper(startNote: ("C", 5), graphBounds: (0, 300), numNotes: 5)
print(newGraphMapper.mapToGraph())

print(13 % 12 + 12)
