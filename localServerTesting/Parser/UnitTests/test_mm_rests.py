# Multi Measure Rests unit tests
# Author: Cade LaVanchy
import unittest
import parser

class TestMMRests(unittest.TestCase):
    def setUp(self):
    # import and parse test multi measure rests mxl file
       file_path = 'CustomUnitTestFiles/Test_MM_Rests.mxl'
       mxl = parser.MusicXML(file_path)
       measures = mxl.part_wise()
       self.song = parser.Song(measures)
    
    # test multi measure rest value
    def test_mm_rest_value(self):
        measure = self.song.get_measure(0)
        mm_rest = int(measure.get_measure_rests())
        self.assertEqual(2, mm_rest)
    
    # test skipping duplicate measures to account for multi measure rests
    def test_mm_rest_jumps(self):
        measure = self.song.get_measure(4)
        mm_rest = int(measure.get_measure_rests())
        measure_number = int(measure.get_measure_number())
        next_measure = self.song.get_measure(5)
        next_measure_number = int(next_measure.get_measure_number())
        self.assertEqual(3, mm_rest)
        self.assertEqual(6, measure_number)
        self.assertEqual(9, next_measure_number)
    
    # test number of measures
    def test_mm_rest_measure_num(self):
        measures = self.song.get_measures()
        self.assertEqual(29, len(measures))
    
    # test total beats are accurate with measure trim due to mm rests
    def test_mm_rest_total_beats(self):
        beats = self.song.get_total_beats()
        self.assertEqual(128, beats)

if __name__ == '__main__':
    unittest.main()