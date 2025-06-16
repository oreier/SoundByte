# Accidentals unit tests
# Author: Cade LaVanchy
import unittest
import parser

class TestAccidentals(unittest.TestCase):
 # import custom test file for time signatures as setup
    def setUp(self):
       file_path = 'CustomUnitTestFiles/Accidentals_Test.mxl' 
       mxl = parser.MusicXML(file_path)
       measures = mxl.part_wise()
       self.song = parser.Song(measures)
    
    # test flat
    def test_flat(self):
        measure = self.song.get_measure(0)
        notes = measure.get_notes()
        note = notes[0]
        note_string = note.get_note()
        self.assertTrue(note_string.startswith('fb'))
    # test sharp
    def test_sharp(self):
        measure = self.song.get_measure(0)
        notes = measure.get_notes()
        note = notes[1]
        note_string = note.get_note()
        self.assertTrue(note_string.startswith('g#'))
    # test natural
    def test_nautral(self):
        measure = self.song.get_measure(0)
        notes = measure.get_notes()
        note = notes[2]
        note_string = note.get_note()
        self.assertTrue(note_string.startswith('an'))
    # test double sharp
    def test_double_sharp(self):
        measure = self.song.get_measure(0)
        notes = measure.get_notes()
        note = notes[3]
        note_string = note.get_note()
        self.assertTrue(note_string.startswith('b##'))
    # test flat flat
    def test_flat_flat(self):
        measure = self.song.get_measure(1)
        notes = measure.get_notes()
        note = notes[0]
        note_string = note.get_note()
        self.assertTrue(note_string.startswith('abb'))
     # test natural sharp
    def test_natural_sharp(self):
        measure = self.song.get_measure(1)
        notes = measure.get_notes()
        note = notes[1]
        note_string = note.get_note()
        self.assertTrue(note_string.startswith('an#'))
     # test natural flat
    def test_natural_flat(self):
        measure = self.song.get_measure(1)
        notes = measure.get_notes()
        note = notes[2]
        note_string = note.get_note()
        self.assertTrue(note_string.startswith('cnb'))
     # test triple sharp
    def test_triple_sharp(self):
        measure = self.song.get_measure(2)
        notes = measure.get_notes()
        note = notes[0]
        note_string = note.get_note()
        self.assertTrue(note_string.startswith('f###'))
     # test flat flat
    def test_triple_flat(self):
        measure = self.song.get_measure(2)
        notes = measure.get_notes()
        note = notes[1]
        note_string = note.get_note()
        self.assertTrue(note_string.startswith('gbbb'))
    # test no accidental
    def test_no_acciental(self):
        measure = self.song.get_measure(2)
        notes = measure.get_notes()
        note = notes[2]
        note_string = note.get_note()
        self.assertTrue(note_string.startswith('a4'))

if __name__ == '__main__':
    unittest.main()