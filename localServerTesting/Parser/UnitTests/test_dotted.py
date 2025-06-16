# Dotted notes unit tests
# Author: Cade LaVanchy
import unittest
import parser

class TestDotted(unittest.TestCase):
    # test single dot
    def test_single_dot(self):
       file_path = 'UnitTestFiles/Ave_Maria.mxl' 
       mxl = parser.MusicXML(file_path)
       measures = mxl.part_wise()
       song = parser.Song(measures)
       measure = song.get_measure(12)
       self.assertIn('.', measure.get_notes()[0].get_note())
       self.assertIn('.', measure.get_notes()[0].get_abbriviation())
    # test double dot
    def test_double_dot(self):
       file_path = 'UnitTestFiles/Ave_Maria.mxl' 
       mxl = parser.MusicXML(file_path)
       measures = mxl.part_wise()
       song = parser.Song(measures)
       measure = song.get_measure(12)
       self.assertIn('..', measure.get_notes()[3].get_note())
       self.assertIn('..', measure.get_notes()[3].get_abbriviation())
    
    def test_dotted_rest(self):
       file_path = 'CustomUnitTestFiles/Dotted_Rest_Test.mxl' 
       mxl = parser.MusicXML(file_path)
       measures = mxl.part_wise()
       song = parser.Song(measures)
       measure = song.get_measure(0)
       self.assertIn('.', measure.get_notes()[0].get_note())
       self.assertIn('.', measure.get_notes()[0].get_abbriviation())

if __name__ == '__main__':
    unittest.main()