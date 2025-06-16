# Clef unit tests
# Author: Cade LaVanchy
import unittest
import parser

class TestClefType(unittest.TestCase):
    # test treble clef
    def test_treble(self):
       file_path = 'CustomUnitTestFiles/Treble_Clef_Test.mxl' 
       mxl = parser.MusicXML(file_path)
       measures = mxl.part_wise()
       song = parser.Song(measures)
       self.assertEqual('treble', song.get_clef())
    # test bass clef
    def test_bass(self):
       file_path = 'CustomUnitTestFiles/Bass_Clef_Test.mxl' 
       mxl = parser.MusicXML(file_path)
       measures = mxl.part_wise()
       song = parser.Song(measures)
       self.assertEqual('bass', song.get_clef())
    # test baritone-c clef
    def test_baritone_c(self):
       file_path = 'CustomUnitTestFiles/Baritone-c_Clef_Test.mxl' 
       mxl = parser.MusicXML(file_path)
       measures = mxl.part_wise()
       song = parser.Song(measures)
       self.assertEqual('baritone-c', song.get_clef())
    # test french clef
    def test_french(self):  
       file_path = 'CustomUnitTestFiles/French_Clef_Test.mxl' 
       mxl = parser.MusicXML(file_path)
       measures = mxl.part_wise()
       song = parser.Song(measures)
       self.assertEqual('french', song.get_clef())
    # test soprano clef
    def test_soprano(self): 
       file_path = 'CustomUnitTestFiles/Soprano_Clef_Test.mxl' 
       mxl = parser.MusicXML(file_path)
       measures = mxl.part_wise()
       song = parser.Song(measures)
       self.assertEqual('soprano', song.get_clef())
    # test mezzo-soprano clef
    def test_mezzo_soprano(self):
       file_path = 'CustomUnitTestFiles/Mezzo-Soprano_Clef_Test.mxl' 
       mxl = parser.MusicXML(file_path)
       measures = mxl.part_wise()
       song = parser.Song(measures)
       self.assertEqual('mezzo-soprano', song.get_clef())
    # test alto clef
    def test_alto(self):
       file_path = 'CustomUnitTestFiles/Alto_Clef_Test.mxl' 
       mxl = parser.MusicXML(file_path)
       measures = mxl.part_wise()
       song = parser.Song(measures)
       self.assertEqual('alto', song.get_clef())
       # test tenor clef
    def test_tenor(self):
       file_path = 'CustomUnitTestFiles/Tenor_Clef_Test.mxl' 
       mxl = parser.MusicXML(file_path)
       measures = mxl.part_wise()
       song = parser.Song(measures)
       self.assertEqual('tenor', song.get_clef())
    # test baritone-f clef
    def test_baritone_f(self):
       file_path = 'CustomUnitTestFiles/Baritone-f_Clef_Test.mxl' 
       mxl = parser.MusicXML(file_path)
       measures = mxl.part_wise()
       song = parser.Song(measures)
       self.assertEqual('baritone-f', song.get_clef())
   # test percussion clef
    def test_percussion(self):
       file_path = 'CustomUnitTestFiles/Unpitched_Note_Test.mxl' 
       mxl = parser.MusicXML(file_path)
       measures = mxl.part_wise()
       song = parser.Song(measures)
       self.assertEqual('percussion', song.get_clef())
   # test tablature clef
    def test_tablature(self):
       file_path = 'CustomUnitTestFiles/Test_Tablature_Clef.mxl' 
       mxl = parser.MusicXML(file_path)
       measures = mxl.part_wise()
       song = parser.Song(measures)
       self.assertEqual('tab', song.get_clef())
    
if __name__ == '__main__':
    unittest.main()