import numpy as np
import datetime
import unittest
import colorlog
import logging
import os
from unittest.mock import patch
from scipy.io import wavfile
from io import StringIO
from contextlib import redirect_stdout
from tqdm import tqdm
from setupMicrophone import list_audio_devices, select_microphone
from recordAudio import record_audio
from WaveGenerator import generate_sine_wave
from WaveToWav import wave_to_wav
from pitch import pitch_to_freq
from pitch import freq_to_pitch
from pitch import find_pitch_index
from pitch import cents_off
from pitch import sharp_or_flat
from pitch import in_tune
from SongToWav import read_song
from WaveGenerator import generate_sine_wave
from WaveGenerator import generate_chord
from WaveGenerator import read_wave_freq
from LoggingSetup import log_setup

class TestMyFunctions(unittest.TestCase):    

# setupMicrophone.py
############################################################################################
    def test_list_audio_devices(self):
        devices = list_audio_devices()
        # Assert that the devices list is not empty
        self.assertTrue(devices)
    
    @patch('builtins.input', return_value='1')  # Mock user input
    def test_select_microphone(self, mock_input):
        with StringIO() as buffer:
                with redirect_stdout(buffer):
                    choice = select_microphone()
        # Assert that the choice is an integer
      

# pitch.py
############################################################################################
    def test_freq_to_pitch(self):
        # Test for frequency to pitch conversion
        self.assertEqual(freq_to_pitch(440), 'A4')
        self.assertEqual(freq_to_pitch(261.63), 'C4')
        # Add more test cases for different frequencies

    def test_pitch_to_freq(self):
        # Test for pitch to frequency conversion
        self.assertAlmostEqual(pitch_to_freq('A4'), 440, delta=0.01)
        self.assertAlmostEqual(pitch_to_freq('C4'), 261.63, delta=0.01)


    def test_find_pitch_index(self):
        # Check that improper input will result in -1
        self.assertEqual(find_pitch_index("Z#4"),-1)
        self.assertEqual(find_pitch_index("Cd9"),-1)
        # Check for correct index  
        self.assertEqual(find_pitch_index("E"),4)
        # Check for correct index sharp
        self.assertEqual(find_pitch_index("C#9"),1)
        # Check for correct index flat
        self.assertEqual(find_pitch_index("Gb"),6)

    def test_cents_off(self):
        # Frequency matches
        self.assertAlmostEqual(cents_off(440), 0, delta=0.001)
        # Frequency is close
        self.assertAlmostEqual(cents_off(445), -19.562,delta=0.001)
        # Frequency is not close
        self.assertAlmostEqual(cents_off(1200),-336.951,delta=0.001)
        # Frequency of 0 returns error value 
        self.assertAlmostEqual(cents_off(0),-1)


    def test_sharp_or_flat(self):
        #Test Flat
        self.assertEqual(sharp_or_flat(435),0)
        #Test Sharp
        self.assertEqual(sharp_or_flat(445),1)
        #Test On Pitch
        self.assertEqual(sharp_or_flat(440),-1)

    def test_in_tune(self):
        # Test cases where the frequency is in tune
        self.assertEqual(in_tune(440), "\033[32m♪ In Tune ♪ \033[0m")
        self.assertEqual(in_tune(439), "\033[32m♪ In Tune ♪ \033[0m")
        # Test cases where the frequency is slightly out of tune
        self.assertEqual(in_tune(442), "\033[33m♪ Out of Tune ♪ \033[0m")
        self.assertEqual(in_tune(438), "\033[33m♪ Out of Tune ♪ \033[0m")
        # Test cases where the frequency is significantly out of tune
        self.assertEqual(in_tune(446), "\033[31m♪ Really Out of Tune ♪ \033[0m")
        self.assertEqual(in_tune(435), "\033[31m♪ Really Out of Tune ♪ \033[0m")
        # Test cases where the frequency is very out of tune
        self.assertEqual(in_tune(450), "\033[35m♪ :( ♪ \033[0m")
        self.assertEqual(in_tune(430), "\033[35m♪ :( ♪ \033[0m")

# recordAudio.py
############################################################################################
    def test_record_audio(self):
        # Define test parameters
        output_filename = 'Python Files\\test_recorded_audio.wav'
        duration = 3  # 3 seconds
        sample_rate = 44100
        
        # Call the function to record audio using a context manager
        with self.assertLogs(level='DEBUG') as cm:
            record_audio(output_filename=output_filename, duration=duration, sample_rate=sample_rate)
        
        # Check if the output file exists
        self.assertTrue(os.path.exists(output_filename))
        
        # Check if the output file is not empty
        self.assertGreater(os.path.getsize(output_filename), 0)

        # Clean up: Remove the output file
        os.remove(output_filename)    


# SongToWav.py
############################################################################################
    def test_read_song(self):
        #Define test parameters
        input_filename = "Python Files\\test_song.txt"
        output_filename = "test_song.wav"

        bpm = 120
        num_beats = 3
        duration = 0.5
        #Fill the txt file
        with open (input_filename, 'w') as f:
            f.write(f'{bpm}\n')
            for i in range(num_beats):
                f.write(f'C4, {duration}\n')

        #Call read_song
        read_song(input=input_filename, output=output_filename)

        # Check if the output file exists
        self.assertTrue(os.path.exists(output_filename))

        # Check if the output file is not empty
        self.assertGreater(os.path.getsize(output_filename),0)

        # Read the sample rate and audio data from the output WAV file
        sample_rate, audio_data = wavfile.read(output_filename)

        #Check if the duration matches the expected duration
        expected_duration = (num_beats / bpm) * 60 * duration
        duration = len(audio_data) / sample_rate
        self.assertAlmostEqual(duration,expected_duration,delta=0.1)
        

        # Clean up: Remove the input and output files
        os.remove(input_filename)
        os.remove(output_filename)



# WaveGenerator.py
############################################################################################
    def test_generate_sine_wave(self):
        # Test with default parameters
        default_wave = generate_sine_wave()
        self.assertEqual(len(default_wave), 220500)  # Default duration * sample_rate
        self.assertAlmostEqual(np.max(default_wave), 1.0, places=5)  # Max value of the sine wave

        # Test with custom parameters
        custom_wave = generate_sine_wave(duration=2, sample_rate=22050, frequency=220)
        self.assertEqual(len(custom_wave), 44100)  # Custom duration * sample_rate
        self.assertAlmostEqual(np.max(custom_wave), 1.0, places=5)  # Max value of the sine wave

    def test_generate_chord(self):
        # Test default chord generation
        duration = 5
        sample_rate = 44100
        frequencies = [440, 554.37, 659.25]
        chord_wave = generate_chord(duration, sample_rate, frequencies)
        self.assertEqual(len(chord_wave), 220500)  # Default duration * sample_rate
        self.assertLessEqual(np.max(chord_wave), 3.0)  # Max value of the sine wave
        # Test custom chord generation
        duration = 3
        sample_rate = 48000
        frequencies = [220, 330, 440, 550]
        chord_wave = generate_chord(duration, sample_rate, frequencies)
        self.assertEqual(len(chord_wave), sample_rate * duration)  # Default duration * sample_rate
        self.assertLessEqual(np.max(chord_wave), float(len(frequencies)))  # Max value of the sine wave
        

    def test_read_wave_freq(self):
        # Test with a known sine wave frequency
        frequency = 440
        duration = 1  # Second
        sample_rate = 44100
        wave = generate_sine_wave(duration=duration, sample_rate=sample_rate, frequency=frequency)
        max_freq = read_wave_freq(wave)
        self.assertAlmostEqual(max_freq, frequency, delta=1)  # Delta set to 1 Hz

        # Test with a different known sine wave frequency
        frequency = 1000
        duration = 1  # Second
        sample_rate = 44100
        wave = generate_sine_wave(duration=duration, sample_rate=sample_rate, frequency=frequency)
        max_freq = read_wave_freq(wave)
        self.assertAlmostEqual(max_freq, frequency, delta=1)  # Delta set to 1 Hz



def main():
    allTestPassed = 1
    # Set up log file
    log_setup(logging.INFO,{'INFO' : 'blue'})
    
    logging.info("\033[33m UNIT TEST : START    " + str(datetime.datetime.now()) + " \033[0m")
    # Get the list of test cases
    test_cases = unittest.TestLoader().loadTestsFromTestCase(TestMyFunctions)
    
    # Iterate over each test case
    for test_case in test_cases:
        # Run the test case
        result = test_case.run()
        
        # Get the test name
        test_name = test_case._testMethodName
        
        # Print the test name in green if the test was successful
        if result.wasSuccessful():
            print("\033[92m" + test_name + " passed\033[0m")
            #logging.info("\033[92m" + test_name + " passed\033[0m")
        else:
            print("\033[91m" + test_name + " failed\033[0m")
            logging.info("\033[91m" + test_name + " failed\033[0m")
            allTestPassed = 0

    if allTestPassed == 1:
        logging.info("\033[92m All test passed \033[92m")

    logging.info("\033[33m UNIT TEST : END \033[0m")

if __name__ == "__main__":
    main()

"""
        @patch('builtins.input', return_value='C#2') #Mock User Input
        def test_sharp_input():
            find_pitch_index()
"""