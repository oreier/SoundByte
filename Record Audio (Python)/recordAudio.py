import pyaudio
import numpy as np
import wave
import logging

#Levels of in Tune measured in Cents away from "perfect"
#1. 2-4   : Perfect              #59933e
#2. 5-12  : Is it cold outside?  #659126
#3. 13-25 : Eep                  #988200
#4. 26-45 : Ow                   #c16d00
#5. 46-99 : Whole different note #ff0000

#Records audio and saves it to a .wav file
#Arguments: (string) output file path
#           (int) microphone to record from
#           (int) seconds to record
#           (int)
#           
#           (int) number of channels microphone has
#           (int) samples per second
#Returns: N/A
def record_audio(output_filename = 'Python Files\\recorded_audio.wav', device_index = 0, duration=5, chunk_size=1024, sample_format=pyaudio.paInt16, channels=1, sample_rate=44100):
    p = pyaudio.PyAudio()
    chunk_size = duration * sample_rate
    stream = p.open(format=sample_format,
                    channels=channels,
                    rate=sample_rate,
                    frames_per_buffer=chunk_size,
                    input=True,
                    input_device_index=device_index)

    frames = []
    all_frequencies = []

    logging.info("Recording...")
    #print("Sample Rate:", sample_rate)

    for _ in range(0, int(sample_rate / chunk_size * duration)):
        data = stream.read(chunk_size)
        frames.append(data)

        # Convert binary data to numpy array
        audio_data = np.frombuffer(data, dtype=np.int16)
        # Apply FFT to analyze frequency components
        fft_result = np.fft.fft(audio_data)
        # Calculate frequencies corresponding to FFT result
        frequencies = np.fft.fftfreq(len(audio_data), 1/sample_rate)
        all_frequencies.append(frequencies)

    # Print frequencies
    logging.info("Finished Recording")
    stream.stop_stream()
    stream.close()
    p.terminate()

    # Log that streams have been closed
    logging.info("Streams closed")

    wf = wave.open(output_filename, 'wb')
    wf.setnchannels(channels)
    wf.setsampwidth(p.get_sample_size(sample_format))
    wf.setframerate(sample_rate)
    wf.writeframes(b''.join(frames))
    wf.close()
