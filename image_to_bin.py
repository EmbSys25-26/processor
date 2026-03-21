# image_to_header.py
from PIL import Image
 
IMG_W = 640
IMG_H = 480
 
img = Image.open("gato.png")          # Load any image
img = img.resize((IMG_W, IMG_H))          # Resize to 640x480
img = img.convert("RGB")                  # Ensure RGB mode
 
pixels = list(img.getdata())              # Flat list of (R, G, B) tuples

with open("gato.bin", "wb") as f:
    for r, g, b in pixels:
        r4 = (r >> 4) & 0xF
        g4 = (g >> 4) & 0xF
        b4 = (b >> 4) & 0xF
        pixel = (r4 << 12) | (g4 << 8) | (b4 << 4)
        f.write(pixel.to_bytes(2, byteorder="little"))
 
print(f"image.bin: {IMG_W*IMG_H*2} bytes")


