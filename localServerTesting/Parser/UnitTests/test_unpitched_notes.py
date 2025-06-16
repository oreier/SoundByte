# Unpitched notes unit tests
# Author: Cade LaVanchy
import unittest
import parser

class TestUnpitched(unittest.TestCase):
    def setUp(self):
        file_path = 'CustomUnitTestFiles/Unpitched_Note_Test.mxl' 
        mxl = parser.MusicXML(file_path)
        measures = mxl.part_wise()
        self.song = parser.Song(measures)
    # test the step from unpitched note
    def test_step(self):
        measure = self.song.get_measure(2)
        note = measure.get_notes()[1]
        note_string = note.get_note()
        self.assertIn('f', note_string)
        self.assertTrue(note.get_is_unpitched())
    # test octave from unpitched note
    def test_octave(self):
        measure = self.song.get_measure(2)
        note = measure.get_notes()[1]
        note_string = note.get_note()
        self.assertIn('4', note_string)
        self.assertTrue(note.get_is_unpitched())
if __name__ == '__main__':
    unittest.main()
    