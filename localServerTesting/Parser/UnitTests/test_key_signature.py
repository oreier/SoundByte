# Key signature unit tests
# Author: Cade LaVanchy
import unittest
import parser

class TestKeySignature(unittest.TestCase):
    # import custom test file for time signatures as setup
    def setUp(self):
       file_path = 'CustomUnitTestFiles/Test_Key_Signature.mxl' 
       mxl = parser.MusicXML(file_path)
       measures = mxl.part_wise()
       self.song = parser.Song(measures)
    # test circle of fifths functionality
    def test_circle_of_fifths(self):
        # test zero for major and minor scales
        self.assertEqual(parser.Measure.circle_of_fifths(parser.Measure, 0, 'major'), 'C')
        self.assertEqual(parser.Measure.circle_of_fifths(parser.Measure, 0, 'minor'), 'Am')
        # test scales for specific major and minor
        self.assertEqual(parser.Measure.circle_of_fifths(parser.Measure, 5, 'major'), 'B')
        self.assertEqual(parser.Measure.circle_of_fifths(parser.Measure, -3, 'major'), 'Eb')
        self.assertEqual(parser.Measure.circle_of_fifths(parser.Measure, 2, 'minor'), 'Bm')
        self.assertEqual(parser.Measure.circle_of_fifths(parser.Measure, -2, 'minor'), 'Gm')
        # test scales for overlapping major and minor
        self.assertEqual(parser.Measure.circle_of_fifths(parser.Measure, 6, 'major'), 'F#')
        self.assertEqual(parser.Measure.circle_of_fifths(parser.Measure, -6, 'major'), 'Gb')
        self.assertEqual(parser.Measure.circle_of_fifths(parser.Measure, 6, 'minor'), 'D#m')
        self.assertEqual(parser.Measure.circle_of_fifths(parser.Measure, -6, 'minor'), 'Ebm')
    # test no sharps of flats for major scale
    def test_C(self):
        measure = self.song.get_measure(0)
        self.assertEqual(measure.get_key(), 'C')
    # test 1 sharp
    def test_G(self):
        measure = self.song.get_measure(1)
        self.assertEqual(measure.get_key(), 'G')
    # test 2 sharps
    def test_D(self):
        measure = self.song.get_measure(2)
        self.assertEqual(measure.get_key(), 'D')
    # test 3 sharps
    def test_A(self):
        measure = self.song.get_measure(3)
        self.assertEqual(measure.get_key(), 'A')
    # test 4 sharps
    def test_E(self):
        measure = self.song.get_measure(4)
        self.assertEqual(measure.get_key(), 'E')
    # test 5 sharps
    def test_B(self):
        measure = self.song.get_measure(5)
        self.assertEqual(measure.get_key(), 'B')
    # test 6 sharps
    def test_F_sharp(self):
        measure = self.song.get_measure(6)
        self.assertEqual(measure.get_key(), 'F#')
    # test 7 sharps
    def test_C_sharp(self):
        measure = self.song.get_measure(7)
        self.assertEqual(measure.get_key(), 'C#')
    # test 1 flat
    def test_F(self):
        measure = self.song.get_measure(8)
        self.assertEqual(measure.get_key(), 'F')
    # test 2 flats
    def test_B_flat(self):
        measure = self.song.get_measure(9)
        self.assertEqual(measure.get_key(), 'Bb')
    # test 3 flats
    def test_E_flat(self):
        measure = self.song.get_measure(10)
        self.assertEqual(measure.get_key(), 'Eb')
    # test 4 flats
    def test_A_flat(self):
        measure = self.song.get_measure(11)
        self.assertEqual(measure.get_key(), 'Ab')
    # test 5 flats
    def test_D_flat(self):
        measure = self.song.get_measure(12)
        self.assertEqual(measure.get_key(), 'Db')
    # test 6 flats
    def test_G_flat(self):
        measure = self.song.get_measure(13)
        self.assertEqual(measure.get_key(), 'Gb')
    # test 6 flats
    def test_C_flat(self):
        measure = self.song.get_measure(14)
        self.assertEqual(measure.get_key(), 'Cb')
    

if __name__ == '__main__':
    unittest.main()