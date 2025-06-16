import unittest
import parser

class TestLyrics(unittest.TestCase):
     # import and parse test lyrics mxl file
    def setUp(self):
       file_path = 'UnitTestFiles/take_me_to_church.mxl' 
       mxl = parser.MusicXML(file_path)
       measures = mxl.part_wise()
       self.song = parser.Song(measures)
    # test notes with no lyrics
    def test_no_lyrics(self):
        measure = self.song.get_measure(0)
        note = measure.get_notes()[0]
        self.assertEqual("", note.get_lyric())
    # test notes with basic lyrics
    def test_basic_lyrics(self):
        measure = self.song.get_measure(0)
        note = measure.get_notes()[1]
        self.assertEqual("My", note.get_lyric())
    # test notes with syllabic lyrics
    def test_syllabic_lyrics(self):
        measure = self.song.get_measure(0)
        note = measure.get_notes()[2]
        self.assertIn("-", note.get_lyric())

if __name__ == '__main__':
    unittest.main()