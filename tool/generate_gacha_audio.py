"""Generate original, deterministic mono PCM effects; no downloaded samples."""
import math
import random
import struct
import wave
from pathlib import Path

out = Path(__file__).resolve().parents[1] / 'assets/audio/gacha'
out.mkdir(parents=True, exist_ok=True)
for index, (name, duration, frequency) in enumerate([
    ('paper_pick', .12, 0), ('paper_rustle', .16, 0),
    ('paper_tear', .20, 0), ('number_reveal', .11, 660),
    ('prize_hit', .17, 440), ('item_reveal', .26, 523.25),
]):
    rng = random.Random(80 + index)
    rate = 22050
    samples = []
    previous = 0
    for i in range(int(rate * duration)):
        t = i / rate
        envelope = min(t / .008, 1) * (1 - t / duration) ** 2
        if frequency:
            value = math.sin(2 * math.pi * frequency * t)
            value += .25 * math.sin(2 * math.pi * frequency * 1.5 * t)
        else:
            noise = rng.uniform(-1, 1)
            value = noise - previous * .65
            previous = noise
            value *= .35 + .65 * abs(math.sin(t * 130))
        samples.append(struct.pack('<h', int(value * envelope * 10000)))
    with wave.open(str(out / (name + '.wav')), 'wb') as audio:
        audio.setparams((1, 2, rate, 0, 'NONE', 'not compressed'))
        audio.writeframes(b''.join(samples))
