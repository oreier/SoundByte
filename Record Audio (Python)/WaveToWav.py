import numpy
import numpy as np
from scipy.io.wavfile import write

def wave_to_wav (sin_wave, sampling_rate = 44100):
    
    sin_wave = np.clip(sin_wave * (32767 / np.max(np.abs(sin_wave))), -32768, 32767)
    #sin_wave *= 32767 / np.max(np.abs(sin_wave))
    #Convert to 16 bit integers
    sin_wave = sin_wave.astype(np.int16)
    #Write to .wav file
    write('Python Files\\generated_wave.wav', sampling_rate, sin_wave)