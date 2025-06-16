# Note groups unit tests
# Author: Cade LaVanchy
import unittest
import parser

class TestNoteGroups(unittest.TestCase):
    # parse test beam file
    def setUp(self):
        file_path = 'CustomUnitTestFiles/Test_Beamed_and_Tuple_Notes.mxl' 
        mxl = parser.MusicXML(file_path)
        measures = mxl.part_wise()
        self.song = parser.Song(measures)
    # test a tuplet at the start of a group of beamed notes but doesnt fully incapsulate all beamed notes
    def test_tuplet_at_beam_start(self):
        measure = self.song.get_measure(0)
        note_groups = measure.get_note_groups()
        self.assertEqual(len(note_groups), 4)
    
    # test a tuplet at the end of a group of beamed notes but doesnt fully incapsulate all beamed notes
    def test_tuplet_at_beam_end(self):
        measure = self.song.get_measure(1)
        note_groups = measure.get_note_groups()
        self.assertEqual(len(note_groups), 3)
    
    # test a tuplet with beamed notes and a rest
    def test_tuplet_with_beam_and_rest(self):
        measure = self.song.get_measure(2)
        note_groups = measure.get_note_groups()
        note_group = note_groups[1]
        self.assertEqual(len(note_groups), 3)
        self.assertTrue(note_group.get_is_beamed())
        self.assertTrue(note_group.get_is_tuplet())
    
    # test a beamed group that would be split and leave one 'beamed' note by itself
    def test_single_beamed_note(self):
        measure = self.song.get_measure(3)
        note_groups = measure.get_note_groups()
        note_group = note_groups[0]
        self.assertEqual(len(note_groups), 3)
        self.assertFalse(note_group.get_is_beamed())
    
    # test a tuplet group with the first note being a rest followed by a beamed group of note
    def test_tuplet_with_rest_followed_by_beams(self):
        measure = self.song.get_measure(4)
        note_groups = measure.get_note_groups()
        note_group = note_groups[1]
        self.assertEqual(len(note_groups), 3)
        self.assertFalse(note_group.get_is_beamed())


if __name__ == '__main__':
    unittest.main()