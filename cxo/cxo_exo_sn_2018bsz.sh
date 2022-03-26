#!/bin/bash

################################################################
# Notes
# Set the correct bad pixel list, chandra_repro creates a bad pixel
# file and sets this as the current file. So, if extraction is
# performed right after repro all's fine. However, if going back, then
# SET THE BAD PIXEL FILE TO THE ONE CREATED BY chandra_repro FOR THE
# SPECIFIC OBSERVATION
#acis_set_ardlib "acisf${ID}_repro_bpix1.fits"

function get_img {
    # Apply a 0.3 to 10 keV filter
    # dmcopy "acisf${ids[id]}_repro_evt2.fits[energy=300:10000]" \
    #        "acisf${ids[id]}_repro_evt2_03_10.fits"

    # # Create a background light curve
    # dmextract "acisf${ids[id]}_repro_evt2_03_10.fits[bin time=::2048]" \
    # 	      "acisf${ids[id]}_repro_bkg_lc.fits" \
    # 	      "opt=ltc1"

    # # Find the GTI, uses clean instead of sigma
    # deflare "acisf${ids[id]}_repro_bkg_lc.fits" \
    # 	    "acisf${ids[id]}_repro_gti.fits" \
    # 	    "method=clean" \
    #         "stddev=3" \
    # 	    "save=acisf${ids[id]}_repro_bkg_lc.ps"

    # # Apply the GTI
    # dmcopy "acisf${ids[id]}_repro_evt2_03_10.fits[@acisf${ids[id]}_repro_gti.fits]" \
    #        "acisf${ids[id]}_repro_evt2_03_10_clean.fits"

    # dmlist acisf${ids[id]}_repro_evt2_03_10.fits header | grep EXPO
    # dmlist acisf${ids[id]}_repro_evt2_03_10_clean.fits header | grep EXPO
    
    # ds9 print regions
    ds9 acisf${ids[id]}_repro_evt2_03_10_clean.fits -scale log -cmap Heat -regions ../../src_${ids[id]}.reg -regions ../../bkg_${ids[id]}.reg -bin buffersize 2048 -zoom 30 -scale linear -pan to ${coords} wcs -print destination file -print filename acisf${ids[id]}_repro_evt2_03_10_clean_img.ps -print -exit
}

# This gets one zeroth order spectrum for the entire source (i.e. standard)
# refcoord expects de_deg to include the sign, so "+" needs to be added if de_deg isn't negative
function get_spe {
    specextract infile="acisf${ids[id]}_repro_evt2_03_10_clean.fits[sky=region(../../src_${ids[id]}.reg)]" \
                bkgfile="acisf${ids[id]}_repro_evt2_03_10_clean.fits[sky=region(../../bkg_${ids[id]}.reg)]" \
    		outroot="acisf${ids[id]}_repro_0th" \
    		correctpsf=yes \
    		weight=no \
                grouptype=NONE \
                binspec=NONE
    
    # Rename and link the files
    fthedit "acisf${ids[id]}_repro_0th.pi[0]" RESPFILE add "acisf${ids[id]}_repro_0th.rmf"
    fthedit "acisf${ids[id]}_repro_0th.pi[0]" ANCRFILE add "acisf${ids[id]}_repro_0th.corr.arf"
    fthedit "acisf${ids[id]}_repro_0th.pi[1]" RESPFILE add "acisf${ids[id]}_repro_0th.rmf"
    fthedit "acisf${ids[id]}_repro_0th.pi[1]" ANCRFILE add "acisf${ids[id]}_repro_0th.corr.arf"
    fthedit "acisf${ids[id]}_repro_0th.pi[0]" BACKFILE add "acisf${ids[id]}_repro_0th_bkg.pi"
    fthedit "acisf${ids[id]}_repro_0th.pi[1]" BACKFILE add "acisf${ids[id]}_repro_0th_bkg.pi"
}

function clean {
    for ff in *.ps
    do
	ps2pdf ${ff}
    done
    rm *.ps
}

################################################################

wrk_dir="/Users/silver/dat/cxo/bsz/"
ids=(20290 20289 20291 21665)
coords="16:09:39.110 -32:03:45.63"



source /usr/local/ciao-4.12/bin/ciao.bash
nid=${#ids[@]}

for id in $(seq 0 $(($nid-1)))
do
    cd ${wrk_dir}${ids[id]}
    ids[id]=$(printf %05d ${ids[id]})
    echo ${ids[id]}

    # chandra_repro indir=. outdir=./repro

    cd repro
    acis_set_ardlib acisf${ids[id]}_repro_bpix1.fits
    # get_img
    # get_spe
    # clean
done

cd ../../merge/spec/
# combine_spectra acisf20290_repro_0th.pi,acisf20289_repro_0th.pi,acisf20291_repro_0th.pi,acisf21665_repro_0th.pi bsz_spec_merged

cd ../../
# reproject_obs "*/repro/*evt2_03_10_clean.fits" merge/rep/
cd merge/rep/
# dmcopy "merged_evt.fits[energy=300:1500]" \
#        "merged_evt_r.fits"
# dmcopy "merged_evt.fits[energy=1500:3000]" \
#        "merged_evt_g.fits"
# dmcopy "merged_evt.fits[energy=3000:10000]" \
#        "merged_evt_b.fits"
ds9 -rgb -red merged_evt_r.fits -green merged_evt_g.fits -blue merged_evt_b.fits

echo "EOF"
