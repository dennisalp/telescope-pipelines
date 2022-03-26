#!/bin/bash -x

# Dry
#wrk_dir="/Users/$USER/dat/cxo/tmp/"
wrk_dir="/Users/$USER/dat/cxo/cas/"

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
    dmextract "acisf${ids[id]}_repro_evt2_03_10.fits[sky=${flare_reg}][bin time=::2048]" \
    	      "acisf${ids[id]}_repro_bkg_lc.fits" \
    	      "opt=ltc1"

    # Find the GTI, uses clean instead of sigma
    deflare "acisf${ids[id]}_repro_bkg_lc.fits" \
    	    "acisf${ids[id]}_repro_gti.fits" \
    	    "method=clean" \
	    "stddev=3" \
    	    "save=acisf${ids[id]}_repro_bkg_lc.ps"

    # Apply the GTI
    dmcopy "acisf${ids[id]}_repro_evt2_03_10.fits[@acisf${ids[id]}_repro_gti.fits]" \
           "acisf${ids[id]}_repro_evt2_03_10_clean.fits"

    dmlist acisf${ids[id]}_repro_evt2_03_10.fits header | grep EXPO
    dmlist acisf${ids[id]}_repro_evt2_03_10_clean.fits header | grep EXPO
    
    # ds9 print regions
    ds9 acisf${ids[id]}_repro_evt2_03_10_clean.fits -scale log -cmap Heat -regions ../src.reg -regions ../bkg.reg -bin buffersize 2048 -zoom to fit -scale log exp 100 -print destination file -print filename acisf${ids[id]}_repro_evt2_03_10_clean_img.ps -print -exit
}

# This gets one zeroth order spectrum for the entire source (i.e. standard)
# refcoord expects de_deg to include the sign, so "+" needs to be added if de_deg isn't negative
function get_spe {
    specextract infile="acisf${ids[id]}_repro_evt2_03_10_clean.fits[sky=${src_reg}]" \
    		outroot="acisf${ids[id]}_repro_0th" \
    		correctpsf=no \
    		weight=yes \
    		grouptype=NUM_CTS \
    		binspec=25

    # Rename and link the files
    mv "acisf${ids[id]}_repro_0th.pi" "acisf${ids[id]}_repro_0th.pha"
    mv "acisf${ids[id]}_repro_0th_grp.pi" "acisf${ids[id]}_repro_0th.grp"
    fthedit "acisf${ids[id]}_repro_0th.pha[0]" RESPFILE add "acisf${ids[id]}_repro_0th.rmf"
    fthedit "acisf${ids[id]}_repro_0th.pha[0]" ANCRFILE add "acisf${ids[id]}_repro_0th.arf"
    fthedit "acisf${ids[id]}_repro_0th.pha[1]" RESPFILE add "acisf${ids[id]}_repro_0th.rmf"
    fthedit "acisf${ids[id]}_repro_0th.pha[1]" ANCRFILE add "acisf${ids[id]}_repro_0th.arf"
    fthedit "acisf${ids[id]}_repro_0th.grp" RESPFILE add "acisf${ids[id]}_repro_0th.rmf"
    fthedit "acisf${ids[id]}_repro_0th.grp" ANCRFILE add "acisf${ids[id]}_repro_0th.arf"
}

#Get spectrum for regions defined carefully by hand
function get_spe_by_hand {
    specextract infile="acisf${ids[id]}_repro_evt2_03_10_clean.fits[sky=region(../by_hand.reg)]" \
    		outroot="acisf${ids[id]}_by_hand" \
    		correctpsf=no \
    		weight=yes \
    		grouptype=NUM_CTS \
    		binspec=25

    # Rename and link the files
    mv "acisf${ids[id]}_by_hand.pi" "acisf${ids[id]}_by_hand.pha"
    mv "acisf${ids[id]}_by_hand_grp.pi" "acisf${ids[id]}_by_hand.grp"
    fthedit "acisf${ids[id]}_by_hand.pha[0]" RESPFILE add "acisf${ids[id]}_by_hand.rmf"
    fthedit "acisf${ids[id]}_by_hand.pha[0]" ANCRFILE add "acisf${ids[id]}_by_hand.arf"
    fthedit "acisf${ids[id]}_by_hand.pha[1]" RESPFILE add "acisf${ids[id]}_by_hand.rmf"
    fthedit "acisf${ids[id]}_by_hand.pha[1]" ANCRFILE add "acisf${ids[id]}_by_hand.arf"
    fthedit "acisf${ids[id]}_by_hand.grp" RESPFILE add "acisf${ids[id]}_by_hand.rmf"
    fthedit "acisf${ids[id]}_by_hand.grp" ANCRFILE add "acisf${ids[id]}_by_hand.arf"
}

function clean {
    for ff in *.ps
    do
	ps2pdf ${ff}
    done
    rm *.ps
}

################################################################

source /usr/local/ciao-4.11/bin/ciao.bash
cd ${wrk_dir}
ids=($(ls -d */ | sed 's#/##'))
nid=${#ids[*]}

#ids=(13783)
#nid=1

for id in $(seq 0 $(($nid-1)))
do
    cd ${wrk_dir}${ids[id]}
    ids[id]=$(printf %05d ${ids[id]})
    echo ${ids[id]}
#    chandra_repro indir=. outdir=./repro

#    . par.sh
    cd repro
    acis_set_ardlib acisf${ids[id]}_repro_bpix1.fits
#    get_img
#    get_spe
    get_spe_by_hand
#    clean
done

echo "EOF"
