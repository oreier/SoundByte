# Time signature unit tests
# Author: Cade LaVanchy
import unittest
import parser

class TestTimeSignature(unittest.TestCase):
    # import custom test file for time signatures as setup
    def setUp(self):
       file_path = 'CustomUnitTestFiles/Time_Signature_Test.mxl' 
       mxl = parser.MusicXML(file_path)
       measures = mxl.part_wise()
       self.song = parser.Song(measures)
    
    # test 4/4 time
    def test_4_4(self):
        measure = self.song.get_measure(0)
        self.assertEqual('4/4', measure.get_time())
    # test 2/4 time
    def test_2_4(self):
        measure = self.song.get_measure(1)
        self.assertEqual('2/4', measure.get_time())
    # test 3/4 time
    def test_3_4(self):
        measure = self.song.get_measure(2)
        self.assertEqual('3/4', measure.get_time())
    # test 5/4 time
    def test_5_4(self):
        measure = self.song.get_measure(3)
        self.assertEqual('5/4', measure.get_time())
    # test 6/4 time
    def test_6_4(self):
        measure = self.song.get_measure(4)
        self.assertEqual('6/4', measure.get_time())
    # test 3/8 time
    def test_3_8(self):
        measure = self.song.get_measure(5)
        self.assertEqual('3/8', measure.get_time())
    # test 4/8 time
    def test_4_8(self):
        measure = self.song.get_measure(6)
        self.assertEqual('4/8', measure.get_time())
    # test 5/8 time
    def test_5_8(self):
        measure = self.song.get_measure(7)
        self.assertEqual('5/8', measure.get_time())
    # test 6/8 time
    def test_6_8(self):
        measure = self.song.get_measure(8)
        self.assertEqual('6/8', measure.get_time())
    # test 7/8 time
    def test_7_8(self):
        measure = self.song.get_measure(9)
        self.assertEqual('7/8', measure.get_time())
    # test 9/8 time
    def test_9_8(self):
        measure = self.song.get_measure(10)
        self.assertEqual('9/8', measure.get_time())
    # test 12/8 time
    def test_12_8(self):
        measure = self.song.get_measure(11)
        self.assertEqual('12/8', measure.get_time())
    # test 2/2 time
    def test_2_2(self):
        measure = self.song.get_measure(14)
        self.assertEqual('2/2', measure.get_time())
    # test 2/2 time
    def test_2_2(self):
        measure = self.song.get_measure(15)
        self.assertEqual('2/2', measure.get_time())
    # test 3/2 time
    def test_3_2(self):
        measure = self.song.get_measure(16)
        self.assertEqual('3/2', measure.get_time())
    # test 4/2 time
    def test_4_2(self):
        measure = self.song.get_measure(17)
        self.assertEqual('4/2', measure.get_time())
    # test common time
    def test_common(self):
        measure = self.song.get_measure(12)
        self.assertEqual('C', measure.get_time())
    # test cut time
    def test_cut(self):
        measure = self.song.get_measure(13)
        self.assertEqual('C|', measure.get_time())
    
    # test total beats
    def test_total_beats(self):
        self.assertEqual(self.song.total_beats(), 133)

if __name__ == '__main__':
    unittest.main()
    