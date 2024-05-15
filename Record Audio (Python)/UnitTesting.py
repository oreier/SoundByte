import unittest
import os
from unittest.mock import patch
from scipy.io import wavfile
from setupMicrophone import list_audio_devices, select_microphone
from recordAudio import record_audio
from WaveGenerator import generate_sine_wave
from WaveToWav import wave_to_wav
from pitch import pitch_to_freq
from pitch import freq_to_pitch
from SongToWav import read_song

class TestMyFunctions(unittest.TestCase):
    

    def test_list_audio_devices(self):
        devices = list_audio_devices()
        # Assert that the devices list is not empty
        self.assertTrue(devices)
    
    @patch('builtins.input', return_value='1')  # Mock user input
    def test_select_microphone(self, mock_input):
        choice = select_microphone()
        # Assert that the choice is an integer
        self.assertIsInstance(choice, int)
        
        
    def test_freq_to_pitch(self):
        # Test for frequency to pitch conversion
        self.assertEqual(freq_to_pitch(440), 'A4')
        self.assertEqual(freq_to_pitch(261.63), 'C4')
        # Add more test cases for different frequencies

    def test_pitch_to_freq(self):
        # Test for pitch to frequency conversion
        self.assertAlmostEqual(pitch_to_freq('A4'), 440, delta=0.01)
        self.assertAlmostEqual(pitch_to_freq('C4'), 261.63, delta=0.01)
    
    def test_record_audio(self):
        # Define test parameters
        output_filename = 'test_recorded_audio.wav'
        duration = 3  # 3 seconds
        sample_rate = 44100
        
        # Call the function to record audio using a context manager
        with self.assertLogs(level='INFO') as cm:
            record_audio(output_filename=output_filename, duration=duration, sample_rate=sample_rate)
        
        # Check if the output file exists
        self.assertTrue(os.path.exists(output_filename))
        
        # Check if the output file is not empty
        self.assertGreater(os.path.getsize(output_filename), 0)
        
        # Check if the log message indicating that streams were closed is present
        self.assertIn('INFO:root:Streams closed', cm.output[0])

        # Clean up: Remove the output file
        os.remove(output_filename)    

    def test_read_song(self):
        #Define test parameters
        input_filename = "test_song.txt"
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
        read_song(input=input_filename)

        # Check if the output file exists
        self.assertTrue(os.path(output_filename))

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

def main():
    unittest.main()

if __name__ == "__main__":
    main()