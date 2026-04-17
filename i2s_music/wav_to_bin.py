import wave
import struct
import sys
import os

def convert_wav_to_bin(input_wav, output_bin):
    if not os.path.exists(input_wav):
        print(f"Error: File '{input_wav}' does not exist.")
        return

    print (f"Converting '{input_wav}' to '{output_bin}'...")

    with wave.open(input_wav, 'rb') as wav_file:
        num_channels = wav_file.getnchannels()
        sample_width = wav_file.getsampwidth()
        frame_rate = wav_file.getframerate()
        num_frames = wav_file.getnframes()

        print(f"Channels: {num_channels}, Sample Width: {sample_width*8} bits, Frame Rate: {frame_rate} Hz, Total Frames: {num_frames}")

        if sample_width != 2:
            print("Error: Only 16-bit WAV files are supported.")
            return

        frames = wav_file.readframes(num_frames)

    print("Converting to AXI Stream format...")

    # Each sample is 16 bits (2 bytes), and we will pack them into 32-bit words for AXI Stream
    # '<' indicates little-endian, 'h' is a short (16-bit) integer
    samples = struct.unpack('<' + 'h' * (num_frames * num_channels), frames)

    with open(output_bin, 'wb') as bin_file:
        for i in range(num_frames):  # Process 4 bytes at a time (2 samples)
            if num_channels == 2:
                left_sample = samples[i * 2]
                right_sample = samples[i * 2 + 1]
            else:
                left_sample = samples[i]
                right_sample = samples[i] # Mono: duplicate the sample for right channel
            
            # Convert signed 16-bit samples to unsigned 16-bit for packing
            left_unsigned = left_sample & 0xFFFF
            right_unsigned = right_sample & 0xFFFF

            word_32 = (left_unsigned << 16) | right_unsigned   # Pack left and right samples into a 32-bit word
            bin_file.write(struct.pack('<I', word_32))         # Write as little-endian unsigned int

    print(f"Conversion complete. Output saved to '{output_bin}'.")
    print(f"Size of output file: {os.path.getsize(output_bin)} bytes")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python wav_to_bin.py <input_wav> <output_bin>")
    else:
        convert_wav_to_bin(sys.argv[1], sys.argv[2])