import numpy as np
import matplotlib.pyplot as plt

#Generates a sine wave using numpy
#Arguments: (int) duration defaults to 5
#           (int) sample_rate defaults to 44100
#           (int) frequency defaults to 440
#Returns: numpy array 
def generate_sine_wave(duration=5, sample_rate=44100, frequency=440):
    timeVector = np.linspace(0, duration, int(duration * sample_rate), endpoint=False)
    wave = np.sin(2 * np.pi * frequency * timeVector)
    return wave

#Returns the frequency of a sine wave
#Arguments: (numpy array) sine wave
#Returns: (int) maximum frequency 
def read_wave_freq(wave):
    fft = np.fft.fft(wave) 
    fft_freq = np.fft.fftfreq(len(fft), 1 / 44100)
    positive_freqs = fft_freq[:len(fft) // 2] # Isolate the positive frequencies 
    magnitude_spectrum = np.abs(fft[:len(fft) // 2]) # Finds magnitude of each frequency 
    max_freq_index = np.argmax(magnitude_spectrum) # Finds index of max frequency 
    max_freq = positive_freqs[max_freq_index] # Finds biggest positive frequency 
    return max_freq