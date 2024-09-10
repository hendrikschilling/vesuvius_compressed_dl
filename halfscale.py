import cv2
import numpy as np
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('-i')
parser.add_argument('-o')
args = parser.parse_args()

img = cv2.imread(args.i, cv2.IMREAD_UNCHANGED)

half = cv2.resize(img, dsize=None, fx=0.5, fy=0.5, interpolation=cv2.INTER_CUBIC)
half = (half/257).astype(np.uint8)

cv2.imwrite(args.o, half)