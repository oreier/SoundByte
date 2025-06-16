# MXL Parser
# Author: Cade LaVanchy

# used to break down the compressed zip structure of a .mxl file
import zipfile
# used to store the elements of a xml style document in a n-ary tree
import xml.etree.ElementTree as ET
# used to write the output to a json file
import json
# used to ensure precision when calculating note type based on duration, especially when there are dots envolved
from decimal import Decimal, getcontext
# used for error message handling
import sys
# used for list type enforcement
from typing import List, Tuple

# Arrays to store all of the key signatures for the circle of fifths
major_sharp = ['C', 'G', 'D', 'A', 'E', 'B','F#','C#']
major_flat = ['C', 'F', 'Bb', 'Eb', 'Ab', 'Db', 'Gb', 'Cb']
minor_sharp = ['Am', 'Em', 'Bm', 'F#m', 'C#m', 'G#m', 'D#m', 'A#m']
minor_flat = ['Am', 'Dm', 'Gm', 'Cm', 'Fm', 'Bbm', 'Ebm', 'Abm']

# a dictonary to determin a rests placement of the staff if not given within a note element
rest_placement = {
    'whole': 'd5',      
    'half': 'b4',        
    'quarter': 'b4',    
    'eighth': 'b4',
    '16th': 'b4',
    '32nd': 'b4',
    '64th': 'b4',
    '128th': 'b4'
}

# a dictonary to convert the mxl note types to abbrivation for the render
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

# a dictonary to convert mxl accidental notation to render comatible notation
accidental = {
    'sharp':'#',
    'flat': 'b',
    'natural': 'n',
    'double-sharp': '##',
    'flat-flat': 'bb',
    'natural-sharp': 'n#',
    'natural-flat': 'nb',
    'triple-sharp': '###',
    'triple-flat': 'bbb'
}

# a dictonary to map a clef given a symbol and line
clef_map = {
    'G': {2: 'treble', 1: 'french'},
    'F': {4: 'bass', 3: 'baritone-f'},
    'C': {
        1: 'soprano',
        2: 'mezzo-soprano',
        3: 'alto',
        4: 'tenor',
        5: 'baritone-c'
    }
}

# a dictonary to map a clef given only the symbol
default_clefs = {
                'G': 'treble',
                'F': 'bass',
            'C': 'alto',
            'percussion': 'percussion',
            'TAB': 'tab'
        }

# MusicXML Class
# Purpose: Unzip mxl structure and sotre xml stle elements into a n-ary tree
class MusicXML:
    # Constructor: unizps the mxl file and sets up the element tree from the internal score xml file 
    # parameters:
    # -file_path: the name/location of the file
    def __init__(self, file_path: str):
        self.file_path = file_path

        # ensure the correct file extention is inputed
        if not file_path.lower().endswith('.mxl'):
            raise ValueError("Invalid file type! Expected a .mxl file.")
        # try to unzip file and determine part id
        try:
            with zipfile.ZipFile(file_path, 'r') as mxl:
                try:
                    # Attempt to find the main XML file
                    xml_file_name = self.find_main_musicxml(mxl)
                except (KeyError, ET.ParseError) as e:
                    print(f"Error finding main MusicXML file: {e}", file=sys.stderr)
                    raise

                try:
                    with mxl.open(xml_file_name) as xml_file:
                        self.tree = ET.parse(xml_file)
                        self.root = self.tree.getroot()
                        if self.root.tag == 'score-partwise':
                            self.id = self.determine_part_id()
                except (KeyError, ET.ParseError) as e:
                    print(f"Error parsing MusicXML content: {e}", file=sys.stderr)
                    raise

        except zipfile.BadZipFile:
            print("Error: The provided file is not a valid ZIP archive.", file=sys.stderr)
            raise
        except FileNotFoundError:
            print(f"Error: File not found: {file_path}", file=sys.stderr)
            raise

    # find_main_musicxml: find the main xml/musicxml file within the zipfile structure
    # parameters:
    # -zip_file: the corresponding mxl zipfile
    def find_main_musicxml(self, zip_file: zipfile.ZipFile) -> str:
        # try getting the file path from container.xml first
        try:
            with zip_file.open("META-INF/container.xml") as f:
                tree = ET.parse(f)
                rootfile = tree.find('.//rootfile')
                if rootfile is not None:
                    return rootfile.attrib['full-path']
        # except erros for container not found or errors parsing the file
        except KeyError as e:
            print(f"Error: the container.xml not found in the MXL archive. {e}", file=sys.stderr)
        except ET.ParseError as e:
            print(f"Error: container.xml is malformed or not readable. {e}", file=sys.stderr)
        
        #Fallback: look for .xml or .musicxml at root
        for name in zip_file.namelist():
            if name.endswith(('.xml', '.musicxml')):
                return name
        
        raise ValueError("No valid MusicXML found in archive.")
    
    # part_wise: returns the measures for a mxl file that is structured partwise
    def part_wise(self):
        measures = []
        # iterate through all parts in the sheet music and return the part that has lyrics
        for part in self.root.findall('.//part'):
            if part.get('id') == self.id:
                for measure in part.findall('.//measure'):
                    measures.append(measure)
        return measures
    
    # determine_part_id: returns the vocal part id of a song by checking for lyrics
    def determine_part_id(self):
        if self.root.tag == 'score-partwise':
            for part in self.root.findall('.//part'):
                if len(part.findall('.//lyric')) != 0:
                    return part.get('id')
        # add functionality for timewise
        elif self.root.tag == 'score-timewise':
            return
            
    def get_root(self):
        return self.root.tag

# Song Class
# Purpose: store music measures and song specific data   
class Song:
    # Constructor: converts mxl measure to measure objects and stores song data
    # parameters:
    # -measures: a list of measure element trees
    def __init__(self, measures: List[ET.Element]):
        self.measures: List[Measure] = [] # List to store Measure objects
        first_measure = True # flag to handle the first measure differently
        
        # Looop through all measure XML elements
        for measure in measures:
            if first_measure:
                # First Measure: initiate all values that need to be cascaded to future measures
                new_measure = Measure(measure, divisions=None)
                self.measures.append(new_measure)
                self.divisions = new_measure.get_divisions()
                first_measure = False
                continue
            # For all other measures:
            # if the measure defines a new divisions, create a measure that doesnt pass in the cascading value of divisions and update the divisons element for future measures
            if len(measure.findall('.//divisions')) > 0:
                new_measure = Measure(measure, divisions=None)
                self.divisions = new_measure.get_divisions()
                self.measures.append(new_measure)
            else:
            # Otherwise, use the exisitng divisions from previous measures
                new_measure = Measure(measure, self.divisions)
                self.measures.append(new_measure)
        # Extract song scope data from the first measure           in 
        self.clef = self.measures[0].get_clef()
        self.time_sig = self.measures[0].get_time()
        
        self.account_for_measure_rests() # adjust for mm rests
        self.beats = self.total_beats() # compute the total beats in the song
    
    # total_beats: calculate the total beats of a song, accounting for mm rests
    def total_beats(self):
        total_beats = 0
        # iterate through all measures and add the beats based on time signature
        for measure in self.measures:
            time = measure.get_time()
            beat = 4  # default to 4 beats per measure (4/4)

            if time:
                # account for time signature that are not fractional
                if time == 'C':
                    beat = 4
                elif time == 'C|':
                    beat = 2
                else:
                    # calculate beats based on fractional time signature, accounting for time signatures like 6/8 and 7/8
                    try:
                        numerator, _ = map(int, time.split('/'))
                        beat = numerator 
                    except ValueError:
                        pass  # fallback to default if time is malformed
            
            # account for mm rests and add the beats for how many measures the rest lasts for
            mm_rest_num = int(measure.get_measure_rests())
            if mm_rest_num > 1:
                total_beats += mm_rest_num * beat
            else:
                total_beats += beat

        return total_beats
    
    # account_for_measure_rests: trim down the duplicate measures caused by mm rest measures            
    def account_for_measure_rests(self):
        temp_measure_list = []
        i = 0
        # iterate through all measurse and add to a temp list
        while i < len(self.measures):
            multi_measure_rests = int(self.measures[i].get_measure_rests())
            temp_measure_list.append(self.measures[i])
            # if there a mm rests then skip those measure bys updating the index accordingly
            if multi_measure_rests > 1:
                i += multi_measure_rests
            else:
                i += 1
        # set the new measure list to the existing private variables    
        self.measures = temp_measure_list

    # to_dict: format classes private variables for JSON file
    def to_dict(self):
        return {
            'song': {
                'clef': self.clef,
                'time_sig': self.time_sig,
                'total_beats': self.beats,
                'key_sig': None,
                'measures': [measure.to_dict() for measure in self.get_measures()]
            }
        }
    
    # save_to_file: save dictonary representation of container classes to a json output
    def save_to_file(self, filename='output.json'):
        # encoding must be utf-8 and ensure_ascii is set to false to ensure special characters in lyrics are represented accurately
        with open(filename, 'w', encoding="utf-8") as file:
            json.dump(self.to_dict(), file, indent=4, ensure_ascii=False)
    
    # getters for private variables       
    def get_clef(self):
        return self.clef
    
    def get_time(self):
        return self.time_sig
    
    def get_measures(self):
        return self.measures
    
    def get_measure(self, index):
        return self.measures[index]
    
    def get_total_beats(self):
        return self.beats

# Note Class
# Purpose: store note data   
class Note:
    # Constructor: converts mxl note to a note object
    # parameters:
    # -note: a note element tree
    # -division: the divisions defined by the measure
    # -duration: the duration of a note (for grace notes) if not given
    def __init__(self, note: ET.ElementTree, division: int, duration: int):
        # define private variable
        self.duration = 0
        self.dots = 0
        self.is_tuplet = False
        self.is_pitched = False
        self.is_unpitched = False
        self.is_rest = False
        self.is_beam = False
        self.is_slur = False
        self.is_tie = False
        self.type = ''
        self.abbriviation = ''
        self.lyric_text = ''
        self.accidental = ''
        self.step = ''
        self.octave = ''
        self.divisions = division
        self.tuplet_type = None
        self.beams: List[Beam] = []
        self.slurs: List[Slur] = []
        self.ties: List[Tie] = []
        self.is_grace = note.find('grace') is not None
        # set duration for grace ntoes
        if self.is_grace == True:
            self.duration = duration
        # determine how many dots are attached to the note
        if len(note.findall('dot')) > 0:
            self.dots = len(note.findall('dot'))
        # update private varirables if a note is a rest
        if note.find('rest') is not None:
            self.is_rest = True
        self.note_string = self.parse_note(note)
                
    # parse_note: store relevent note data from element tree into private variables  
    # parameters:
    # - note: element tree of a note 
    def parse_note(self, note: ET.ElementTree):
        # determine duration of note
        if note.find('duration') is not None:
            self.duration = note.find('duration').text
            
        # determine type of note if given, else derive type from duration of note
        if note.find('type') is not None:
            self.type = note.find('type').text
        else:
            self.type = self.determine_note_type()
            
        # determine the step and octave of note based on if its a pitched, unpitched, or rest note
        if note.find('pitch') is not None:
            self.is_pitched = True
            self.step = note.find('pitch/step').text
            self.octave = note.find('pitch/octave').text
        elif note.find('unpitched') is not None:
            self.is_unpitched = True
            self.step = note.find('unpitched/display-step').text
            self.octave = note.find('unpitched/display-octave').text
        elif self.is_rest:
            # the display step and octave are not gaurenteed to exist so fallback to a predetermined placement based on rest_placement dictonary
            if note.find('rest/display-step') is not None and note.find('rest/display-octave') is not None:
                self.step = note.find('rest/display-step').text
                self.octave = note.find('rest/display-octave').text
            else:
                for key, value in rest_placement.items():
                    if key == self.type:
                        placement = list(value)
                self.step = placement[0]
                self.octave = placement[1]
        
        # determine the accidental of the note if there is one        
        if note.find('accidental') is not None:
            self.accidental = note.find('accidental').text
        # determine if a note is beamed and store beam objects in an array
        if len(note.findall('beam')) > 0:
            self.is_beam = True
            self.parse_beams(note.findall('beam'))
        
        if note.find('notations') is not None:
            # determine if a note is within a tuplet 
            if note.find('notations').find('tuplet') is not None:
                self.is_tuplet = True
                self.tuplet_type = note.find('notations').find('tuplet').attrib.get('type')

            # determine if a note is slured and store slur objects to reflect how many slurs a note is apart of
            if len(note.find('notations').findall('slur')) > 0:
                self.slurs = []
                slurs = note.find('notations').findall('slur')
                for slur in slurs:
                    slur_type = slur.attrib.get('type')
                    slur_number = slur.attrib.get('number', '1')
                    self.slurs.append(Slur(slur_number, slur_type))
                self.is_slur = True
            
            # determine if a note is tied and if its tied to more than one note (rarely) and store the Tie objects accordingly    
            if len(note.find('notations').findall('tied')) > 0:
                self.ties = []
                ties = note.find('notations').findall('tied')
                for tie in ties:
                    tie_type = tie.attrib.get('type')
                    tie_number = tie.attrib.get('number', '1')
                    self.ties.append(Tie(tie_number, tie_type))
                self.is_tie = True
            
        # tuplets can also be determined by the time-modification element but so are tremolos which arent supported
        # So check if time modification exists but tremolo element doesnt to ensure the time modificaiton relates to a tuplet
        has_time_mod = note.find('time-modification') is not None
        has_tremolo = note.find('.//tremolo') is not None

        if has_time_mod and not has_tremolo:
            self.is_tuplet = True
        
        # determine lyrics and accound for syllabic or elision tags
        lyric_parts = []
        if len(note.findall('lyric')) > 0:
            for lyric in note.findall('lyric'):
                text_el = lyric.find('text')
                if text_el is not None and text_el.text:
                    text = text_el.text.replace("’", "'")
                    syllabic_el = lyric.find('syllabic')
                    elision = lyric.find('elision') is not None

                    # Add dash if it's begin or middle syllable
                    if syllabic_el is not None:
                        syllabic = syllabic_el.text
                        if syllabic in ('begin', 'middle'):
                            text += '-'  # hyphen at the end
                    if elision:
                        text += '--'  # or '--' if you prefer
                    lyric_parts.append(text)
        else:
            lyric_parts = ''
        # Join final lyric string
        self.lyric_text = ''.join(lyric_parts)
        
        # return the note string after all private variables have been determined
        return self.concatenate_note()

    # parse_beams: iterate through an array of beams and create beam objects to store relevent information  
    # parameters:
    # - beams: element tree of a beam element
    def parse_beams(self, beams: ET.Element):
        self.beams = []
        for beam in beams:
            beam_status = beam.text
            beam_num_dict = beam.attrib
            beam_num = beam_num_dict['number']
            self.beams.append(Beam(beam_status, beam_num))
   
    # concatenate_note: create the note string format used by the render
    def concatenate_note(self):
        # determine note abbrivation based on type, if unsupported type, default to quarter note
        self.abbriviation = note_abbriviations.get(self.type, 'q')
        # if the note is a rest create string to format to render differently
        if self.is_rest:
            # create the format with the dots at the end of the note string for render special rest case but change the self.abbriviation to include the dot for consistancy with regular notes   
            note_string = f'{self.step.lower()}{self.octave}/{self.abbriviation}/r'
            for _ in range(self.dots):
                note_string += '.'

            for _ in range(self.dots):
                self.abbriviation += '.' 

            return note_string
        # if note is not a rest, create string to standard render specifications
        for _ in range(self.dots):
            self.abbriviation += '.'
        if self.accidental is not None:
            render_accidental_notation = accidental.get(self.accidental, '')
            note_string = f'{self.step.lower()}{render_accidental_notation}{self.octave}/{self.abbriviation}'
        else:
            note_string = f'{self.step.lower()}{self.octave}/{self.abbriviation}'
        return note_string
    
    # determine_note_type: determines the type of note based on note duration
    # parameter:
    # - duration: the duration of the note
    def determine_note_type(self):
        # set the precision of the decimal object to ensure there are no rounding errors
        getcontext().prec = 100
    # Calculate duration in quarter notes
        quarter_units = Decimal(self.duration) / Decimal(self.divisions)
        
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
    
    # private variables getters
    def get_note(self):
        return self.note_string
    
    def get_type(self):
        return self.type
    
    def get_lyric(self):
        return self.lyric_text
    
    def get_beam_info(self):
        for beam in self.beams:
            if beam.get_num() == '1':
                return beam.get_num(), beam.get_status()           
    
    def get_is_beam(self):
        return self.is_beam
    
    def get_is_tuplet(self):
        return self.is_tuplet
    
    def get_tuplet_type(self):
        return self.tuplet_type
    
    def get_is_slur(self):
        return self.is_slur
    
    def get_slurs(self):
        return self.slurs
    
    def get_is_tie(self):
        return self.is_tie
    
    def get_ties(self):
        return self.ties
    
    def get_is_rest(self):
        return self.is_rest
    
    def get_is_pitched(self):
        return self.is_pitched
    
    def get_is_unpitched(self):
        return self.is_unpitched
    
    def get_abbriviation(self):
        return self.abbriviation
         
# Note_Group Class
# Purpose: store groups of notes based on certain flags  
class Note_Group:
    # Constructor: store note objects in groups
    # parameters:
    # -notes: array of note objects
    # -is_beamed: flag for beamed group of notes
    # -is_tuplet: flag for tuplet group of notes
    def __init__(self, notes: List[Note], is_beamed, is_tuplet):
        self.notes = notes
        self.notes_string = ', '.join([note.get_note() for note in self.notes])
        self.is_beamed = is_beamed
        self.is_tuplet = is_tuplet
    
    # to_dict: format classes private variables for JSON file
    def to_dict(self):
        return {
                    "notes": self.get_notes_string(),
                    "is_beamed": self.get_is_beamed(),
                    "is_tuplet": self.get_is_tuplet()
                }
    
    # private variable getters            
    def get_notes_string(self):
        return self.notes_string
    
    def get_is_beamed(self):
        return self.is_beamed
    
    def get_is_tuplet(self):
        return self.is_tuplet
    
    def get_notes(self):
        return self.notes
   
# Measure Class
# Purpose: store groups of notes based on certain flags            
class Measure:
    # Constructor: store notes and measure specific data
    # parameters:
    # -measure: element tree of a measure element
    # -divisons: the divisions of a measure, is null for this measure, take on the cascading value from previous measures
    def __init__(self, measure: ET.Element, divisions):
        self.divisions = divisions
        self.measure_tree: ET.ElementTree = measure
        self.measure_number = self.measure_tree.get('number')
        self.measure_rests = 0
        self.is_repeat_end = False
        self.is_repeat_start = False
        self.clef = ''
        self.dynamics: List[List[Tuple[int, str]]] = [] # [note_idx, dynamic_type], not an explict tuple but the inner arrays will only ever hold those two values in those positions
        self.grace_notes: List[Tuple[Note, int]] = [] # [grace_note_obj, index of note its tied to], not an explicit tuple but will always contain those values in the same order
        self.hairpins: List[Tuple[int, int, str]] = [] # List of [start_index, end_index, type], not an explicit tuple but will always contain those values in the same order
        self.note_groups: List[Note_Group] = []
        self.notes: List[Note] = []
        self.slur_indices: List[Tuple[int, int]] = [] # [start_idx, end_idx], not an explicit tuple but will always contain those values in the same order
        self.key = None
        self.time = None
        # determine measure data
        self.parse_attributes()
        # initialize note objects
        self.parse_notes()
        # group notes based on beams or tuplets
        self.group_notes()
        # determine other attributes of the measure tied to the notes
        self.determine_slur_indices()
        self.determine_tie_indices()
        # determine attributes of a measure that are not found within the attributes element of the measure tree
        self.determine_dynamics()
        self.determine_hairpins()
        self.determine_repeats()
    
    # parse_attributes: store measure data in private variables  
    def parse_attributes(self):
        
        if self.measure_tree.find('attributes') is not None:
            attributes = self.measure_tree.find('attributes')
            
            # determine the divisions of the measure
            if attributes.find('divisions') is not None:
                self.divisions = attributes.find('divisions').text
                
            # determine the key signature of the measure
            if attributes.find('key') is not None:
                fifth = attributes.find('key').find('fifths').text
                if attributes.find('key').find('mode') is not None:
                    mode = attributes.find('key').find('mode').text
                else:
                    mode = 'major'
                self.key = self.circle_of_fifths(fifth, mode)
                
            # determine the time signature of the measure
            if attributes.find('time') is not None:
                self.time = self.determine_time(attributes.find('time'))
                
            # determine the clef of the measure
            if attributes.find('clef') is not None:
                sign = attributes.find('clef').find('sign').text
                if attributes.find('clef').find('line') is not None:
                    line = attributes.find('clef').find('line').text
                else:
                    line = None
                self.clef = self.determine_clef_name(sign, line)
            
            # determine any mm rests
            if attributes.find('measure-style/multiple-rest') is not None:
                self.measure_rests = attributes.find('measure-style/multiple-rest').text
    
    # determine_time: determien the time signature of the measure
    # parameters:
    # time: a time element within the attributes element
    def determine_time(self, time: ET.Element):
        # get the beats and beat_type for time signature fraction
        beats = time.find('beats').text
        beat_type = time.find('beat-type').text
        # find the symbol that determines the type of time signature and output the signature based on the symbol
        if  time.attrib.get('symbol') is not None:
            symbol = time.attrib.get('symbol')
            if symbol == 'normal':
                return f'{beats}/{beat_type}'
            elif symbol == 'common':
                return 'C'
            elif symbol == 'cut':
                return 'C|'
        else:
            # if the symbol attribute is not present, the default is a normal fractional time signature
            return f'{beats}/{beat_type}'
        
    # determine_clef_name: determine clef from symbol and line attributes
    # parameters:
    # - clef_sign: the mxl symbol for a clef
    # - clef_line: the mxl line associated with the clef
    def determine_clef_name(self, clef_sign, clef_line):
        # if the clef line is psesent match the clef to the clef_map dictonary, default to treble if clef unsupported
        if clef_line is not None:
            clef_line = int(clef_line)
            if clef_sign in clef_map and clef_line in clef_map[clef_sign]:
                return clef_map[clef_sign][clef_line]
            elif clef_sign == 'percussion':
                return 'percussion'
            elif clef_sign == 'TAB':
                return 'tab'
            return 'treble'
        else:
            # if the line isnt present match the clef to the default_clefs dictonary, default to treble if clef unsupported
            return default_clefs.get(clef_sign, 'treble')
    # parse_notes: construct the note objects accounting for grace notes
    def parse_notes(self):

        # temp note variables to store grace notes
        grace_note_before = None
        grace_note_after = None
        # index for grace ntoes
        last_main_note_index = None

        # iterate through notes and create note objects
        for note in self.measure_tree.findall('./note'):
            # if a grace note is found, determine if the note it is tied to is before or after the grace note
            if note.find('grace') is not None:
                tied = note.find('notations/tied')
                tied_type = tied.attrib.get('type') if tied is not None else None

                if tied_type == 'start':
                    # Grace note before the current note
                    grace_note_before = note
                elif tied_type == 'stop':
                    # Grace note after the previous main note
                    grace_note_after = note
                else:
                    # Fallback: treat as grace before
                    grace_note_before = note
                continue

            # Regular note
            current_duration = note.find('duration').text
            main_note_index = len(self.notes)

            # Handle grace note before
            if grace_note_before is not None:
                grace_note_obj = Note(grace_note_before, self.divisions, current_duration)
                self.grace_notes.append([grace_note_obj, main_note_index])
                grace_note_before = None

            # Create and store main note
            self.notes.append(Note(note, self.divisions, current_duration))

            # Handle grace note after
            if grace_note_after is not None and last_main_note_index is not None:
                grace_note_obj = Note(grace_note_after, self.divisions, current_duration)
                self.grace_notes.append([grace_note_obj, last_main_note_index])
                grace_note_after = None

            last_main_note_index = main_note_index

    # group_notes: group notes based on if theya are beamed, tupleted or neither
    def group_notes(self):
        # define the parameters of the measure
        length =len(self.notes)
        counter = 0
        # counter is updated at the return of each of the three different fuction calls
        while counter < length:
            note = self.notes[counter]
            # if the note is beamed get beam info and only create the group if its the first beam
            if note.get_is_beam():
                num, _ = note.get_beam_info()
                if num == '1':
                    counter = self.create_beam_group(counter, length)
            elif note.get_is_tuplet():
                # if the note is a tuplet create a note group for all notes in the tuplet
                counter = self.create_tuplet_group(counter, length)
            else:
                # if the note is apart of no group then create a standard note group object
                counter = self.create_note_group(counter, length)
    
    # create_tuplet_group: create a note group with all notes from the tuplet
    # parameters:
    # - counter: the current counter of the group_notes function
    # - length: the length of the notes array
    def create_tuplet_group(self, counter, length):
        # create temp array to hold group of notes
        group = []
        # flag to determine that the notes appended are not the start or stop of the tuplet
        inside_tuplet = False
        # iterate through the notes in the array left of from the group_notes function
        while counter < length:
            note: Note = self.notes[counter]
            # check the note is a tuplet and get the type
            if note.get_is_tuplet():
                tuplet_type = note.get_tuplet_type()
                # if note is a tuplet and is the start then set inside_tuplet to true to indicate the start of the tuplet group
                if tuplet_type == "start":
                    inside_tuplet = True
                # if the notes checked are in a tuplet then add the note to group and increment the counter accordingly
                if inside_tuplet:
                    group.append(note)
                    counter += 1
                # if the type is stop then the tuplet is complete
                    if tuplet_type == "stop":
                        break
                else:
                    # Skip tuplets that aren't marked as start — could be malformed or middle of group
                    break
            else:
                break
        # if the group isnt empty then create a Note_Group object and append to the note_groups private var
        if group:
            self.note_groups.append(Note_Group(group, is_beamed=False, is_tuplet=True))
        # return the counter to reflect the group added 
        return counter       
            
    # create_beam_group: group notes that are beamed and tupleted if neccisary. This function proitizes tuplets so a beamed group will be broken up into multiple if there is an overlapping tuplet (even if some of the notes are not beamed)
    # parameters:
    # - counter: the current counter of the group_notes function
    # - length: the length of the notes array
    def create_beam_group(self, counter, length):
        # create a temp group to hold beamed notes
        group = []
        
        # get the first note and check if its apart of a tuplet
        first_note = self.notes[counter]
        first_is_tuplet = first_note.get_is_tuplet()
        
        # add the first note to the group
        group.append(first_note)
        counter += 1

        # iterate through the remaining notes
        while counter < length:
            note = self.notes[counter]
            is_tuplet = note.get_is_tuplet()
            tuplet_type = note.get_tuplet_type()
            is_beamed = note.get_is_beam()

            if first_is_tuplet:
                # if the group starts with a tuplet, only add notes also in the tuplet
                if is_tuplet:
                    group.append(note)

                    # If this note ends the tuplet, break the loop
                    if tuplet_type == "stop":
                        counter += 1
                        break

                    counter += 1
                else:
                    # If a note is no longer part of the tuplet, end the group
                    break

            else:
                # If the group is not a tuplet, dont add tuplet notes to the group
                if is_tuplet:
                    break

                if is_beamed:
                    group.append(note)
                    
                    # Check beam status and end if the note is at the end of the beam
                    _, status = note.get_beam_info()
                    counter += 1
                    if status == 'end':
                        break
                else:
                    break
        # Append the note group with appropriate flags
        if len(group) <= 1:
            # Single note, not considered a beam group (edge case when a beamed group is mostly a tuplet group other than one note)
            self.note_groups.append(Note_Group(group, is_beamed=False, is_tuplet=first_is_tuplet))
        else:
            # proper beammed group
            self.note_groups.append(Note_Group(group, is_beamed=True, is_tuplet=first_is_tuplet))

        # return updated counter to continue parsing
        return counter
    
    # create_note_group: create a Note_Group object with notes not apart of a beam or tuplet
    # parameters:
    # - counter: the current counter of the group_notes function
    # - length: the length of the notes array
    def create_note_group(self, counter, length):
        # create temp group to store notes
        group = []
        # iterate through the remaining notes in the array
        while counter < length:
            note = self.notes[counter]
            is_beam = note.get_is_beam()
            is_tuplet = note.get_is_tuplet()
            # check that a note is not beamed or apart of a tuplet to add to the group
            if not is_beam and not is_tuplet:
                 group.append(note)
            else:
                # else stop the loop and return the current group
                self.note_groups.append(Note_Group(group, is_beamed=False, is_tuplet=False))
                return counter
            counter += 1
        # append the group of notes to the note_group private var       
        self.note_groups.append(Note_Group(group, is_beamed=False, is_tuplet=False))
        # return updated counter to continue parsing
        return counter    
    
    # determine_slur_indices: determine the indices of the notes that are slurred together
    def determine_slur_indices(self):
        # temp dictonary to store incomplete slurs until the closing note index is found
        open_slurs = {}  # slur_number -> first_index

        # iterate through the notes
        for index, note in enumerate(self.notes):
            # ignore notes that arent slurred
            if not note.get_is_slur():
                continue
            # iterate through all slurs a note has
            for slur in note.get_slurs():
                slur_number = slur.get_number() or "1"
                slur_type = slur.get_type()

                # if a note contains a slur type of start, add to the open_slurs dictonary
                if slur_type == "start":
                    open_slurs[slur_number] = index

                # if the note contains a slur type of stop remove the slur from the dictonary and append to the slur_indices private var
                elif slur_type == "stop":
                    start_index = open_slurs.pop(slur_number, None)
                    if start_index is not None:
                        self.slur_indices.append([start_index, index])

        # Any unmatched start slurs remain
        # for slur_number, start_index in open_slurs.items():
        #     self.slur_indices.append([start_index, None])
    
    # determine_tie_indices: determine the inices of the notes that are tied together
    # IMPORTANT: ties will be added to the slur_indices private var for render compliance
    def determine_tie_indices(self):
        # temp dictonary to store incomplete ties until the closing note index is found
        open_ties = {}  # tie_number -> first_index
        
        # iterate through the notes
        for index, note in enumerate(self.notes):
            if not note.get_is_tie():
                continue
            # iterate through all ties a note has (rarely more than one)
            for tie in note.get_ties():
                tie_number = tie.get_number() or "1"
                tie_type = tie.get_type()

                # if a note contains a tie type of start, add to the open_slurs dictonary
                if tie_type in ("start", "continue"):
                    # Overwrite existing start (if redefined)
                    open_ties[tie_number] = index
                    
                # if the note contains a slur type of stop remove the tie from the dictonary and append to the slur_indices private var
                elif tie_type == "stop":
                    start_index = open_ties.pop(tie_number, None)
                    if start_index is not None:
                        self.slur_indices.append([start_index, index])

        # Any leftover start with no stop
        for tie_number, start_index in open_ties.items():
            self.slur_indices.append([start_index, None])    

    # determine_dynamics: determine the dynamics found within the self.measure_tree and determine associated note indicies
    def determine_dynamics(self):
        elements: List[ET.Element] = list(self.measure_tree)

        # Build a list of all note elements and their positions in the element list
        note_positions = [i for i, el in enumerate(elements) if el.tag.lower().endswith("note")]
        dynamics_map = {}  # Maps note-relative index to dynamic string

        # iterate through all the elements in the measure tree
        for index, element in enumerate(elements):
            # if the element is dynamics then determine the type
            if element.tag.lower().endswith("direction"):
                dynamics_el = element.find(".//dynamics")
                if dynamics_el is not None and len(dynamics_el) > 0:
                    dyn_type = ''
                    # iterate through dynamics if more than one
                    for j in range(len(dynamics_el)):
                        # concatenate dynamics for complex dynamics
                        dyn_type += dynamics_el[j].tag.lower()
                    # if the dynamic is other than do not process (no support for other-dynamics)
                    if dyn_type == 'other-dynamics':
                        continue
                    # determine note index in the element tree list
                    note_xml_index = self.find_next_note_index(index, elements)
                    if note_xml_index is not None and note_xml_index in note_positions:
                        # convert note index from entire tree to the index of just notes
                        note_relative_index = note_positions.index(note_xml_index)
                        dynamics_map[note_relative_index] = dyn_type

        # Ensure every note from get_notes() has a dynamic, even if it's '' for render compliance
        for i in range(len(self.get_notes())):
            dyn = dynamics_map.get(i, '')
            self.dynamics.append([i, dyn])
    
    # determine_hairpins: determine the existance, type and note indices associated with hairpins
    def determine_hairpins(self):
        elements: List[ET.Element] = list(self.measure_tree)
        
        # Build a list of all note elements and their positions in the element list
        note_positions = [i for i, el in enumerate(elements) if el.tag.lower().endswith("note")]
        open_hairpin = None

        # iterate through all the elements in the measure tree
        for index, element in enumerate(elements):
            # if the element is a wedge (indicating a hairpin dynamic)
            if element.tag.lower().endswith("direction"):
                wedge_el = element.find(".//direction-type/wedge")
                # disregard elements that are not a wedge
                if wedge_el is None:
                    continue
                
                # get the type of wedge
                wedge_type = wedge_el.attrib.get("type", "").lower()

                # check to determine the wedge type
                if wedge_type in ("crescendo", "diminuendo"):
                    # determine index of note within the element tree of the measure
                    note_xml_index = self.find_next_note_index(index, elements)
                    if note_xml_index is not None:
                        try:
                            # determine note array relative index from note xml index
                            note_relative_index = note_positions.index(note_xml_index)
                            open_hairpin = [note_relative_index, 1 if wedge_type == "crescendo" else 2]
                        except ValueError:
                            continue  # Note not found
                elif wedge_type == "stop" and open_hairpin is not None:
                    # Prefer previous note (the one it most likely applies to)
                    note_xml_index = self.find_previous_note_index(index, elements)
                    if note_xml_index is None:
                    # Fallback to next note if nothing found before
                        note_xml_index = self.find_next_note_index(index, elements)

                    if note_xml_index is not None:
                        try:
                            # determine the note relative index for the closing index and add to hairpins private var
                            note_relative_index = note_positions.index(note_xml_index)
                            start_index, kind = open_hairpin
                            self.hairpins.append([start_index, note_relative_index, kind])
                            open_hairpin = None
                        except ValueError:
                            continue  # Couldn't resolve end note
    # find_next_note_index: helper function to determine next note index in measure element tree
    # paramters:
    # start_idx: starting index relative to the current location in the measure elements list
    # elements: a list of the measure element tree
    def find_next_note_index(self, start_idx, elements: List[ET.Element]):
        for i in range(start_idx + 1, len(elements)):
            if elements[i].tag.lower().endswith("note"):
                return i
        return None

    # find_previous_note_index: helper function to determine previous note index in measure element tree
    # paramters:
    # start_idx: starting index relative to the current location in the measure elements list
    # elements: a list of the measure element tree
    def find_previous_note_index(self, start_idx, elements: List[ET.Element]):
        for i in range(start_idx - 1, -1, -1):
            if elements[i].tag.lower().endswith("note"):
                return i
        return None 
    
    # determine_repeats: determine the existance of repeats in a measure
    def determine_repeats(self):
        elements: List[ET.Element] = list(self.measure_tree)
        
        # iterate through the elements of the measure tree
        for element in elements:
            repeat = element.findall('.//repeat')
            # if a repeat is found then determine the directon of them
            if repeat is not None and len(repeat) > 0:
                # iterate through all repeat objects and set the flag private vars accordingly
                for repeat_obj in repeat:
                    direction = repeat_obj.attrib.get('direction')
                    if direction == 'forward':
                        self.is_repeat_start = True
                    elif direction == 'backward':
                        self.is_repeat_end = True
    
    # circle_of_fifths: determines the key signature
    # parameters:
    # - fifth: int indicating how many sharps or flats (+ for sharps, - for flats)
    # - mode: string indicating major or minor
    def circle_of_fifths(self, fifth, mode):
        fifth = int(fifth)
        if mode == 'minor':
            if fifth >= 0:
                return minor_sharp[fifth]
            elif fifth < 0:
                return minor_flat[abs(fifth)]
        else:
            # if mode is major or unrecognized then default to major scale
            if fifth >= 0:
                return major_sharp[fifth]
            elif fifth < 0:
                return major_flat[abs(fifth)] 
                        
    # to_dict: format classes private variables for JSON file
    def to_dict(self):
        return  {
        'time_sig': self.time,
        'key_sig': self.key,
        'note_groups': [note_group.to_dict() for note_group in self.note_groups],
        'lyrics': self.lyrics_to_dict(),
        'grace_notes': self.grace_notes_to_dict(),
        'slur_indices': self.slur_indices,
        "is_repeat_start": self.is_repeat_start,
        "is_repeat_end": self.is_repeat_end,
        "hairpins": self.hairpins_to_dict(),
        "dynamics": self.dynamics_to_dict(),
        "measure_rests": self.measure_rests,
        "measure_number": self.measure_number,
        }
    
    # grace_notes_to_dict: format grace_notes private var for JSON file
    def grace_notes_to_dict(self):
        # temp array to hold dictonary format outputs
        grace_notes_output = []
        # iterate through grace ntoes
        for grace_note, tied_index in self.grace_notes:
            # get the (grace) note objects note string
            raw_note: Note = grace_note.get_note()

            # Separate pitch and octave from duration
            note_octave_part = raw_note.split("/")[0]

            # Separate pitch and accidetal from octave
            pitch = ""
            octave = ""

            # iterate over the note_octave_part to determine where the octave and sepearte the two parts 
            for char in note_octave_part:
                if char.isdigit():
                    octave += char
                else:
                    pitch += char

            # Combine in desired format for render: pitch/octave (e.g., b##/4, b/4)
            cleaned_note = f"{pitch}/{octave}"

            # Append the output to temp array
            # grace note duration hard coded to 8th note duration
            grace_notes_output.append({
                "keys": [cleaned_note],
                "duration": grace_note.get_abbriviation(),
                "index": tied_index
            })

        # return the array to the measure to_dict function
        return grace_notes_output
    
    # lyrics_to_dict: format the lyrics of the measure for JSON file
    def lyrics_to_dict(self):
        # temp array to hold formatted lyrics
        measure_lyrics = []
        # iterate through the note_groups
        for note_group in self.note_groups:
            # iterate through the notes in a note_group
            for note in note_group.get_notes():
                # format lyrics dependent on if the group is a tuplet or not for render compliance
                if note.get_is_tuplet() == True:
                    lyric_data = {
                        'text': note.get_lyric(),
                        'duration': note.get_abbriviation(),
                        'notes_in_tuplet': len(note_group.get_notes())
                    }
                else:
                    lyric_data = {
                        'text': note.get_lyric(),
                        'duration': note.get_abbriviation(),
                        'notes_in_tuplet': 0
                    }
                # append formatted output to temp array
                measure_lyrics.append(lyric_data)
        # return the array to the measure to_dict function
        return measure_lyrics
    
    # dynamics_to_dict: format dynamics for JSON file
    def dynamics_to_dict(self):
        # temp array to hold formatted dynamics
        measure_dynamics = []
        # iterate over all of the dynamics in the measure
        for dynamic in self.dynamics:
            # get the associated note and abbriviation from the dynamic
            note = self.notes[dynamic[0]]
            duration = note.get_abbriviation()
            # iterate over all note_groups in measure
            for note_group in self.note_groups:
                # iterate over the notes in the note_group
                for note_obj in note_group.get_notes():
                    # compare notes in note_group to the note tied to the dynamic to match the note to the group
                    if note == note_obj:
                        # determine the notes in the group if tuplet for render
                        if note.get_is_tuplet() == True:
                            notes_in_tuplet = len(note_group.get_notes())
                        else:
                            notes_in_tuplet = 0
            
            # format dynamic to match render compliance           
            dynamic_data = {
                'text': dynamic[1],
                'duration': duration,
                'notes_in_tuplet': notes_in_tuplet
            }
            # append formatted dynamic
            measure_dynamics.append(dynamic_data)
        # return the formatted dynamics ot the measure to_dict function
        return measure_dynamics    
    
    # hairpins_to_dict: format haipins for JSON file
    def hairpins_to_dict(self):
        # temp array to hold formatted hairpins
        measure_hairpins = []
        # iterate through all hairpins in the measure
        for hairpin in self.hairpins:
            # store the start, stop, and type of each hairpin
            start_idx = hairpin[0]
            end_idx = hairpin[1]
            hairpin_type = hairpin[2]
            # format hairpin data
            hairpin_data = {
                "start_index": start_idx,
                "end_index": end_idx,
                "type": hairpin_type
            }  
            # append hairpin data to temp array 
            measure_hairpins.append(hairpin_data)
        # return the formatted hairpins to measure to_dict function
        return measure_hairpins                 
                
    # private var getters and setters            
    def get_notes(self):
        return self.notes
    
    def get_grace_notes(self):
        return self.grace_notes
    
    def get_note_groups(self):
        return self.note_groups
   
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
    
    def get_slur_indicies(self):
        return self.slur_indices
    
    def get_dynamics(self):
        return self.dynamics
    
    def get_hairpins(self):
        return self.hairpins
    
    def get_is_repeat_start(self):
        return self.is_repeat_start
    
    def get_is_repeat_end(self):
        return self.is_repeat_end
    
    def get_measure_rests(self):
        return self.measure_rests
    
    def get_measure_number(self):
        return self.measure_number

# Beam Class
# Purpose: store note beam info 
class Beam:
    # Constructor: store beam data
    # parameters:
    # - beam_status: start, continue, or stop of the beam
    # - beam_num: the number of the beam
    def __init__(self, beam_status, beam_num):
        self.status = beam_status
        self.num = beam_num

    # private var getters
    def get_status(self):
        return self.status
    
    def get_num(self):
        return self.num

# Slur Class
# Purpose: store note slur info 
class Slur:
    # Constructor: store slur data
    # parameters:
    # - number: number of the slur
    # - type: start, continue, or stop of the slur
    def __init__(self, number, type):
        self.number = number
        self.type = type
    
    # private var getters
    def get_number(self):
        return self.number
    
    def get_type(self):
        return self.type

# Tie Class
# Purpose: store note slur info 
class Tie:
    # Constructor: store tie data
    # parameters:
    # - number: number of the tie
    # - type: start, continue, or stop of the tie
    def __init__(self, number, type):
        self.number = number
        self.type = type
    
    # private var getters
    def get_number(self):
        return self.number
    
    def get_type(self):
        return self.type 
       
       
# main: creates an mxl object based on a filepath and stores the measures from the mxl object into a Song object which then saves the song information to a file for the render
if __name__ == "__main__":
    mxl_path ='CustomUnitTestFiles/Grace_Notes_Test.mxl'
    mxl = MusicXML(mxl_path)
    measures = mxl.part_wise()
    song = Song(measures)
    song.save_to_file()