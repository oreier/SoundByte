import math
import re
import numpy as np

A4 = 440
C0 = A4*pow(2, -4.75)
all_sharp = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
all_flat = ["C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"]

frequencies_C2_to_C5 = np.array([65.40639132514966, 73.41619197935188, 82.40688922821748, 87.30705785825096, 97.99885899543733, 109.99999999999999, 123.47082531403102, 
                                 130.8127826502993, 146.83238395870376, 164.81377845643496, 174.6141157165019, 195.99771799087466, 219.99999999999997, 246.94165062806204, 
                                 261.6255653005986, 293.66476791740763, 329.62755691286986, 349.22823143300394, 391.9954359817492, 439.99999999999994, 493.8833012561242, 
                                 523.2511306011972, 587.3295358348153, 659.2551138257397, 698.4564628660079, 783.9908719634984, 879.9999999999999, 987.7666025122484])

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
        
def cents_off (f1):
   f2 = min(frequencies_C2_to_C5, key=lambda x: abs(x - f1))
   return 1200 * math.log2(f2 / f1)

def sharp_or_flat (freq):
    cents = cents_off(freq)
    if cents < 0:
        flat = 1
    else:
        flat = 0
    return flat


#Levels of in Tune measured in Cents away from "perfect"
#1. 2-4   : Perfect              #59933e
#2. 5-12  : Is it cold outside?  #659126
#3. 13-25 : Eep                  #988200
#4. 26-45 : Ow                   #c16d00
#5. 46-99 : Whole different note #ff0000
def in_tune(freq):
    cents = abs(cents_off(freq))
    if cents < 4:
        return("\033[32m" + "♪ In Tune ♪ \033[0m")
    elif cents < 13:
        return("\033[33m" + "♪ Out of Tune ♪ \033[0m")
    elif cents < 26:
        return("\033[31m" + "♪ Really Out of Tune ♪ \033[0m")
    elif cents < 99:
        return("\033[35m" + "♪ :( ♪ \033[0m")

