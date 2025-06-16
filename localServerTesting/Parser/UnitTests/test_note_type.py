# Note type unit tests
# Author: Cade LaVanchy
import unittest
import parser

class TestNoteType(unittest.TestCase):
    # import custom test file for note types as setup
    def setUp(self):
       file_path = 'CustomUnitTestFiles/Test_Note_Types.mxl' 
       mxl = parser.MusicXML(file_path)
       measures = mxl.part_wise()
       self.song = parser.Song(measures)
    
    # test whole notes
    def test_whole_note(self):
        measure = self.song.get_measure(0)
        notes = measure.get_notes()
        note = notes[0]
        self.assertEqual('whole', note.get_type())
        self.assertFalse(note.get_is_rest())
    
    # test half notes
    def test_half_note(self):
        measure = self.song.get_measure(1)
        notes = measure.get_notes()
        note = notes[0]
        self.assertEqual('half', note.get_type())
        self.assertFalse(note.get_is_rest())
    
    # test quarter notes
    def test_quarter_note(self):
        measure = self.song.get_measure(2)
        notes = measure.get_notes()
        note = notes[0]
        self.assertEqual('quarter', note.get_type())
        self.assertFalse(note.get_is_rest())
    
    # test eighth notes
    def test_eighth_note(self):
        measure = self.song.get_measure(3)
        notes = measure.get_notes()
        note = notes[0]
        self.assertEqual('eighth', note.get_type())
        self.assertFalse(note.get_is_rest())
        
    # test sixteenth notes
    def test_sixteenth_note(self):
        measure = self.song.get_measure(3)
        notes = measure.get_notes()
        note = notes[2]
        self.assertEqual('16th', note.get_type())
        self.assertFalse(note.get_is_rest())
    
    # test 32nd notes
    def test_32nd_note(self):
        measure = self.song.get_measure(4)
        notes = measure.get_notes()
        note = notes[0]
        self.assertEqual('32nd', note.get_type())
        self.assertFalse(note.get_is_rest())
    
    # test 64th notes
    def test_64th_note(self):
        measure = self.song.get_measure(4)
        notes = measure.get_notes()
        note = notes[5]
        self.assertEqual('64th', note.get_type())
        self.assertFalse(note.get_is_rest())
    
    # No example files with 128th notes to test or to make
    
    # test whole rests
    def test_whole_rest(self):
        measure = self.song.get_measure(5)
        notes = measure.get_notes()
        note = notes[0]
        self.assertEqual('whole', note.get_type())
        self.assertTrue(note.get_is_rest())
    
    # test half rests
    def test_half_rest(self):
        measure = self.song.get_measure(6)
        notes = measure.get_notes()
        note = notes[0]
        self.assertEqual('half', note.get_type())
        self.assertTrue(note.get_is_rest())
    
    # test quarter rests
    def test_quarter_rest(self):
        measure = self.song.get_measure(7)
        notes = measure.get_notes()
        note = notes[0]
        self.assertEqual('quarter', note.get_type())
        self.assertTrue(note.get_is_rest())
    
    # test eighth rests
    def test_eighth_rest(self):
        measure = self.song.get_measure(7)
        notes = measure.get_notes()
        note = notes[2]
        self.assertEqual('eighth', note.get_type())
        self.assertTrue(note.get_is_rest())
    
    # test sixteenth rests
    def test_sixteenth_rest(self):
        measure = self.song.get_measure(7)
        notes = measure.get_notes()
        note = notes[4]
        self.assertEqual('16th', note.get_type())
        self.assertTrue(note.get_is_rest())

    # test 32nd rests
    def test_32nd_rest(self):
        measure = self.song.get_measure(7)
        notes = measure.get_notes()
        note = notes[6]
        self.assertEqual('32nd', note.get_type())
        self.assertTrue(note.get_is_rest())
    
    # test 64th rests
    def test_64th_rest(self):
        measure = self.song.get_measure(7)
        notes = measure.get_notes()
        note = notes[8]
        self.assertEqual('64th', note.get_type())
        self.assertTrue(note.get_is_rest())
    
if __name__ == '__main__':
    unittest.main()