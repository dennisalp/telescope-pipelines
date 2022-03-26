# Dennis Alp 2016-10-27
# Drizzle HST observations, part of data reduction after calibration.
# On my setup I need to work in the iraf27 environment: source activate iraf27
# Then astropy becomes accesible from both python and python2.7 (both are 2.7.12 anyway)
# time python /Users/silver/Dropbox/bin/hst_drz.py

import time
import pdb
import os
from glob import glob

import numpy as np
import drizzlepac as drz

WRK_DIR = "/Users/silver/Dropbox/phd/data/hst/87a/drz/2017-01-22_uplim_f657n/"
BASE = "w36572016-06-08_"

os.chdir(WRK_DIR) #Move to designated directory

files = ",".join(glob(WRK_DIR + BASE + 'und_?0?.fits')) #Find all files.

# TweakReg seems to make AstroDrizzle crash and can't run twice, both when updating
#drz.tweakreg.TweakReg(files, updatehdr=False, threshold=3,peakmax=50)

def do_drz():
    OUTNAME = BASE + str(i).replace(".","p")
    drz.astrodrizzle.AstroDrizzle(files, output=OUTNAME, resetbits=4096, \
        combine_nsigma=COMBINE_NSIGMA, combine_grow=COMBINE_GROW, \
        driz_cr_corr=True, driz_sep_bits="64,32", \
        driz_cr_snr=DRIZ_CR_SNR, driz_cr_scale=DRIZ_CR_SCALE, \
        final_bits="64,32", final_wcs=True, final_scale=FINAL_SCALE, \
        final_rot=0, final_pixfrac=FINAL_PIXFRAC, final_units=FINAL_UNITS, build=False)

for i in [0., 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]:
    COMBINE_NSIGMA = "4 3" # Creating median image
    COMBINE_GROW = 1 # Number of iterations when creating median, seems to be a heuristic
    DRIZ_CR_SNR = "3.5 3.0" # Default 3.5 3.0, cosmic ray signal to noise
    DRIZ_CR_SCALE = "2.4 1.4" # Default 1.2 0.7, cosmic ray scale * deriv, seems heuristic
    FINAL_SCALE = 0.025 # The two main parameters
    FINAL_PIXFRAC = i # The two main parameters
    FINAL_UNITS = "cps"
    do_drz()
