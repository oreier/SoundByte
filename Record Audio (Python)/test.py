import numpy as np
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
from UnitTesting import main

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
    return wave1.append(wave2)


def test_single_note():
    freq_to_wav(440)
    

def test_hot_cross_buns():
    read_song(output="./test_output.wav")


def test_off_pitch():
    pitches = []
    pitches.append(append_notes(append_notes(append_notes(freq_to_wav(444)),freq_to_wav(450)),freq_to_wav(460)),freq_to_wav(470))
    pitches = np.array(pitches)
    wave_to_wav(output_file="./test_output.wav")

if __name__ == "__main__":
    #record_audio()
    #record_to_wave()
    #create_wav()
    #print (pitch_to_freq("Ab4"))
    #print (freq_to_pitch(415))
    #read_song("Python Files\\HotCrossBuns.txt")
    #wave_to_wav(generate_chord(frequencies=[pitch_to_freq("C4"),pitch_to_freq("E4"),pitch_to_freq("G4")]))
    #print (cents_off(442))
    #for x in range (440,448):
    #    print(in_tune(x))
    pass