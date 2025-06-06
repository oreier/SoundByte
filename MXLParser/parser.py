import zipfile
import xml.etree.ElementTree as ET
import json
from decimal import Decimal, getcontext
from lxml import etree

major_sharp = ['C', 'G', 'D', 'A', 'E', 'B','F#','C#']
major_flat = ['C', 'F', 'Bb', 'Eb', 'Ab', 'Db', 'Gb']
minor_sharp = ['Am', 'Em', 'Bm', 'F#m', 'C#m', 'G#m', 'D#m', 'A#m']
minor_flat = ['Am', 'Dm', 'Gm', 'Cm', 'Fm', 'Bbm', 'Ebm']

clef = {
    "G": "treble",
    "F": "bass",
    "C": "alto",
    "T": "tenor"
}

rest_placement = {
    'whole': 'd4',      
    'half': 'b4',        
    'quarter': 'b4',    
    'eighth': 'b4',
    '16th': 'b4',
    '32nd': 'b4',
    '64th': 'b4',
    '128th': 'b4'
}

note_abbriviations = {
    'whole': 'w',      
    'half': 'h',        
    'quarter': 'q',    
    'eighth': '8',
    '16th': '16',
    '32nd': '32',
    '64th': '64',
    '128th': '128'
}

class MusicXML:
    # Constructor: unizps the mxl file and sets up the element tree from the internal score xml file 
    # parameters:
    # -file_path: the name/location of the file
    def __init__(self, file_path):
        self.file_path = file_path
        # error for invalid file types
        if not file_path.lower().endswith('.mxl'):
            raise ValueError("Invalid file type! Expected a .mxl file.")
        # open compressed zip file structure
        with zipfile.ZipFile(file_path, 'r') as mxl:
            # find the content musicxml file
            xml_file_name = self.find_main_musicxml(mxl)
            # parse the xml file and store the root and tree in private instance variables
            with mxl.open(xml_file_name) as xml_file:
                self.tree = ET.parse(xml_file)
                self.root = self.tree.getroot()
                if self.root.tag == 'score-partwise':
                    self.id = self.get_part_id()
                    return
                elif self.root.tag == 'score-timewise':
                    # load and parse conversion XSLT
                    xslt = etree.parse('parttime.xsl')
                    transform = etree.XSLT(xslt)
                    new_tree = transform(etree.parse(xml_file))
                    
                    # Apply the transformation
                    new_tree.write('timewise_to_partwise.musicxml', pretty_print=True, xml_declaration=True, encoding='UTF-8')
                    
                    # update root and tree to reflect converted file
                    with mxl.open('timewise_to_partwise.musicxml') as converted_file:
                        self.tree = ET.parse(converted_file)
                        self.root = self.tree.getroot()
                    
        self.id = self.get_part_id()
    
    def find_main_musicxml(self, zip_file: zipfile.ZipFile) -> str:
        # try getting the gile path from container.xml first
        try:
            with zip_file.open("META-INF/container.xml") as f:
                tree = ET.parse(f)
                rootfile = tree.find('.//rootfile')
                if rootfile is not None:
                    return rootfile.attrib['full-path']
        except KeyError:
            pass # container.xml not found
        
        #Fallback: look for .xml or .musicxml at root
        for name in zip_file.namelist():
            if name.endswith(('.xml', '.musicxml')):
                return name
        
        raise ValueError("No calid MusicXML found in archive.")
    
   # get_measures: returns all measures nodes and their child elements
    def get_measures(self):
        measures = self.root.findall('.//measure')
        # print(len(measures))
        return measures
    
    # returns the measures for a mxl file that is structured partwise
    def part_wise(self):
        measures = []
        for part in self.root.findall('.//part'):
            if part.get('id') == self.id:
                for measure in part.findall('.//measure'):
                    measures.append(measure)
        return measures
    
    # returns the vocal part id of a ong by checking for lyrics
    def get_part_id(self):
        if self.root.tag == 'score-partwise':
            for part in self.root.findall('.//part'):
                if len(part.findall('.//lyric')) != 0:
                    return part.get('id')
        # add functionality for timewise
        elif self.root.tag == 'score-timewise':
            return
            
    def get_root(self):
        return self.root.tag
   
   # returns a select number of elements
    def print_all(self):
        count = 0
        for elem in self.root.iter():
            if elem.text and elem.text.strip():
                text = elem.text.strip()
            else:
                text = "None"
            if count > 200:
                break
           
            print(f"Tag: {elem.tag}, Text: {text}, Attributes: {elem.attrib}")
            count += 1
     
class Song:
    def __init__(self, measures):
        self.measures = []
        first_measure = True
        for measure in measures:
            if first_measure == True:
                new_measure = Measure(measure, divisions=None)
                self.measures.append(new_measure)
                self.divisions = new_measure.get_divisions()
                first_measure = False
                continue
            if len(measure.findall('.//divisions')) > 0:
                new_measure = Measure(measure, divisions=None)
                self.measures.append(new_measure)
            else:
                new_measure = Measure(measure, self.divisions)
                self.measures.append(new_measure)
    
            if not new_measure.get_divisions():
                new_measure.set_divisions(self.divisions)
                    
        self.clef = self.measures[0].get_clef()
        self.divisions = self.measures[0].get_divisions()
        self.time_sig = self.measures[0].get_time()
   
    def parse_notes(self):
        for measure in self.measures:
            divisions = measure.get_divsions()
            if divisions != None:
                self.divisions = divisions
            measure.parse_notes(divisions)
   
    def print_notes(self):
        for measure in self.measures:
            for note in measure.get_notes():
                print(note.get_note())
            print()
    def get_clef(self):
        return self.clef
    def get_time(self):
        return self.time_sig
    def get_measures(self):
        return self.measures
    def get_measure(self, index):
        return self.measures[index]
            
    
    def to_dict(self):
        return {
            'song': {
                'clef': self.clef,
                'time_sig': self.time_sig,
                'measures': [measure.to_dict() for measure in self.get_measures()]
            }
        }
    
    def save_to_file(self, filename='output.json'):
        with open(filename, 'w') as file:
            json.dump(self.to_dict(), file, indent=4)
    
    def print_measure(self, index):
        measure = self.measures[index]
        measure.print_measure_detail()

class Note_Group:
    def __init__(self, notes, is_beamed, is_tuplet):
        self.notes = notes
        self.notes_string = ', '.join([note.get_note() for note in self.notes])
        self.is_beamed = is_beamed
        self.is_tuplet = is_tuplet
                
    def get_notes_string(self):
        return self.notes_string
    
    def get_is_beamed(self):
        return self.is_beamed
    
    def get_is_tuplet(self):
        return self.is_tuplet
    
    def to_dict(self):
        return {
                    "notes": self.get_notes_string(),
                    "is_beamed": self.get_is_beamed(),
                    "is_tuplet": self.get_is_tuplet()
                }
   
           
class Measure:
    def __init__(self, measure, divisions):
        self.divisions = divisions
        self.measure_tree = measure
        self.number = self.measure_tree.get('number')
        self.parse_attributes(self.measure_tree)
        self.parse_notes(self.divisions)
        self.group_notes()
        self.slur_indices = []
        self.determine_slur_indices()
       
    def parse_attributes(self, measure):
        if measure.find('attributes') is not None:
            attributes = measure.find('attributes')
       
            if attributes.find('divisions') is not None:
                self.divisions = attributes.find('divisions').text
       
            if attributes.find('key') is not None:
                fifth = attributes.find('key').find('fifths').text
                if attributes.find('key').find('mode') is not None:
                    mode = attributes.find('key').find('mode').text
                else:
                    mode = 'major'
                self.key = circle_of_fifths(fifth, mode)
            else:
                self.key = None
       
            if attributes.find('time') is not None:
                self.time = f'{attributes.find('time').find('beats').text}/{attributes.find('time').find('beat-type').text}'
            else:
                self.time = None
           
            if attributes.find('clef') is not None:
                sign = attributes.find('clef').find('sign').text
                if attributes.find('clef').find('line') is not None:
                    line =attributes.find('clef').find('line').text
                else:
                    line = None
                self.clef = self.get_clef_name(sign, line)
            else:
                self.clef = None
            
        else:
            self.key = None
            self.time = None
            self.clef = None
   
    def parse_clef(self, sign):
        for key, value in clef.items():
            if sign == key:
                return value
        return None
    
    def get_clef_name(self, clef_sign, clef_line):
        clef_line = int(clef_line)
        if clef_sign == 'G':
            if clef_line == 2:
                return 'treble'
            elif clef_line == 1:
                return 'french'
        elif clef_sign == 'F':
            if clef_line == 4:
                return 'bass'
            elif clef_line == 3:
                return 'baritone-f'
        elif clef_sign == 'C':
            if clef_line == 1:
                return 'soprano'
            elif clef_line == 2:
                return 'mezzo-soprano'
            elif clef_line == 3:
                return 'alto'
            elif clef_line == 4:
                return 'tenor'
            elif clef_line == 5:
                return 'baritone-c'
        return 'treble'
   
    def parse_notes(self, division):
        self.notes = []
        counter = 0
        for note in self.measure_tree.findall('./note'):
            if note.find('grace') is not None:
                continue
            counter += 1
            self.notes.append(Note(note, division))
    
    def group_notes(self):
        self.note_groups = []
        length =len(self.notes)
        counter = 0
        while counter < length:

            note = self.notes[counter]
            if note.get_is_beam():
                num, status = note.get_beam_info()
                if num == '1' and status == 'begin':
                    counter = self.create_beam_group(counter, length)
            else:
                counter = self.create_note_group(counter, length)
            
            
    
    def create_beam_group(self, counter, length):
        group = []
        while counter < length:
            note = self.notes[counter]
            num, status = note.get_beam_info()
            if num == '1':
                if status == 'begin':
                    group.append(note)
                elif status == 'continue':
                    group.append(note)
                else:
                    group.append(note)
                    counter += 1
                    if note.get_is_tuplet() == True:
                        self.note_groups.append(Note_Group(group, is_beamed=True, is_tuplet=True))
                        return counter
                    else:    
                        self.note_groups.append(Note_Group(group, is_beamed=True, is_tuplet=False))
                        return counter
            counter += 1
    
    def create_note_group(self, counter, length):
        group = []
        while counter < length:
            note = self.notes[counter]
            is_beam = note.get_is_beam()
            if not is_beam:
                 group.append(note)
            else:
                self.note_groups.append(Note_Group(group, is_beamed=False, is_tuplet=False))
                return counter
            counter += 1   
        self.note_groups.append(Note_Group(group, is_beamed=False, is_tuplet=False))
        return counter    
    
    def determine_slur_indices(self):
        visited = set()  # To avoid matching the same slur twice

        for first_index, note in enumerate(self.notes):
            if note.get_is_slur():
                for slur in note.get_slurs():
                    if slur.get_type() == 'start':
                        slur_number = slur.get_number()
                        if (slur_number, 'start', first_index) in visited:
                            continue
                        visited.add((slur_number, 'start', first_index))

                    # Now find the matching 'stop'
                        for second_index in range(first_index + 1, len(self.notes)):
                            next_note = self.notes[second_index]
                            if next_note.get_is_slur():
                                for next_slur in next_note.get_slurs():
                                    
                                    if next_slur.get_type() == 'stop' and next_slur.get_number() == slur_number:
                                        if (slur_number, 'stop', second_index) not in visited:
                                            visited.add((slur_number, 'stop', second_index))
                                            self.slur_indices.append([first_index, second_index])
                                            break
                                else:
                                    continue
                                break
                    
   
    def get_notes(self):
        return self.notes
   
    def get_clef(self):
        return self.clef
   
    def get_key(self):
        return self.key
   
    def get_time(self):
        return self.time
   
    def get_divisions(self):
        return self.divisions
    
    def set_divisions(self, divisions):
        self.divisions = divisions
    
    def get_notes_string(self):
        return ', '.join([note.get_note() for note in self.notes])
   
    def get_attributes(self):
        return f'{self.number}, {self.clef}, {self.divisions}, {self.key}, {self.time}'
    
    def get_slur_indicies(self):
        return self.slur_indices
    
    def to_dict(self):
        return  {
        'time_sig': self.time,
        'key_sig': self.key,
        'note_groups': [note_group.to_dict() for note_group in self.note_groups],
        'slur_indices': self.slur_indices,
        "measure_number": self.number,
        'divisions': self.divisions

        }
    
    def print_measure_detail(self):
        for elem in self.measure_tree.iter():
            text = elem.text.strip() if elem.text and elem.text.strip() else "None"
            print(f"Tag: {elem.tag}, Text: {text}, Attributes: {elem.attrib}")
            
    def print_note_groups(self):
        for note_group in self.note_groups:
            print(note_group.get_notes_string())
   
class Note:
    def __init__(self, note, division):
        self.divisions = division
        if note.find('rest') is not None:
            self.note = self.parse_rest(note)
            self.is_beam = False
            self.is_slur = False
            self.is_rest = True
        else:
            self.is_rest = False
            self.note = self.parse_note(note)
       
        if len(note.findall('dot')) > 0:
            self.dots = len(note.findall('dot'))
            self.concatenate_dot(len(note.findall('dot')))
        else:
            self.dots = 0
           
    def parse_rest(self, note):
        if len(note.findall('dot')) > 0:
            self.dots = len(note.findall('dot'))
        else:
            self.dots = 0
        self.is_rest = True
        duration = note.find('duration').text
        self.type = self.get_note_type(duration)
        return self.concatenate_rest(self.type)
       
    def parse_note(self, note):
        duration = note.find('duration').text
        self.type = self.get_note_type(duration)
        step = note.find('pitch').find('step').text
        octave = note.find('pitch').find('octave').text
        if note.find('pitch').find('accidental') is not None:
            accidental = note.find('pitch').find('accidental').text
        else:
            accidental = None
        if len(note.findall('beam')) > 0:
            self.is_beam = True
            self.parse_beams(note.findall('beam'))
        else:
            self.is_beam = False
        if note.find('notations') is not None:
            if note.find('notations').find('tuplet') is not None:
                self.is_tuplet = True
            else:
                self.is_tuplet = False
            if len(note.find('notations').findall('slur')) > 0:
                self.slurs = []
                slurs = note.find('notations').findall('slur')
                for slur in slurs:
                    slur_type = slur.attrib.get('type')
                    slur_number = slur.attrib.get('number', '1')
                    self.slurs.append(Slur(slur_number, slur_type))
                self.is_slur = True
            else:
                self.is_slur = False
            
        else:
            self.is_tuplet = False
            self.is_slur = False
        return self.concatenate_note(type, octave, accidental, step)
    
    def parse_beams(self, beams):
        self.beams = []
        for beam in beams:
            beam_status = beam.text
            beam_num_dict = beam.attrib
            beam_num = beam_num_dict['number']
            self.beams.append(Beam(beam_status, beam_num))
           
    def concatenate_rest(self, type):
        for key, value in rest_placement.items():
            if key == type:
                placement = value
        for key, value in note_abbriviations.items():
            if key == type:
                abbriviation = value
        return f'{placement}/{abbriviation}/r'
   
    def concatenate_note(self, type, octave, accidental, step):
        abbriviation = 'q'
        for key, value in note_abbriviations.items():
            if key == type:
                abbriviation = value
        if accidental is not None:
            if accidental == 'sharp':
                return f'{step.lower()}#{octave}/{abbriviation}'
            elif accidental == 'flat':
                return f'{step.lower()}b{octave}/{abbriviation}'
            elif accidental == 'natural':
                return f'{step.lower()}n{octave}/{abbriviation}'
        else:
            return f'{step.lower()}{octave}/{abbriviation}'
   
    def concatenate_dot(self, size):
        for dot in range(size):
            self.note = self.note + '.'
    
    def get_note_type(self, duration):
        getcontext().prec = 100
    # Calculate duration in quarter notes
        quarter_units = Decimal(duration) / Decimal(self.divisions)
        
        if quarter_units >= 4:
            return 'whole'
        elif quarter_units >= 2:
            return 'half'
        elif quarter_units >= 1:
            return 'quarter'
        elif quarter_units >= 0.5:
            return 'eighth'
        elif quarter_units >= 0.25:
            return '16th'
        elif quarter_units >= 0.125:
            return '32nd'
        elif quarter_units >= 0.0625:
            return '64th'
        elif quarter_units >= 0.03125:
            return '128th'
   
    def get_note(self):
        return self.note
    
    def get_type(self):
        return self.type
    
    def get_beam_info(self):
        for beam in self.beams:
            if beam.get_num() == '1':
                return beam.get_num(), beam.get_status()               
    
    def get_is_beam(self):
        return self.is_beam
    
    def get_is_tuplet(self):
        return self.is_tuplet
    
    def get_is_slur(self):
        return self.is_slur
    
    def get_slurs(self):
        return self.slurs
    
    def get_is_rest(self):
        return self.is_rest

       
class Beam:
    def __init__(self, beam_status, beam_num):
        self.status = beam_status
        self.num = beam_num

    def get_status(self):
        return self.status
    
    def get_num(self):
        return self.num
   
    def get_begin(self):
        return self.is_begin
   
    def get_end(self):
        return self.is_end

class Slur:
    def __init__(self, number, type):
        self.number = number
        self.type = type
    
    def get_number(self):
        return self.number
    
    def get_type(self):
        return self.type

def circle_of_fifths(fifth, mode):
    fifth = int(fifth)
    if mode == 'major':
        if fifth >= 0:
            return major_sharp[fifth]
        elif fifth < 0:
            return major_flat[abs(fifth)]
    elif mode == 'minor':
        if fifth >= 0:
            return minor_sharp[fifth]
        elif fifth < 0:
            return minor_flat[abs(fifth)]
       
       
       
   
if __name__ == "__main__":
    mxl_path = 'take_me_to_church.mxl'
    mxl = MusicXML(mxl_path)
    measures = mxl.part_wise()
    song = Song(measures)
    song.save_to_file()