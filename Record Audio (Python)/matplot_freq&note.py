import pyaudio
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation

# Function to initialize the plot
def init_plot():
    line_time.set_ydata(np.zeros(CHUNK))
    line_freq.set_ydata(np.zeros(int(CHUNK / 2)))
    return line_time, line_freq, note_text

# Function to update the plot with new audio data
def update_plot(frame):
    data = np.frombuffer(stream.read(CHUNK), dtype=np.int16)
    
    # Time-domain plot
    line_time.set_ydata(data)
    
    # Frequency-domain plot
    fft_data = np.fft.fft(data)
    fft_magnitude = np.abs(fft_data[:int(CHUNK / 2)]) * 2 / (32768 * CHUNK) # Scale FFT
    line_freq.set_ydata(fft_magnitude)
    
    # Find the index of the peak frequency
    peak_index = np.argmax(fft_magnitude)
    
    # Calculate corresponding frequency and note
    frequency = peak_index * RATE / CHUNK
    note = get_note_name(frequency)
    note_text.set_text(f'Note: {note}')
    
    return line_time, line_freq, note_text

# Function to get the musical note name from frequency
def get_note_name(frequency):
    A4_frequency = 440.0
    notes = ['A', 'A#', 'B', 'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#']
    

    # when frequency = 0, log2(0) would cuase error 
    # (also if frequency / A4_frequency is very close to 0 cuases round(infinity) so just keep frequecny above some min value)
    if( frequency < 1 ):
        return f'{'None'}'
    
    else:
        # Calculate the number of half steps from A4
        half_steps = round(12 * np.log2(frequency / A4_frequency)) # (round to 1 decimal ?)
    
        # Calculate the octave and note
        octave = 4 + half_steps // 12
        note_index = int(half_steps % 12)
    
        return f'{notes[note_index]}{octave}'

# Parameters
FORMAT = pyaudio.paInt16
CHANNELS = 1
RATE = 44100
CHUNK = 1024

# Initialize PyAudio
p = pyaudio.PyAudio()

# Open stream
stream = p.open(format=FORMAT,
                channels=CHANNELS,
                rate=RATE,
                input=True,
                frames_per_buffer=CHUNK)

# Initialize plot
fig, (ax1, ax2) = plt.subplots(2, 1)
x_time = np.arange(0, 2 * CHUNK, 2)
x_freq = np.linspace(0, RATE / 2, int(CHUNK / 2))
line_time, = ax1.plot(x_time, np.random.rand(CHUNK))
line_freq, = ax2.plot(x_freq, np.random.rand(int(CHUNK / 2)))
note_text = ax2.text(0.85, 0.9, '', transform=ax2.transAxes, ha='center')

# Plot settings
# ax1.set_ylim(-32768, 32767)
ax1.set_ylim(-32768 / 8, 32767 / 8)
ax1.set_xlim(0, CHUNK)
ax1.set_title('Time Domain')
ax1.set_ylabel('Amplitude')
# plt.setp(ax1, xticks=[0, CHUNK, 2 * CHUNK], yticks=[-32768, 0, 32767])
plt.setp(ax1, xticks=[0, CHUNK, 2 * CHUNK], yticks=[-32768 / 8, 0, 32767/ 8])

# ax2.set_ylim(0, 1)
ax2.set_ylim(0, 1 / 8)
# ax2.set_xlim(20, RATE / 2)
ax2.set_xlim(20, RATE / 16)
ax2.set_title('Frequency Domain')
ax2.set_xlabel('Frequency (Hz)')
ax2.set_ylabel('Magnitude')

# Animation
ani = animation.FuncAnimation(fig, update_plot, init_func=init_plot, blit=True)

plt.show()

# Close stream
stream.stop_stream()
stream.close()

# Close PyAudio
p.terminate()
