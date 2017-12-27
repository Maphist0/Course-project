"""
    QR code detector for extremely low quality input image

    Please install ZBar before using this code.

    See 'main.py' for the usage.

    Author:     Maphisto
    Version:    0.1
    Contact:    zzp201501@gmail.com
    License:    MIT
"""

from __init__ import *

class Decoder():

    def __init__(self):
        self.scanner = zbar.ImageScanner()
        self.scanner.parse_config('enable')

    def decode(self, pil):
        width, height = pil.size
        raw = pil.tobytes()
        # Use tostring() if you have a prior version of PIL
        # raw = pil.tostring()
        image = zbar.Image(width, height, 'Y800', raw)
        self.scanner.scan(image)
        result = []
        for symbol in image:
            result.append({
                'decoded' : symbol.type,
                'symbol'  : '"%s"' % symbol.data
                })
        return result

    def decode_file(self, fpath):
        pil = Image.open(fpath).convert('L')
        return (pil, self.decode(pil))
