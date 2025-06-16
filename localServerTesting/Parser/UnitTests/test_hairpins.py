# Hairpins unit tests
# Author: Cade LaVanchy
import unittest
import parser

class TestHairpins(unittest.TestCase):
    def setUp(self):
    # import and parse test dynamics mxl file
      file_path = 'CustomUnitTestFiles/Test_Hairpins.mxl'
      mxl = parser.MusicXML(file_path)
      measures = mxl.part_wise()
      self.song = parser.Song(measures)
      
    # test crecendo lasting the full measure
    def test_crecendo_full_measure(self):
        measure = self.song.get_measure(0)
        hairpins = measure.get_hairpins()
        hairpin = hairpins[0]
        start = hairpin[0]
        stop = hairpin[1]
        hairpin_type = hairpin[2]
        
        self.assertEqual(start, 0)
        self.assertEqual(stop, 3)
        self.assertEqual(hairpin_type, 1)
    
    # test diminuendo lasting the full measure
    def test_diminuendo_full_measure(self):
        measure = self.song.get_measure(1)
        hairpins = measure.get_hairpins()
        hairpin = hairpins[0]
        start = hairpin[0]
        stop = hairpin[1]
        hairpin_type = hairpin[2]
        
        self.assertEqual(start, 0)
        self.assertEqual(stop, 2)
        self.assertEqual(hairpin_type, 2)
    
    # test hairpins not lasting the full measure
    def test_hairpins_partial_measure(self):
        measure = self.song.get_measure(4)
        hairpins = measure.get_hairpins()
        hairpin = hairpins[0]
        start = hairpin[0]
        stop = hairpin[1]
        hairpin_type = hairpin[2]
        
        self.assertEqual(start, 1)
        self.assertEqual(stop, 2)
        self.assertEqual(hairpin_type, 1)
    
    # test multiple hairpins in a measure
    def test_multiple_hairpins(self):
        measure = self.song.get_measure(7)
        hairpins = measure.get_hairpins()
        self.assertEqual(2, len(hairpins))
    
    # test hairpins across measure (no functionality for this)
    def test_hairpins_across_measure(self):
        first_measure = self.song.get_measure(5)
        first_hairpins = first_measure.get_hairpins()
        second_measure = self.song.get_measure(6)
        second_hairpins = second_measure.get_hairpins()
        self.assertEqual(0, len(first_hairpins))
        self.assertEqual(0, len(second_hairpins))
    
    

if __name__ == '__main__':
    unittest.main()