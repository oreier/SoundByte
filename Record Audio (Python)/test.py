import matplotlib.pyplot as plt
import numpy as np
import colorlog
import logging
import math
from setupMicrophone import list_audio_devices, select_microphone
from recordAudio import record_audio
from WaveGenerator import generate_sine_wave
from WaveGenerator import generate_chord
from WaveToWav import wave_to_wav
from pitch import pitch_to_freq
from pitch import freq_to_pitch
from pitch import cents_off
from pitch import sharp_or_flat
from pitch import in_tune
from SongToWav import read_song
from WavToFreq import find_dominant_freq
from WavToFreq import find_frequencies
from WavToFreq import plot_freqs
from UnitTesting import main
from LoggingSetup import log_setup

def record_to_wave():
    device_index = select_microphone()
    output_filename = "recorded_audio.wav"
    record_audio(output_filename, device_index)
    print("Audio saved as:", output_filename)

def create_wav(freq=440):
    new_wave = generate_sine_wave(frequency=freq)
    wave_to_wav(new_wave)

def freq_to_wav (freq=440):
    return wave_to_wav(generate_sine_wave(freq), output_file="./test_output.wav")

def append_notes (wave1, wave2):
    return wave1 + wave2


def test_single_note():
    freq_to_wav(440)
    

def test_hot_cross_buns():
    read_song(output="./test_output.wav")


def test_off_pitch():
    pitches = []
    pitches.append(append_notes(append_notes(append_notes(freq_to_wav(444),freq_to_wav(450)),freq_to_wav(460)),freq_to_wav(470)))
    pitches = np.array(pitches)
    wave_to_wav(output_file="./test_output.wav")

if __name__ == "__main__":
    log_setup(logging.DEBUG, {'DEBUG': 'red'})
    logging.info("\033[33m TEST : START \033[0m")
    record_audio()
    #record_to_wave()
    #create_wav()
    #print (pitch_to_freq("Ab4"))
    #print (freq_to_pitch(415))
    #read_song("Python Files\\HotCrossBuns.txt")
    #wave_to_wav(generate_sine_wave(frequency=440))
    #wave_to_wav(generate_chord(frequencies=[pitch_to_freq("C4"),pitch_to_freq("E4"),pitch_to_freq("G4")]))
    #print (cents_off(442))
    #for x in range (440,448):
    #    print(in_tune(x))
    #print(find_dominant_freq())
    #test_off_pitch()
    #freqs, magnitude = find_frequencies()
    #plot_freqs (freqs,magnitude)
    #print (cents_off(0))
    #print(round(cents_off(435)))
    #print(sharp_or_flat(435))
    #print(np.max(generate_chord()))
    logging.info("\033[33m TEST : END \033[0m")