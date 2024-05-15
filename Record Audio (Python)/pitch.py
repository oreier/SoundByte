import math
import re

A4 = 440
C0 = A4*pow(2, -4.75)
all_sharp = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
all_flat = ["C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"]

"""
C_major, A_minor= []
#Sharp Keys
# Fat Cats Go Down Alleys Eating Birds
G_major, E_minor= []
D_major, B_minor = []
A_major, F_sharp_minor = []
E_major, C_sharp_minor = []
B_major, G_sharp_minor = []
F_sharp_major, D_sharp_minor = []
C_sharp_major, A_sharp_minor = []
#Flat Keys
# B.E.A.D Girls Can Fight
F_major, D_flat_minor = []
B_flat_major, G_minor = []
E_flat_major, C_minor = []
A_flat_major, F_minor = []
D_flat_major, B_flat_minor = []
G_flat_major, E_flat_minor = []
C_flat_major, A_flat_minor = []
"""

#Returns the closest pitch
#Arguments: int freqency, key (defaults to all sharps)
#Returns string
def freq_to_pitch(freq, key=all_sharp):
    h = round(12*math.log2(freq/C0))
    octave = h // 12
    n = h % 12
    return key[n] + str(octave)

def pitch_to_freq(pitch):
    #Check if pitch passed in is in correct format
    match = re.match(r'([A-G][#b]?+)(\d+)',pitch)
    if match:
        note = match.group(1)
        octave = match.group(2)
        index = find_pitch_index(note)
        if index != -1:
            return C0 * (2 ** ((index + int(octave) * 12) / 12))
        else:
            print ("Improper format")
    else:
        print ("Improper format")

def find_pitch_index(pitch):
    try:
        index = all_sharp.index(pitch)
        return index
    except ValueError:
        try:
            index = all_flat.index(pitch)
            return index
        except ValueError:
            return -1