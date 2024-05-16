from setupMicrophone import list_audio_devices, select_microphone
from recordAudio import record_audio
from WaveGenerator import generate_sine_wave
from WaveToWav import wave_to_wav
from pitch import pitch_to_freq
from pitch import freq_to_pitch
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


if __name__ == "__main__":
    #record_audio()
    #record_to_wave()
    #create_wav()
    #print (pitch_to_freq("Ab4"))
    #print (freq_to_pitch(415))
    #read_song("Python Files\\HotCrossBuns.txt")
    pass