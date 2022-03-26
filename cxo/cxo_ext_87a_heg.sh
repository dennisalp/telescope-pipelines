#!/bin/bash -x

# This extracts all ACIS-S HEG and MEG spectra for all of SN 1987A.

# Dry
wrk_dir="/Volumes/lacie_600_gb/dat/cxo/tmp/"
ra="05h35m27.9875s"
de="-69d16m11.107s"
ids=(16756)

# SN 1987A, all HETG
#wrk_dir="/Volumes/lacie_600_gb/dat/cxo/87a/"
#ra="05h35m27.9875s"
#de="-69d16m11.107s"
#ids=(8523 8537 7588 8538 7589 8539 8542 8487 8543 8544 8488 8545 8546 7590 9144 10852 10221 10853 10854 10855 10222 10926 12125 12126 11090 13131 11091 12145 13238 13239 12146 12539 12540 14344 13735 14417 14697 14698 15809 17415 15810 16756 17899 19882 20793 19289)

################################################################
# Notes
# Set the correct bad pixel list, chandra_repro creates a bad pixel
# file and sets this as the current file. So, if extraction is
# performed right after repro all's fine. However, if going back, then
# SET THE BAD PIXEL FILE TO THE ONE CREATED BY chandra_repro FOR THE
# SPECIFIC OBSERVATION
#acis_set_ardlib "acisf${ID}_repro_bpix1.fits"

################################################################
# Common for all ACIS, this cleans and makes images
function get_img {
    # Apply a 0.3 to 10 keV filter
    dmcopy "acisf${ids[id]}_repro_evt2.fits[energy=300:10000]" \
	   "acisf${ids[id]}_repro_evt2_03_10.fits"

    # Create a background light curve. 3.24104 seconds
    dmextract "acisf${ids[id]}_repro_evt2_03_10.fits[sky=field()-${src_reg}][bin time=::1024]" \
    	      "acisf${ids[id]}_repro_bkg_lc.fits" \
    	      "opt=ltc1"
    
    # Find the GTI, uses clean instead of sigma
    deflare "acisf${ids[id]}_repro_bkg_lc.fits" \
    	    "acisf${ids[id]}_repro_gti.fits" \
    	    "method=clean" \
	    "stddev=7" \
    	    "save=acisf${ids[id]}_repro_bkg_lc.ps"
    
    # Apply the GTI
    dmcopy "acisf${ids[id]}_repro_evt2_03_10.fits[@acisf${ids[id]}_repro_gti.fits]" \
           "acisf${ids[id]}_repro_evt2_03_10_clean.fits"
    
    # High resolution image to save some space
    dmcopy "acisf${ids[id]}_repro_evt2_03_10_clean.fits[bin x=${xlo}:${xhi}:0.1, y=${ylo}:${yhi}:0.1][IMAGE]" \
           "acisf${ids[id]}_repro_evt2_03_10_clean_img.fits"
}

# This gets one zeroth order spectrum for the entire source
#(i.e. standard) The main decisions you have to make when running this
#script are: is the source's spatial extent large enough that the
#responses (ARF and RMF) should be weighted by the count distribution
#within the aperture (the weight and weight_rmf parameters); if
#weight=no, should the ARF be corrected to account for X-rays falling
#outside the finite size and shape of the aperture (the correctpsf
#parameter); do you want a background spectrum - and possibly
#responses - also created and linked to the source spectrum via the
#BACKFILE, ANCRFILE and RESPFILE keywords (the bkg* parameters);
function get_spe {
    specextract infile="acisf${ids[id]}_repro_evt2_03_10_clean.fits[sky=${src_reg}]" \
    		bkgfile="acisf${ids[id]}_repro_evt2_03_10_clean.fits[sky=${bkg_reg}]" \
    		outroot="acisf${ids[id]}_repro_0th" \
    		correctpsf=yes \
    		weight=no \
    		bkgresp=no \
    		grouptype=NONE
    
    # Rename and link the files
    mv "acisf${ids[id]}_repro_0th.pi" "acisf${ids[id]}_repro_0th.pha"
    mv "acisf${ids[id]}_repro_0th_bkg.pi" "acisf${ids[id]}_repro_0th.bkg"
    mv "acisf${ids[id]}_repro_0th.corr.arf" "acisf${ids[id]}_repro_0th.arf"
    fthedit "acisf${ids[id]}_repro_0th.pha[1]" BACKFILE add "acisf${ids[id]}_repro_0th.bkg"
    fthedit "acisf${ids[id]}_repro_0th.pha[1]" RESPFILE add "acisf${ids[id]}_repro_0th.rmf"
    fthedit "acisf${ids[id]}_repro_0th.pha[1]" ANCRFILE add "acisf${ids[id]}_repro_0th.arf"
}

function mk_tgs {
    ################################################################
    # Extract the first order HETG/METG spectra
    dmtype2split "acisf${ids[id]}_repro_pha2.fits[tg_part=1,tg_m=1]"  "acisf${ids[id]}_repro_heg_p1.pha[SPECTRUM]"
    dmtype2split "acisf${ids[id]}_repro_pha2.fits[tg_part=1,tg_m=-1]" "acisf${ids[id]}_repro_heg_m1.pha[SPECTRUM]"
    dmtype2split "acisf${ids[id]}_repro_pha2.fits[tg_part=2,tg_m=1]"  "acisf${ids[id]}_repro_meg_p1.pha[SPECTRUM]"
    dmtype2split "acisf${ids[id]}_repro_pha2.fits[tg_part=2,tg_m=-1]" "acisf${ids[id]}_repro_meg_m1.pha[SPECTRUM]"
    
    tg_bkg "acisf${ids[id]}_repro_heg_p1.pha" "acisf${ids[id]}_repro_heg_p1.bkg"
    tg_bkg "acisf${ids[id]}_repro_heg_m1.pha" "acisf${ids[id]}_repro_heg_m1.bkg"
    tg_bkg "acisf${ids[id]}_repro_meg_p1.pha" "acisf${ids[id]}_repro_meg_p1.bkg"
    tg_bkg "acisf${ids[id]}_repro_meg_m1.pha" "acisf${ids[id]}_repro_meg_m1.bkg"
    
    # Link the rmf files
    fthedit "acisf${ids[id]}_repro_heg_p1.pha" RESPFILE add "acisf${ids[id]}_repro_heg_p1.rmf"
    fthedit "acisf${ids[id]}_repro_heg_m1.pha" RESPFILE add "acisf${ids[id]}_repro_heg_m1.rmf"
    fthedit "acisf${ids[id]}_repro_meg_p1.pha" RESPFILE add "acisf${ids[id]}_repro_meg_p1.rmf"
    fthedit "acisf${ids[id]}_repro_meg_m1.pha" RESPFILE add "acisf${ids[id]}_repro_meg_m1.rmf"
    
    # Link the arf files
    fthedit "acisf${ids[id]}_repro_heg_p1.pha" ANCRFILE add "acisf${ids[id]}_repro_heg_p1.arf"
    fthedit "acisf${ids[id]}_repro_heg_m1.pha" ANCRFILE add "acisf${ids[id]}_repro_heg_m1.arf"
    fthedit "acisf${ids[id]}_repro_meg_p1.pha" ANCRFILE add "acisf${ids[id]}_repro_meg_p1.arf"
    fthedit "acisf${ids[id]}_repro_meg_m1.pha" ANCRFILE add "acisf${ids[id]}_repro_meg_m1.arf"
    
#    # Attempt to group the grating spectra
#    dmgroup infile="acisf${ids[id]}_repro_heg_p1.pha[SPECTRUM]" \
#    	outfile="acisf${ids[id]}_repro_heg_p1.pha" \
#    	binspec="1:16384:100" grouptypeval="" grouptype=BIN ycolumn="counts" xcolumn="channel"
#    
#    dmgroup infile="acisf${ids[id]}_repro_heg_m1.pha[SPECTRUM]" \
#    	outfile="acisf${ids[id]}_repro_heg_m1.pha" \
#    	binspec="1:16384:100" grouptypeval="" grouptype=BIN ycolumn="counts" xcolumn="channel"
#    
#    dmgroup infile="acisf${ids[id]}_repro_meg_p1.pha[SPECTRUM]" \
#    	outfile="acisf${ids[id]}_repro_meg_p1.pha" \
#    	binspec="1:16384:100" grouptypeval="" grouptype=BIN ycolumn="counts" xcolumn="channel"
#    
#    dmgroup infile="acisf${ids[id]}_repro_meg_m1.pha[SPECTRUM]" \
#    	outfile="acisf${ids[id]}_repro_meg_m1.pha" \
#    	binspec="1:16384:100" grouptypeval="" grouptype=BIN ycolumn="counts" xcolumn="channel"
}

function par_hlp {
    printf "import numpy as np
import os
from glob import glob

from astropy.io import fits
from astropy.coordinates import SkyCoord

def coords2pix(image, ra, de):
    raref = fits.getval(image,'TCRVL11', 1)
    radel = fits.getval(image,'TCDLT11', 1)
    rapix = fits.getval(image,'TCRPX11', 1)
    deref = fits.getval(image,'TCRVL12', 1)
    dedel = fits.getval(image,'TCDLT12', 1)
    depix = fits.getval(image,'TCRPX12', 1)
    xx = (ra-raref)*np.cos(np.deg2rad(de))/radel+rapix-1
    yy = (de-deref)/dedel+depix-1
    return xx, yy

fits_path = glob('primary/acisf${ids[id]}N00?_evt2.fits')[0]
cc = SkyCoord('${ra}', '${de}', frame='icrs')
xx, yy = coords2pix(fits_path, cc.ra.degree, cc.dec.degree)
xx = xx+1
yy = yy+1

ff = open('par.sh', 'w+')
ff.write('src_reg=\"circle(' + str(xx) + ',' + str(yy) + ',16)\"\\\\n')
ff.write('bkg_reg=\"annulus(' + str(xx) + ',' + str(yy) + ',24,48)\"\\\\n')
ff.write('xx=' + str(xx) + '\\\\n')
ff.write('yy=' + str(yy) + '\\\\n')
ff.write('xlo=' + str(xx-20) + '\\\\n')
ff.write('xhi=' + str(xx+20) + '\\\\n')
ff.write('ylo=' + str(yy-20) + '\\\\n')
ff.write('yhi=' + str(yy+20) + '\\\\n')
ff.write('ra_deg=' + str(cc.fk5.ra.degree) + '\\\\n')
ff.write('de_deg=' + str(cc.fk5.dec.degree) + '\\\\n')
ff.close()" > get_par.py
}

function get_par {
    par_hlp
    source activate astroconda
    python get_par.py
    source deactivate
    . par.sh
    # This is epected to set the following variables:
    # src_reg="circle(4077.8788,4084.2184,16.256681)"
    # xx=4077
    # yy=4084
    # xlo=4046
    # xhi=4110
    # ylo=4052
    # yhi=4116

    instrument=($(fkeyprint oif.fits[1] INSTRUME | sed -n '6p'))
    instrument="${instrument[1]:1:3}"
    grating=($(fkeyprint oif.fits[1] GRATING | sed -n '6p'))
    grating="${grating[2]:1:3}"
}

################################################################

source /usr/local/ciao-4.9/bin/ciao.bash
nid=${#ids[@]}

for id in $(seq 0 $(($nid-1)))
do
    cd ${wrk_dir}${ids[id]}
    ids[id]=$(printf %05d ${ids[id]})
    chandra_repro indir=. outdir=./repro

    get_par
    cd repro
    acis_set_ardlib acisf${ids[id]}_repro_bpix1.fits
    get_img
    get_spe
    mk_tgs
done

echo "EOF"
