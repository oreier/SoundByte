# Dynamics unit tests
# Author: Cade LaVanchy
import unittest
import parser

class TestDymanics(unittest.TestCase):
    def setUp(self):
    # import and parse test dynamics mxl file
      file_path = 'CustomUnitTestFiles/Test_Dynamics.mxl'
      mxl = parser.MusicXML(file_path)
      measures = mxl.part_wise()
      self.song = parser.Song(measures)
    
    # test dynamic paired to note at the beginning of a measure
    def test_dynamic_at_measure_start(self):
      measure = self.song.get_measure(0)
      dynamics = measure.get_dynamics()
      target_dynamic = dynamics[0]
      note_index = target_dynamic[0]
      dynamic_type = target_dynamic[1]
      self.assertEqual(0, note_index)
      self.assertEqual('p', dynamic_type)
      
    # test dynamic paired to note at the end of a measure
    def test_dynamic_at_measure_end(self):
      measure = self.song.get_measure(0)
      dynamics = measure.get_dynamics()
      target_dynamic = dynamics[3]
      note_index = target_dynamic[0]
      dynamic_type = target_dynamic[1]
      self.assertEqual(3, note_index)
      self.assertEqual('ppp', dynamic_type)
    
    # test dynamic paired to note at the middle of a measure
    def test_dynamic_at_measure_middle(self):
      measure = self.song.get_measure(7)
      dynamics = measure.get_dynamics()
      target_dynamic = dynamics[2]
      note_index = target_dynamic[0]
      dynamic_type = target_dynamic[1]
      self.assertEqual(2, note_index)
      self.assertEqual('sf', dynamic_type)
    
    # test unsupported dynamics
    def test_unsupported_dynamics(self):
      measure = self.song.get_measure(8)
      dynamics = measure.get_dynamics()
      target_dynamic = dynamics[2]
      note_index = target_dynamic[0]
      dynamic_type = target_dynamic[1]
      self.assertEqual(2, note_index)
      self.assertEqual('', dynamic_type)

if __name__ == '__main__':
    unittest.main()