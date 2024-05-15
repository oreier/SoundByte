import pyaudio

#Detects audio input devices
#Arguments: N/A
#Returns: Array of audio devices and their info 
def list_audio_devices():
    p = pyaudio.PyAudio()
    info = p.get_host_api_info_by_index(0)
    num_devices = info.get('deviceCount')
    devices = []
    for i in range(0, num_devices):
        device_info = p.get_device_info_by_host_api_device_index(0, i)
        devices.append(device_info.get('name'))
    p.terminate()
    return devices

#Prints out a menu for the user to select a microphone
#Arguments: N/A
#Returns: index of microphone selected
def select_microphone():
    devices = list_audio_devices()
    print("Available microphones:")
    for i, device in enumerate(devices):
        print(f"{i}: {device}")
    choice = int(input("Select the microphone you want to use: "))
    return choice