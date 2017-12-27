# QR code detector for low quality images
 - Version:    0.1
 - Library used in development:
   - opencv 3.3.1
   - Zbar
 - See 'main.py' for the usage.

# Steps
1. Pre-process the input image, including 

   - image median/Gaussian filtering
   - image adaptive thresholding
   - image morphology transformation.
   
   The goal is to generate a clean binary image without losing much detail.

1. Locate three finder patterns in the image

   - Based on the QR code standard, any line which goes across the center of the finder pattern will change between black and white like W-B-W-B-W, with a ratio for the width of each color of 1:1:3:1:1.
   - Apply a brute force search to filter out the most / top two candidates for the finder pattern.
   - Find the last finder pattern.
   - Use three finder patterns to determine the location of QR code region.

1. Process the QR code region

   - Crop out the QR code region.
   - Apply a grid algorithm to generate a new binary image representing the QR code.

1. Let Zbar decode

# TODO
1. Use matrix/vector to speedup the code
1. Refine the gridding algorithm, especially while generating the new binary image.

# References:
 - [Zbar python](https://github.com/ZBar/ZBar/tree/master/python)
 - [Scanning QR code](http://aishack.in/tutorials/scanning-qr-codes-1/)
 - [QR code detector](http://blog.csdn.net/xm1050230545/article/details/7041686)
 - [Fast QR Code Detection in Arbitrarily Acquired Images](http://ieeexplore.ieee.org/document/6134743/)
 - [Python code to change color space](http://www.pythonexample.com/code/rgb-to-yuv-conversion-formula/)

# Related:
 - [Barcode detection](https://www.pyimagesearch.com/2014/12/15/real-time-barcode-detection-video-python-opencv/)
 - [Datamatrix detection](https://stackoverflow.com/questions/44926316/how-to-locate-and-read-data-matrix-code-with-python)
