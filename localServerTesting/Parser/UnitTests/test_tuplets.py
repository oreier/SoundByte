# Tuplet unit tests
# Author: Cade LaVanchy
import unittest
import parser

class TestTuplets(unittest.TestCase):
    # import and parse test tuplets mxl file
    def setUp(self):
       file_path = 'CustomUnitTestFiles/Tuplet_Test.mxl' 
       mxl = parser.MusicXML(file_path)
       measures = mxl.part_wise()
       self.song = parser.Song(measures)
    # test tuplet group at the middle of a measure
    def test_tuplet_group_at_measure_middle(self):
        measure = self.song.get_measure(0)
        note_groups = measure.get_note_groups()
        notes = note_groups[1]
        self.assertTrue(notes.get_is_tuplet())
    # test tuplet group at the beginning of a measure
    def test_tuplet_group_at_measure_start(self):
        measure = self.song.get_measure(1)
        note_groups = measure.get_note_groups()
        notes = note_groups[0]
        self.assertTrue(notes.get_is_tuplet())
    # test tuplet group at the end of a measure
    def test_tuplet_group_at_measure_end(self):
        measure = self.song.get_measure(1)
        note_groups = measure.get_note_groups()
        notes = note_groups[2]
        self.assertTrue(notes.get_is_tuplet())
    # test rest tuplet group
    def test_rest_tuplet_group(self):
        measure = self.song.get_measure(2)
        note_groups = measure.get_note_groups()
        notes = note_groups[0]
        self.assertTrue(notes.get_is_tuplet())
    # test unbeamed tuplet group
    def test_unbeamed_tuplet_group(self):
        measure = self.song.get_measure(1)
        note_groups = measure.get_note_groups()
        notes = note_groups[0]
        self.assertTrue(notes.get_is_tuplet())
        self.assertFalse(notes.get_is_beamed())
    # test note and rest combo tuplet
    def test_note_rest_combo_tuplet(self):
        measure = self.song.get_measure(3)
        note_groups = measure.get_note_groups()
        notes = note_groups[0]
        self.assertTrue(notes.get_is_tuplet())
    
    
    

if __name__ == '__main__':
    unittest.main()