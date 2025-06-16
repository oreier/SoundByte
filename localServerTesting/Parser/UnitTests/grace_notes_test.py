# Grace notes unit tests
# Author: Cade LaVanchy
import unittest
import parser

class TestGraceNotes(unittest.TestCase):
     # import and parse test grace notes mxl file
    def setUp(self):
       file_path = 'CustomUnitTestFiles/Grace_Notes_Test.mxl' 
       mxl = parser.MusicXML(file_path)
       measures = mxl.part_wise()
       self.song = parser.Song(measures)
    # test the number of grace notes in a measure
    def test_num_grace_notes(self):
        measure = self.song.get_measure(0)
        grace_notes = measure.get_grace_notes()
        self.assertEqual(len(grace_notes), 3)
    # test grace note at the beginning of a measure
    def test_grace_at_measure_start(self):
        measure = self.song.get_measure(0)
        grace_notes = measure.get_grace_notes()
        grace_note = grace_notes[0]
        self.assertEqual(grace_note[1], 0)
    # test grace note at the middle of a measure and test grace note after note instead of before
    def test_grace_at_measure_middle(self):
        measure = self.song.get_measure(0)
        grace_notes = measure.get_grace_notes()
        grace_note = grace_notes[1]
        self.assertEqual(grace_note[1], 1)
    # test grace note at the end of a measure
    def test_grace_at_measure_end(self):
        measure = self.song.get_measure(0)
        grace_notes = measure.get_grace_notes()
        grace_note = grace_notes[2]
        self.assertEqual(grace_note[1], 3)
    # test grace note without tie
    def test_grace_without_tie(self):
        measure = self.song.get_measure(1)
        grace_notes = measure.get_grace_notes()
        grace_note = grace_notes[0]
        self.assertEqual(grace_note[1], 1)
    
if __name__ == '__main__':
    unittest.main()