from setupMicrophone import list_audio_devices, select_microphone
from recordAudio import record_audio




if __name__ == "__main__":
    device_index = select_microphone()
    output_filename = "recorded_audio.wav"
    record_audio(output_filename, device_index)
    print("Audio saved as:", output_filename)