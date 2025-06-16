# Slurs unit tests
# Author: Cade LaVanchy
import unittest
import parser

class TestSlurs(unittest.TestCase):
     # import and parse test slurs mxl file
    def setUp(self):
       file_path = 'CustomUnitTestFiles/Test_Slurs.mxl' 
       mxl = parser.MusicXML(file_path)
       measures = mxl.part_wise()
       self.song = parser.Song(measures)
    # test slur at the middle of a measure
    def test_slurs_at_measure_middle(self):
        measure = self.song.get_measure(0)
        slur_indicies = measure.get_slur_indicies()
        self.assertIn([1, 2], slur_indicies)
    # test slur at end of measure
    def test_slurs_at_measure_end(self):
        measure = self.song.get_measure(1)
        slur_indicies = measure.get_slur_indicies()
        self.assertIn([2, 3], slur_indicies)
    # test slur at beginning of measure
    def test_ties_at_measure_start(self):
        measure = self.song.get_measure(1)
        slur_indicies = measure.get_slur_indicies()
        self.assertIn([0, 1], slur_indicies)
    # test multiple slur ending
    def test_multiple_slur_ending(self):
        measure = self.song.get_measure(2)
        slur_indicies = measure.get_slur_indicies()
        self.assertIn([0, 2], slur_indicies) 
        self.assertIn([1, 2], slur_indicies) 
    # test slur across multiple notes
    def test_slur_across_multiple_notes(self):
        measure = self.song.get_measure(3)
        slur_indicies = measure.get_slur_indicies()
        self.assertIn([0, 3], slur_indicies) 

if __name__ == '__main__':
    unittest.main()