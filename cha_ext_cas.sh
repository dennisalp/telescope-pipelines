#!/bin/bash -x

# This is the dedicated Cas A CCO extractor for Chandra/ACIS
# SN 1987A needs more careful regions for ER and ejecta
# Cas A needs more careful background subtraction because of the
# extended nebular emission

# Dry
wrk_dir="/Users/$USER/dat/cxo/tmp/"

# Cas A
wrk_dir="/Users/$USER/dat/cxo/cas/"

ra="23h23m27.943s"
de="58d48m42.51s"

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

    # Create a background light curve
    dmextract "acisf${ids[id]}_repro_evt2_03_10.fits[sky=${flare_reg}][bin time=::1024]" \
    	      "acisf${ids[id]}_repro_bkg_lc.fits" \
    	      "opt=ltc1"

    # Find the GTI, uses clean instead of sigma
    deflare "acisf${ids[id]}_repro_bkg_lc.fits" \
    	    "acisf${ids[id]}_repro_gti.fits" \
    	    "method=clean" \
	    "stddev=4" \
    	    "save=acisf${ids[id]}_repro_bkg_lc.ps"

    # Create a source light curve
    dmextract "acisf${ids[id]}_repro_evt2_03_10.fits[sky=${src_reg}][bin time=::4096]" \
    	      "acisf${ids[id]}_repro_src_lc.fits" \
    	      "opt=ltc1"
    
    # Make source light curve
    deflare "acisf${ids[id]}_repro_src_lc.fits" \
	    "acisf${ids[id]}_repro_tmp.fits" \
    	    "method=clean" \
	    "stddev=4" \
    	    "save=acisf${ids[id]}_repro_src_lc.ps"
    
    # Apply the GTI
    dmcopy "acisf${ids[id]}_repro_evt2_03_10.fits[@acisf${ids[id]}_repro_gti.fits]" \
           "acisf${ids[id]}_repro_evt2_03_10_clean.fits"

    # High resolution image with cuts to save some space
    dmcopy "acisf${ids[id]}_repro_evt2_03_10_clean.fits[bin x=${xlo}:${xhi}:0.1, y=${ylo}:${yhi}:0.1][IMAGE]" \
           "acisf${ids[id]}_repro_evt2_03_10_clean_img.fits"

    # ds9 print regions
    ds9 acisf${ids[id]}_repro_evt2_03_10_clean.fits -scale log -cmap Heat -regions ../src.reg -regions ../bkg.reg -zoom 5 -scale log exp 100 -print destination file -print filename acisf${ids[id]}_repro_evt2_03_10_clean_img.ps -print -exit
}

# This gets one zeroth order spectrum for the entire source (i.e. standard)
# refcoord expects de_deg to include the sign, so "+" needs to be added if de_deg isn't negative
function get_spe {
    specextract infile="acisf${ids[id]}_repro_evt2_03_10_clean.fits[sky=${src_reg}]" \
    		bkgfile="acisf${ids[id]}_repro_evt2_03_10_clean.fits[sky=${bkg_reg}]" \
    		outroot="acisf${ids[id]}_repro_0th" \
    		correctpsf=yes \
    		weight=no \
    		bkgresp=no \
		refcoord="${ra_deg}, ${de_deg}" \
    		grouptype=SNR \
    		binspec=10

    # Rename and link the files
    mv "acisf${ids[id]}_repro_0th.pi" "acisf${ids[id]}_repro_0th.fits"
    mv "acisf${ids[id]}_repro_0th_grp.pi" "acisf${ids[id]}_repro_0th.pha"
    mv "acisf${ids[id]}_repro_0th_bkg.pi" "acisf${ids[id]}_repro_0th.bkg"
    mv "acisf${ids[id]}_repro_0th.corr.arf" "acisf${ids[id]}_repro_0th.arf"
    fthedit "acisf${ids[id]}_repro_0th.pha" BACKFILE add "acisf${ids[id]}_repro_0th.bkg"
    fthedit "acisf${ids[id]}_repro_0th.pha" RESPFILE add "acisf${ids[id]}_repro_0th.rmf"
    fthedit "acisf${ids[id]}_repro_0th.pha" ANCRFILE add "acisf${ids[id]}_repro_0th.arf"
}

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

function clean {
    for ff in *.ps
    do
	ps2pdf ${ff}
    done
    rm *.ps
}

################################################################

source /usr/local/ciao-4.9/bin/ciao.bash
cd ${wrk_dir}
ids=($(ls -d */ | sed 's#/##'))
nid=${#ids[*]}

#ids=(13783)
#nid=1

for id in $(seq 0 $(($nid-1)))
do
    cd ${wrk_dir}${ids[id]}
    ids[id]=$(printf %05d ${ids[id]})
#    chandra_repro indir=. outdir=./repro

    . par.sh
    cd repro
    acis_set_ardlib acisf${ids[id]}_repro_bpix1.fits
    get_img
    get_spe
    mk_psf
    clean
done

echo "EOF"
