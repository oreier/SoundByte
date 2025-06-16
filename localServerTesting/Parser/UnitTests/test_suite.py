# Complete Test Suite
# Author: Cade LaVanchy
import unittest
import test_note_type
import test_clef_type
import test_time_signature
import test_key_signature
import test_accidentals
import test_dotted
import test_unpitched_notes
import test_beamed
import file_tests
import test_ties
import test_slurs
import test_tuplets
import test_lyrics
import grace_notes_test
import test_dynamics
import test_hairpins
import test_repeats
import test_mm_rests
import test_note_groups

if __name__ == '__main__':
    loader = unittest.TestLoader()
    suite = unittest.TestSuite()
    
    suite.addTests(loader.loadTestsFromTestCase(test_note_type.TestNoteType))
    suite.addTests(loader.loadTestsFromTestCase(test_clef_type.TestClefType))
    suite.addTests(loader.loadTestsFromTestCase(test_time_signature.TestTimeSignature))
    suite.addTests(loader.loadTestsFromTestCase(file_tests.TestFileInput))
    suite.addTests(loader.loadTestsFromTestCase(test_key_signature.TestKeySignature))
    suite.addTests(loader.loadTestsFromTestCase(test_accidentals.TestAccidentals))
    suite.addTests(loader.loadTestsFromTestCase(test_dotted.TestDotted))
    suite.addTests(loader.loadTestsFromTestCase(test_unpitched_notes.TestUnpitched))
    suite.addTests(loader.loadTestsFromTestCase(test_beamed.TestBeams))
    suite.addTests(loader.loadTestsFromTestCase(test_ties.TestTies))
    suite.addTests(loader.loadTestsFromTestCase(test_slurs.TestSlurs))
    suite.addTests(loader.loadTestsFromTestCase(test_tuplets.TestTuplets))
    suite.addTests(loader.loadTestsFromTestCase(test_lyrics.TestLyrics))
    suite.addTests(loader.loadTestsFromTestCase(grace_notes_test.TestGraceNotes))
    suite.addTests(loader.loadTestsFromTestCase(test_dynamics.TestDymanics))
    suite.addTests(loader.loadTestsFromTestCase(test_hairpins.TestHairpins))
    suite.addTests(loader.loadTestsFromTestCase(test_repeats.TestRepeats))
    suite.addTests(loader.loadTestsFromTestCase(test_mm_rests.TestMMRests))
    suite.addTests(loader.loadTestsFromTestCase(test_note_groups.TestNoteGroups))
    
    
    runner = unittest.TextTestRunner(verbosity=2)
    runner.run(suite)