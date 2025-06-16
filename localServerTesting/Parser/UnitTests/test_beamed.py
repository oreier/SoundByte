# Beams unit tests
# Author: Cade LaVanchy
import unittest
import parser

class TestBeams(unittest.TestCase):
    # parse test beam file
    def setUp(self):
        file_path = 'CustomUnitTestFiles/Beams_Test.mxl' 
        mxl = parser.MusicXML(file_path)
        measures = mxl.part_wise()
        self.song = parser.Song(measures)
    # test beamed group at the beginning of a measure
    def test_beamed_group_at_measure_start(self):
        measure = self.song.get_measure(0)
        note_groups = measure.get_note_groups()
        notes = note_groups[0]
        self.assertTrue(notes.get_is_beamed())
    # test a beamed group inbetween non beamed notes
    def test_beamed_group_surrounded(self):
        measure = self.song.get_measure(0)
        note_groups = measure.get_note_groups()
        notes = note_groups[2]
        self.assertTrue(notes.get_is_beamed())
    # test beamed group at the end of a measure
    def test_beamed_group_at_measure_end(self):
        measure = self.song.get_measure(1)
        note_groups = measure.get_note_groups()
        notes = note_groups[1]
        self.assertTrue(notes.get_is_beamed())
    # test beamed groups back to back
    def test_beamed_group_back_to_back(self):
        measure = self.song.get_measure(2)
        note_groups = measure.get_note_groups()
        group_one = note_groups[0]
        group_two = note_groups[1]
        self.assertTrue(group_one.get_is_beamed())
        self.assertTrue(group_two.get_is_beamed())

if __name__ == '__main__':
    unittest.main()