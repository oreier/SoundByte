# File unit tests
# Author: Cade LaVanchy

import unittest
import parser

class TestFileInput(unittest.TestCase):
    # test for valid extention
    def test_valid_mxl_extension(self):
        try:
            parser.MusicXML('UnitTestFiles/file.mxl')
        except ValueError:
            self.fail("MusicXML raised ValueError unexpectedly for valid .mxl extension.")
    # test invalid file extention
    def test_invalid_txt_extension(self):
        with self.assertRaises(ValueError) as context:
            parser.MusicXML('UnitTestFiles/testfile.txt')
        self.assertIn("Invalid file type", str(context.exception))
    # test invalid xml file extention
    def test_invalid_xml_extension(self):
        with self.assertRaises(ValueError) as context:
            parser.MusicXML('UnitTestFiles/testfile.xml')
        self.assertIn("Invalid file type", str(context.exception))
    # test valid hidden file extention
    def test_hidden_file_with_mxl(self):
        try:
            parser.MusicXML('UnitTestFiles/.hidden_file.mxl')
        except ValueError:
            self.fail("MusicXML raised ValueError unexpectedly for hidden .mxl file.")
    

if __name__ == "__main__":
    unittest.main()