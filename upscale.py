import cv2
import numpy as np
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('-i')
parser.add_argument('-o')
args = parser.parse_args()

half = cv2.imread(args.i, cv2.IMREAD_UNCHANGED)

img = cv2.resize(img, dsize=None, fx=2, fy=2, interpolation=cv2.INTER_CUBIC)
img = img.astype(np.uint8)*257

cv2.imwrite(args.o, img)