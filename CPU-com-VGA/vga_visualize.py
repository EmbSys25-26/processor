"""
vga_visualize.py

Le o ficheiro vga_output.txt gerado pela simulacao Vivado
e gera uma imagem PNG do que apareceria no monitor VGA.

Uso:
    python3 vga_visualize.py

Requisitos:
    sudo apt install python3 python3-pil
    ou
    pip install pillow --break-system-packages

O ficheiro vga_output.txt deve estar na mesma pasta.
Cada linha tem 3 bits: R G B
    "111" = branco
    "000" = preto
    "100" = vermelho
    "010" = verde
    "001" = azul

O ficheiro deve ter exactamente 307200 linhas (640x480).
Se tiver menos, o resto e preenchido com preto.
Se tiver mais, o excesso e ignorado.
"""

from PIL import Image

INPUT_FILE  = "vga_output_soc.txt"
OUTPUT_FILE = "vga_frame.png"
WIDTH       = 640
HEIGHT      = 480
SCALE       = 2     # amplia a imagem para ver melhor (2 = dobro do tamanho)

print(f"A ler {INPUT_FILE}...")

pixels = []
errors = 0

with open(INPUT_FILE, "r") as f:
    for line_num, line in enumerate(f):
        line = line.strip()
        if len(line) != 3:
            errors += 1
            pixels.append((0, 0, 0))
            continue
        try:
            r = 255 if line[0] == '1' else 0
            g = 255 if line[1] == '1' else 0
            b = 255 if line[2] == '1' else 0
            pixels.append((r, g, b))
        except:
            errors += 1
            pixels.append((0, 0, 0))

total = WIDTH * HEIGHT
print(f"Pixels lidos : {len(pixels)}")
print(f"Esperado     : {total} (640x480)")

if errors > 0:
    print(f"Avisos       : {errors} linhas com formato invalido (substituidas por preto)")

if len(pixels) < total:
    em_falta = total - len(pixels)
    print(f"Aviso        : faltam {em_falta} pixels — completados com preto")
    print(f"              (a simulacao pode nao ter corrido tempo suficiente)")
    pixels += [(0, 0, 0)] * em_falta
else:
    if len(pixels) > total:
        print(f"Aviso        : {len(pixels) - total} pixels a mais — ignorados")
    pixels = pixels[:total]

# cria a imagem
img = Image.new("RGB", (WIDTH, HEIGHT))
img.putdata(pixels)

# amplia para ver melhor
if SCALE > 1:
    img = img.resize((WIDTH * SCALE, HEIGHT * SCALE), Image.NEAREST)

img.save(OUTPUT_FILE)
print(f"\nImagem guardada : {OUTPUT_FILE}")
print(f"Tamanho         : {WIDTH*SCALE} x {HEIGHT*SCALE} px")

# estatisticas simples
brancos = sum(1 for p in pixels if p == (255, 255, 255))
pretos  = sum(1 for p in pixels if p == (0, 0, 0))
outros  = total - brancos - pretos

print(f"\nEstatisticas dos pixels:")
print(f"  Brancos : {brancos:>7}  ({100*brancos/total:.1f}%)")
print(f"  Pretos  : {pretos:>7}  ({100*pretos/total:.1f}%)")
if outros > 0:
    print(f"  Outros  : {outros:>7}  ({100*outros/total:.1f}%)")

print(f"\nO que procurar na imagem:")
print(f"  - As letras enviadas (o, l, a nas primeiras 3 caixinhas da linha 0")
print(f"  - A letra enviada (c na primeira caixinha da linha 1")
print(f"  - Resto do ecra preenchido com espacos (cor de fundo)")
print(f"  - Se o ecra estiver todo da mesma cor: modo texto nao esta activo")
print(f"  - Se as letras aparecerem deslocadas: verificar o lookahead do pipeline")
