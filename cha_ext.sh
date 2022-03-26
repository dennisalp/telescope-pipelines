#!/bin/bash -x

# This is the most general extractor for Chandra/ACIS
# SN 1987A needs more careful regions for ER and ejecta
# Cas A needs more careful background subtraction because of the
# extended nebular emission

# Cas A
wrk_dir="/Users/$USER/dat/cxo/cas/"

# Dry
wrk_dir="/Users/$USER/dat/cxo/tmp/"
ra="05h35m27.9875s"
de="-69d16m11.107s"

# SN 1987A
wrk_dir="/Users/$USER/dat/cxo/87a/"
ra="05h35m27.9875s"
de="-69d16m11.107s"

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
	    "mean=5.5" \
    	    "save=acisf${ids[id]}_repro_bkg_lc.ps"
    
    # Apply the GTI
    dmcopy "acisf${ids[id]}_repro_evt2_03_10.fits[@acisf${ids[id]}_repro_gti.fits]" \
           "acisf${ids[id]}_repro_evt2_03_10_clean.fits"
    
    # High resolution image to save some space
    dmcopy "acisf${ids[id]}_repro_evt2_03_10_clean.fits[bin x=${xlo}:${xhi}:0.1, y=${ylo}:${yhi}:0.1][IMAGE]" \
           "acisf${ids[id]}_repro_evt2_03_10_clean_img.fits"
}

# This gets one zeroth order spectrum for the entire source (i.e. standard)
function get_spe {
    specextract infile="acisf${ids[id]}_repro_evt2_03_10_clean.fits[sky=${src_reg}]" \
    		bkgfile="acisf${ids[id]}_repro_evt2_03_10_clean.fits[sky=${bkg_reg}]" \
    		outroot="acisf${ids[id]}_repro_0th" \
    		correctpsf=yes \
    		weight=no \
    		bkgresp=no \
    		grouptype=NUM_CTS \
    		binspec=24
    
    # Rename and link the files
    mv "acisf${ids[id]}_repro_0th.pi" "acisf${ids[id]}_repro_0th.fits"
    mv "acisf${ids[id]}_repro_0th_grp.pi" "acisf${ids[id]}_repro_0th.pha"
    mv "acisf${ids[id]}_repro_0th_bkg.pi" "acisf${ids[id]}_repro_0th.bkg"
    fthedit "acisf${ids[id]}_repro_0th.pha" BACKFILE add "acisf${ids[id]}_repro_0th.bkg"
    fthedit "acisf${ids[id]}_repro_0th.pha" RESPFILE add "acisf${ids[id]}_repro_0th.rmf"
    fthedit "acisf${ids[id]}_repro_0th.pha" ANCRFILE add "acisf${ids[id]}_repro_0th.arf"
}

# This does ER-ejecta separation for SN 1987A
function get_all_spe {    
    # Extract zeroth order spectrum of the ejecta
    specextract infile="acisf${ids[id]}_repro_evt2_03_10_clean.fits[sky=region(inner.reg)]" \
    		bkgfile="acisf${ids[id]}_repro_evt2_03_10_clean.fits[sky=${bkg_reg}]" \
    		outroot="acisf${ids[id]}_repro_0th_ej" \
    		correctpsf=no \
    		weight=no \
    		bkgresp=no \
    		grouptype=NONE
    
    # Rename and link the files
    mv "acisf${ids[id]}_repro_0th_ej.pi" "acisf${ids[id]}_repro_0th_ej.pha"
    mv "acisf${ids[id]}_repro_0th_ej_bkg.pi" "acisf${ids[id]}_repro_0th_ej.bkg"
    fthedit "acisf${ids[id]}_repro_0th_ej.pha[1]" BACKFILE add "acisf${ids[id]}_repro_0th_ej.bkg"
    fthedit "acisf${ids[id]}_repro_0th_ej.pha[1]" RESPFILE add "acisf${ids[id]}_repro_0th_ej.rmf"
    fthedit "acisf${ids[id]}_repro_0th_ej.pha[1]" ANCRFILE add "acisf${ids[id]}_repro_0th_ej.arf"
    
    # Get the aperture correction
#    arfcorr infile="acisf${ids[id]}_repro_img.fits" \
#    	    arf="" \
#    	    outfile="acisf${ids[id]}_repro_psf.fits" \
#    	    region="region(inner.reg)" \
#    	    x=${xx} \
#    	    y=${yy} \
#    	    energy=2. \
#    	    radlim=3.0 \
#    	    verbose=1
    
    # Extract zeroth order spectrum of the ER
    specextract infile="acisf${ids[id]}_repro_evt2_03_10_clean.fits[sky=${src_reg}-$(sed -n '2p' inner.reg)]" \
    		bkgfile="acisf${ids[id]}_repro_evt2_03_10_clean.fits[sky=${bkg_reg}]" \
    		outroot="acisf${ids[id]}_repro_0th_er" \
    		correctpsf=no \
    		weight=no \
    		bkgresp=no \
    		grouptype=NUM_CTS \
    		binspec=24
    
    # Rename and link the files
    mv "acisf${ids[id]}_repro_0th_er.pi" "acisf${ids[id]}_repro_0th_er.fits"
    mv "acisf${ids[id]}_repro_0th_er_grp.pi" "acisf${ids[id]}_repro_0th_er.pha"
    mv "acisf${ids[id]}_repro_0th_er_bkg.pi" "acisf${ids[id]}_repro_0th_er.bkg"
    fthedit "acisf${ids[id]}_repro_0th_er.pha[1]" BACKFILE add "acisf${ids[id]}_repro_0th_er.bkg"
    fthedit "acisf${ids[id]}_repro_0th_er.pha[1]" RESPFILE add "acisf${ids[id]}_repro_0th_er.rmf"
    fthedit "acisf${ids[id]}_repro_0th_er.pha[1]" ANCRFILE add "acisf${ids[id]}_repro_0th_er.arf"
}

#function mk_tg {
#    ################################################################
#    # Extract the first order HETG/METG spectra
#    dmtype2split "acisf${ids[id]}_repro_pha2.fits[tg_part=1,tg_m=1]"  "acisf${ids[id]}_repro_heg_p1.fits[SPECTRUM]"
#    dmtype2split "acisf${ids[id]}_repro_pha2.fits[tg_part=1,tg_m=-1]" "acisf${ids[id]}_repro_heg_m1.fits[SPECTRUM]"
#    dmtype2split "acisf${ids[id]}_repro_pha2.fits[tg_part=2,tg_m=1]"  "acisf${ids[id]}_repro_meg_p1.fits[SPECTRUM]"
#    dmtype2split "acisf${ids[id]}_repro_pha2.fits[tg_part=2,tg_m=-1]" "acisf${ids[id]}_repro_meg_m1.fits[SPECTRUM]"
#    
#    tg_bkg "acisf${ids[id]}_repro_heg_p1.fits" "acisf${ids[id]}_repro_heg_p1.bkg"
#    tg_bkg "acisf${ids[id]}_repro_heg_m1.fits" "acisf${ids[id]}_repro_heg_m1.bkg"
#    tg_bkg "acisf${ids[id]}_repro_meg_p1.fits" "acisf${ids[id]}_repro_meg_p1.bkg"
#    tg_bkg "acisf${ids[id]}_repro_meg_m1.fits" "acisf${ids[id]}_repro_meg_m1.bkg"
#    
#    # Link the rmf files
#    fthedit "acisf${ids[id]}_repro_heg_p1.fits" RESPFILE add "acisf${ids[id]}_repro_heg_p1.rmf"
#    fthedit "acisf${ids[id]}_repro_heg_m1.fits" RESPFILE add "acisf${ids[id]}_repro_heg_m1.rmf"
#    fthedit "acisf${ids[id]}_repro_meg_p1.fits" RESPFILE add "acisf${ids[id]}_repro_meg_p1.rmf"
#    fthedit "acisf${ids[id]}_repro_meg_m1.fits" RESPFILE add "acisf${ids[id]}_repro_meg_m1.rmf"
#    
#    # Link the arf files
#    fthedit "acisf${ids[id]}_repro_heg_p1.fits" ANCRFILE add "acisf${ids[id]}_repro_heg_p1.arf"
#    fthedit "acisf${ids[id]}_repro_heg_m1.fits" ANCRFILE add "acisf${ids[id]}_repro_heg_m1.arf"
#    fthedit "acisf${ids[id]}_repro_meg_p1.fits" ANCRFILE add "acisf${ids[id]}_repro_meg_p1.arf"
#    fthedit "acisf${ids[id]}_repro_meg_m1.fits" ANCRFILE add "acisf${ids[id]}_repro_meg_m1.arf"
#    
#    # Attempt to group the grating spectra
#    dmgroup infile="acisf${ids[id]}_repro_heg_p1.fits[SPECTRUM]" \
#    	outfile="acisf${ids[id]}_repro_heg_p1.pha" \
#    	binspec="1:16384:100" grouptypeval="" grouptype=BIN ycolumn="counts" xcolumn="channel"
#    
#    dmgroup infile="acisf${ids[id]}_repro_heg_m1.fits[SPECTRUM]" \
#    	outfile="acisf${ids[id]}_repro_heg_m1.pha" \
#    	binspec="1:16384:100" grouptypeval="" grouptype=BIN ycolumn="counts" xcolumn="channel"
#    
#    dmgroup infile="acisf${ids[id]}_repro_meg_p1.fits[SPECTRUM]" \
#    	outfile="acisf${ids[id]}_repro_meg_p1.pha" \
#    	binspec="1:16384:100" grouptypeval="" grouptype=BIN ycolumn="counts" xcolumn="channel"
#    
#    dmgroup infile="acisf${ids[id]}_repro_meg_m1.fits[SPECTRUM]" \
#    	outfile="acisf${ids[id]}_repro_meg_m1.pha" \
#    	binspec="1:16384:100" grouptypeval="" grouptype=BIN ycolumn="counts" xcolumn="channel"
#}

function mk_psf {
    ################################################################
    # Simulate PSF
    # Extract some parameter values
    # This is just to find the off-axis angle theta, in arcminutes
    punlearn dmcoords
    dmcoords acisf${ids[id]}_repro_evt2_03_10_clean.fits option=sky x=${xx} y=${yy} celfmt=deg
    pget dmcoords theta phi

    dmkeypar acisf${ids[id]}_repro_evt2_03_10_clean.fits OBS_ID echo+
    dmkeypar acisf${ids[id]}_repro_evt2_03_10_clean.fits OBI_NUM echo+
    
    # Make an XSPEC and a Python script
    # Just dumps the XSPEC model into 2 arrays
    printf "tclout energies
echo \$xspec_tclout > tmp.ene
tclout modval
echo \$xspec_tclout > tmp.flx"  > get_mod.xcm

    # Converts the XSPEC output into something that Chart/MARX
    # understand that can be used for PSF simulations
    printf "import numpy as np

bins = np.loadtxt('tmp.ene')
flux = np.loadtxt('tmp.flx')

keep = (bins < 10) & (bins > 0.3)
nn = np.sum(keep)-1
bins = bins[keep]
out = np.zeros((nn, 3))
out[:,0] = bins[:-1]
out[:,1] = bins[1:]
out[:,2] = flux[keep[:-1]][:-1]

np.savetxt('simulate_psf_spectrum.txt',out)" > xspec2chart.py

    # Run the two aforementioned scripts, the blank lines accept
    # defaults in XSPEC model!
    xspec << EOF
    query yes
    data acisf${ids[id]}_repro_0th.pha
    ignore **-0.3 10.-**
    mo pha(bb+bknpow)







    renorm
    fit
    @get_mod.xcm
EOF
    python xspec2chart.py # fit a model!

    # Run MARX
    simulate_psf infile=acisf${ids[id]}_repro_evt2_03_10_clean.fits \
    	     outroot=acisf${ids[id]}_repro_psf                      \
    	     ra=${ra_deg}                                           \
    	     dec=${de_deg}                                          \
    	     spectrum=simulate_psf_spectrum.txt                     \
    	     blur=0.07                                              \
    	     readout_streak=yes                                     \
    	     pileup=yes                                             \
    	     ideal=no                                               \
    	     extended=no                                            \
    	     binsize=0.1                                            \
    	     minsize=32                                             \
    	     numsig=0                                               \
    	     numiter=10
    # I have my own modification of simulate_psf to accept
    # numsig=0. Search my mailbox for "numsig"
    #dmcopy psf_ideal_yes.psf"[534:734,537:737]" psf_ideal_yes.fits clobber=yes
}

#function clr_all {
#    ################################################################
#    # Move all spectra to spectra
#    mkdir spectra
#    mv *?eg_?1.pha spectra/
#    mv *?eg_?1.bkg spectra/
#    mv acisf${ids[id]}_repro_0th* spectra/
#    mv tg/* spectra/
#    print_hlp
#}
#
#function print_hlp {
#    printf "cpd /xs
#setplot energy
#
##data 1:1 acisf${ids[id]}_repro_0th_al.pha
##data 1:2 acisf${ids[id]}_repro_heg_p1.pha
##data 1:3 acisf${ids[id]}_repro_heg_m1.pha
##data 1:4 acisf${ids[id]}_repro_meg_p1.pha
##data 1:5 acisf${ids[id]}_repro_meg_m1.pha
##
##ignore 1: **-0.3 10.-**
##ignore 2: **-0.8 10.-**
##ignore 3: **-0.8 10.-**
##ignore 4: **-0.4  5.-**
##ignore 5: **-0.4  5.-**
#
#data 1:1 acisf${ids[id]}_repro_0th_er.pha
#data 2:2 acisf${ids[id]}_repro_0th_ej.pha
##data 3:3 acisf${ids[id]}_repro_0th_al.pha
#
#ignore 1-3: **-0.3 10.-**
#
#pl lda"  > spectra/load_spec.xcm
#}

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
    # This is epected to set:
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
cd ${wrk_dir}
ids=($(ls -d */ | sed 's#/##'))
nid=${#ids[*]}

ids=(16756)
nid=1

for id in $(seq 0 $(($nid-1)))
do
    cd ${wrk_dir}${ids[id]}
    ids[id]=$(printf %05d ${ids[id]})
#    chandra_repro indir=. outdir=./repro

    get_par
    cd repro
    acis_set_ardlib acisf${ids[id]}_repro_bpix1.fits
#    get_img
#    get_spe
    get_all_spe
#    mk_psf
done
#echo "BLOCK TO PREVENT DAMAGE"

echo "EOF"
