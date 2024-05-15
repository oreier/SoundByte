import numpy as np
import math
from pitch import pitch_to_freq
from WaveGenerator import generate_sine_wave
from WaveToWav import wave_to_wav


def read_song(input):
    f = open (input, "r")
    bpm = f.readline()
    notes = []
    for line in f:
        line = line.strip()
        if line:
            pitch,duration = line.split(", ")
            notes.append((pitch, float(duration)))
    song = []
    all_notes = []
    for i in range(len(notes)):
        dur = pow(int(bpm) / 60 * pow(float(notes[i][1]),-1),-1) # duration of note in seconds
        freq = pitch_to_freq(notes[i][0])
        wave = generate_sine_wave (duration = dur, frequency= freq)
        all_notes.append(wave)
    for note in all_notes:
        for element in note:
            song.append(element)

    song = np.array(song)
    wave_to_wav(song)
