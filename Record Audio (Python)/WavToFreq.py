import numpy as np
import librosa
import matplotlib.pyplot as plt

def find_dominant_freq(input_file = "Python Files\\generated_wave.wav"):
    wave, sample_rate = librosa.load(input_file)

    fft = np.fft.fft(wave)

    # Finding the dominant frequency
    freqs = np.fft.fftfreq(len(fft), 1/sample_rate)
    index = np.argmax(np.abs(fft))
    dominant_freq = freqs[index]
    return dominant_freq

def find_frequencies(input_file = "Python Files\\generated_wave.wav"):
    wave, sample_rate = librosa.load(input_file)
    magnitude = np.abs(np.fft.fft(wave))
    fft = np.fft.fft(wave)
    freqs = np.fft.fftfreq(len(fft), 1/sample_rate)
    return freqs, magnitude

def plot_freqs(freqs,magnitude):
    plt.figure(figsize = (8, 5))
    plt.plot(freqs,magnitude)
    plt.xlabel("Frequency (Hz)")
    plt.ylabel("Magnitude")
    plt.title("Magitude vs. Frequency")
    plt.grid(True)
    plt.show()