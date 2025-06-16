# Ties unit tests
# Author: Cade LaVanchy
import unittest
import parser

class TestTies(unittest.TestCase):
     # import and parse test ties mxl file
    def setUp(self):
       file_path = 'CustomUnitTestFiles/Test_Ties.mxl' 
       mxl = parser.MusicXML(file_path)
       measures = mxl.part_wise()
       self.song = parser.Song(measures)
    # test tie at the beginning of a measure
    def test_ties_at_measure_start(self):
        measure = self.song.get_measure(0)
        tie_indicies = measure.get_slur_indicies()
        self.assertIn([0, 1], tie_indicies)
    # test tie at end of measure
    def test_ties_at_measure_end(self):
        measure = self.song.get_measure(0)
        tie_indicies = measure.get_slur_indicies()
        self.assertIn([2, 3], tie_indicies)
    # test tie at middle of measure
    def test_ties_at_measure_middle(self):
        measure = self.song.get_measure(1)
        tie_indicies = measure.get_slur_indicies()
        self.assertIn([1, 2], tie_indicies)
    # test tie inbetween measures
    def test_ties_between_measures(self):
        measure_one = self.song.get_measure(2)
        tie_indicies_one = measure_one.get_slur_indicies()
        self.assertIn([3, None], tie_indicies_one)


    
if __name__ == '__main__':
    unittest.main()