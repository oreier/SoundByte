import numpy as np
from WaveGenerator import generate_sine_wave
from WaveGenerator import read_wave_freq

test_wave = generate_sine_wave(frequency=660)

frequency = read_wave_freq (test_wave)

print (frequency)
