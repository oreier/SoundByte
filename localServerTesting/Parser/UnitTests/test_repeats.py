# Repeats unit tests
# Author: Cade LaVanchy
import unittest
import parser

class TestRepeats(unittest.TestCase):
    def setUp(self):
    # import and parse test repeats mxl file
      file_path = 'CustomUnitTestFiles/Repeats_Test.mxl'
      mxl = parser.MusicXML(file_path)
      measures = mxl.part_wise()
      self.song = parser.Song(measures)
    
    # test a end repeat
    def test_repeat_end(self):
        measure = self.song.get_measure(3)
        repeat_start = measure.get_is_repeat_start()
        repeat_end = measure.get_is_repeat_end()
        self.assertTrue(repeat_end)
        self.assertFalse(repeat_start)
    
    # test a start repeat
    def test_repeat_start(self):
        measure = self.song.get_measure(2)
        repeat_start = measure.get_is_repeat_start()
        repeat_end = measure.get_is_repeat_end()
        self.assertTrue(repeat_start)
        self.assertFalse(repeat_end)
    
    # test measure with both a repeat start and end
    def test_both_repeats(self):
        measure = self.song.get_measure(11)
        repeat_start = measure.get_is_repeat_start()
        repeat_end = measure.get_is_repeat_end()
        self.assertTrue(repeat_start)
        self.assertTrue(repeat_end)
        


if __name__ == '__main__':
    unittest.main()
        