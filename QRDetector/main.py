#!/usr/bin/python

from __init__ import *
from Decoder import Decoder
from QRDetector import QRDetector
from Util import *

T_DIR = './test_imgs/'
ext = '.jpg'

# (succ, fail, rate) = test_folder('../test_images/Group4/')
# print 'Succ / Fail = %d / %d, rate = %.4f' % (succ, fail, rate)

if __name__ == "__main__":

    detector = QRDetector()

    for _, _, files in os.walk(T_DIR):
        pass

    for file in files:
        if ext in file:
            detector.detect(T_DIR + file)
        
