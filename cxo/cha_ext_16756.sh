#!/bin/bash -x

# Parameters
ID=16756
src_reg="circle(4077.8788,4084.2184,16.256681)"
xlo=4046
xhi=4110
ylo=4052
yhi=4116

################################################################
# Change to working directory
cd /Users/silver/Dropbox/phd/projects/87a/uplim/cha/${ID}/repro

# Set the correct bad pixel list
acis_set_ardlib "acisf${ID}_repro_bpix1.fits"

# Apply a 0.3 to 10 keV filter
dmcopy "acisf${ID}_repro_evt2.fits[energy=300:10000]" "acisf${ID}_evt2_03_10.fits"

# Create a background light curve. 3.24104 seconds
dmextract infile="acisf${ID}_evt2_03_10.fits[sky=field()-${src_reg}][bin time=::1024]"\
	  outfile=acisf${ID}_bkg_lc.fits\
	  opt=ltc1

# Find the GTI
deflare "acisf${ID}_bkg_lc.fits" \
	"acisf${ID}_gti.fits" \
	method=clean \
	save=acisf${ID}_lc.ps

# Apply the GTI
dmcopy "acisf${ID}_evt2_03_10.fits[@acisf${ID}_gti.fits]" \
       "acisf${ID}_evt2_03_10_clean.fits"

# Super-resolve to 40, 125, and 200 mas
dmcopy "acisf${ID}_evt2_03_10_clean.fits[bin x=${xlo}:${xhi}:0.1, y=${ylo}:${yhi}:0.1]" \
       acisf${ID}_evt2_03_10_subpix_01.fits

dmcopy "acisf${ID}_evt2_03_10_clean.fits[bin x=${xlo}:${xhi}:0.2540650406504065, y=${ylo}:${yhi}:0.2540650406504065]" \
       acisf${ID}_evt2_03_10_subpix_025.fits

dmcopy "acisf${ID}_evt2_03_10_clean.fits[bin x=${xlo}:${xhi}:0.5, y=${ylo}:${yhi}:0.5]" \
       acisf${ID}_evt2_03_10_subpix_05.fits

# Save some sky images
dmcopy "acisf${ID}_evt2_03_10_clean.fits[bin x=${xlo}:${xhi}:0.1, y=${ylo}:${yhi}:0.1][IMAGE]" \
       acisf${ID}_repro_img.fits

################################################################
# Extract the first order HETG/METG spectra
dmtype2split "acisf16756_repro_pha2.fits[tg_part=1,tg_m=1]"  "acisf16756_repro_heg_p1.fits[SPECTRUM]"
dmtype2split "acisf16756_repro_pha2.fits[tg_part=1,tg_m=-1]" "acisf16756_repro_heg_m1.fits[SPECTRUM]"
dmtype2split "acisf16756_repro_pha2.fits[tg_part=2,tg_m=1]"  "acisf16756_repro_meg_p1.fits[SPECTRUM]"
dmtype2split "acisf16756_repro_pha2.fits[tg_part=2,tg_m=-1]" "acisf16756_repro_meg_m1.fits[SPECTRUM]"

tg_bkg "acisf16756_repro_heg_p1.fits" "acisf16756_repro_heg_p1.bkg"
tg_bkg "acisf16756_repro_heg_m1.fits" "acisf16756_repro_heg_m1.bkg"
tg_bkg "acisf16756_repro_meg_p1.fits" "acisf16756_repro_meg_p1.bkg"
tg_bkg "acisf16756_repro_meg_m1.fits" "acisf16756_repro_meg_m1.bkg"

# Link the rmf files
fthedit "acisf16756_repro_heg_p1.fits" RESPFILE add "acisf16756_repro_heg_p1.rmf"
fthedit "acisf16756_repro_heg_m1.fits" RESPFILE add "acisf16756_repro_heg_m1.rmf"
fthedit "acisf16756_repro_meg_p1.fits" RESPFILE add "acisf16756_repro_meg_p1.rmf"
fthedit "acisf16756_repro_meg_m1.fits" RESPFILE add "acisf16756_repro_meg_m1.rmf"

# Link the arf files
fthedit "acisf16756_repro_heg_p1.fits" ANCRFILE add "acisf16756_repro_heg_p1.arf"
fthedit "acisf16756_repro_heg_m1.fits" ANCRFILE add "acisf16756_repro_heg_m1.arf"
fthedit "acisf16756_repro_meg_p1.fits" ANCRFILE add "acisf16756_repro_meg_p1.arf"
fthedit "acisf16756_repro_meg_m1.fits" ANCRFILE add "acisf16756_repro_meg_m1.arf"

# Attempt to group the grating spectra
dmgroup infile="acisf16756_repro_heg_p1.fits[SPECTRUM]" \
	outfile="acisf16756_repro_heg_p1.pha" \
	binspec="1:16384:100" grouptypeval="" grouptype=BIN ycolumn="counts" xcolumn="channel"

dmgroup infile="acisf16756_repro_heg_m1.fits[SPECTRUM]" \
	outfile="acisf16756_repro_heg_m1.pha" \
	binspec="1:16384:100" grouptypeval="" grouptype=BIN ycolumn="counts" xcolumn="channel"

dmgroup infile="acisf16756_repro_meg_p1.fits[SPECTRUM]" \
	outfile="acisf16756_repro_meg_p1.pha" \
	binspec="1:16384:100" grouptypeval="" grouptype=BIN ycolumn="counts" xcolumn="channel"

dmgroup infile="acisf16756_repro_meg_m1.fits[SPECTRUM]" \
	outfile="acisf16756_repro_meg_m1.pha" \
	binspec="1:16384:100" grouptypeval="" grouptype=BIN ycolumn="counts" xcolumn="channel"
	
################################################################
# Extract zeroth order spectrum of ejecta+ER
specextract infile="acisf${ID}_evt2_03_10_clean.fits[sky=region(outer.reg)]" \
	    bkgfile="acisf${ID}_evt2_03_10_clean.fits[sky=region(bkg.reg)]" \
	    outroot="acisf16756_repro_0th_al" \
	    correctpsf=no \
	    weight=no \
	    bkgresp=no \
	    grouptype=NUM_CTS \
	    binspec=20

# Rename and link the files
mv "acisf16756_repro_0th_al.pi" "acisf16756_repro_0th_al.fits"
mv "acisf16756_repro_0th_al_grp.pi" "acisf16756_repro_0th_al.pha"
mv "acisf16756_repro_0th_al_bkg.pi" "acisf16756_repro_0th_al.bkg"
fthedit "acisf16756_repro_0th_al.pha" BACKFILE add "acisf16756_repro_0th_al.bkg"
fthedit "acisf16756_repro_0th_al.pha" RESPFILE add "acisf16756_repro_0th_al.rmf"
fthedit "acisf16756_repro_0th_al.pha" ANCRFILE add "acisf16756_repro_0th_al.arf"

# Extract zeroth order spectrum of the ejecta
specextract infile="acisf${ID}_evt2_03_10_clean.fits[sky=region(inner.reg)]" \
	    bkgfile="acisf${ID}_evt2_03_10_clean.fits[sky=region(bkg.reg)]" \
	    outroot="acisf16756_repro_0th_ej" \
	    correctpsf=no \
	    weight=no \
	    bkgresp=no \
	    grouptype=NUM_CTS \
	    binspec=20

# Rename and link the files
mv "acisf16756_repro_0th_ej.pi" "acisf16756_repro_0th_ej.fits"
mv "acisf16756_repro_0th_ej_grp.pi" "acisf16756_repro_0th_ej.pha"
mv "acisf16756_repro_0th_ej_bkg.pi" "acisf16756_repro_0th_ej.bkg"
fthedit "acisf16756_repro_0th_ej.pha" BACKFILE add "acisf16756_repro_0th_ej.bkg"
fthedit "acisf16756_repro_0th_ej.pha" RESPFILE add "acisf16756_repro_0th_ej.rmf"
fthedit "acisf16756_repro_0th_ej.pha" ANCRFILE add "acisf16756_repro_0th_ej.arf"

# Get the aperture correction
arfcorr infile="acisf${ID}_repro_img.fits" \
	arf="" \
	outfile="acisf${ID}_repro_psf.fits" \
	region="region(inner.reg)" \
	x=4077.8788 \
	y=4084.2184 \
	energy=2. \
	radlim=3.0 \
	verbose=1

# Extract zeroth order spectrum of the ER
specextract infile="acisf${ID}_evt2_03_10_clean.fits[sky=$(sed -n '2p' outer.reg)-$(sed -n '2p' inner.reg)]" \
	    bkgfile="acisf${ID}_evt2_03_10_clean.fits[sky=region(bkg.reg)]" \
	    outroot="acisf16756_repro_0th_er" \
	    correctpsf=no \
	    weight=no \
	    bkgresp=no \
	    grouptype=NUM_CTS \
	    binspec=20

# Rename and link the files
mv "acisf16756_repro_0th_er.pi" "acisf16756_repro_0th_er.fits"
mv "acisf16756_repro_0th_er_grp.pi" "acisf16756_repro_0th_er.pha"
mv "acisf16756_repro_0th_er_bkg.pi" "acisf16756_repro_0th_er.bkg"
fthedit "acisf16756_repro_0th_er.pha" BACKFILE add "acisf16756_repro_0th_er.bkg"
fthedit "acisf16756_repro_0th_er.pha" RESPFILE add "acisf16756_repro_0th_er.rmf"
fthedit "acisf16756_repro_0th_er.pha" ANCRFILE add "acisf16756_repro_0th_er.arf"


################################################################
# Move all spectra to spectra
mkdir spectra
mv *?eg_?1.pha spectra/
mv *?eg_?1.bkg spectra/
mv acisf16756_repro_0th* spectra/
cp tg/* spectra/
cp /Users/silver/Dropbox/bin/cha_xsp_16756.xcm /Users/silver/Dropbox/phd/projects/87a/uplim/cha/16756/repro/spectra/

################################################################
# Simulate PSF
# Extract some parameter values
##punlearn dmcoords
##dmcoords acisf16756_evt2_03_10_clean.fits << EOF
##cel 05:35:27.964 -69:16:11.03
##EOF
##punlearn dmcoords
##dmcoords acisf16756_evt2_03_10_clean.fits op=cel ra=05:35:27.964 dec=-69:16:11.03 celfmt=hms
##pget dmcoords theta phi
##
##dmkeypar acisf16756_evt2_03_10_clean.fits OBS_ID echo+
##dmkeypar acisf16756_evt2_03_10_clean.fits OBI_NUM echo+
##
### Make an XSPEC and a Python script
##printf "tclout energies
##echo \$xspec_tclout > /Users/silver/Dropbox/phd/projects/87a/uplim/cha/16756/repro/spectra/tmp.ene
##tclout modval
##echo \$xspec_tclout > /Users/silver/Dropbox/phd/projects/87a/uplim/cha/16756/repro/spectra/tmp.flx"  > /Users/silver/Dropbox/phd/projects/87a/uplim/cha/16756/repro/spectra/get_mod.xcm
##
##printf "import numpy as np
##
##bins = np.loadtxt('cha.ene')
##flux = np.loadtxt('cha.flx')
##
##keep = (bins < 10) & (bins > 0.3)
##nn = np.sum(keep)-1
##bins = bins[keep]
##out = np.zeros((nn, 3))
##out[:,0] = bins[:-1]
##out[:,1] = bins[1:]
##out[:,2] = flux[keep[:-1]][:-1]
##
##np.savetxt('cha.txt',out)" > /Users/silver/Dropbox/phd/projects/87a/uplim/cha/16756/repro/spectra/xspec2chart.py
##
##cd spectra/
##xspec << EOF
##@pha_con_veq_vps_bkn.xcm
##@get_mod.xcm
##EOF
##python xspec2chart.py
##cd ../
##
### Run MARX
##simulate_psf infile=acisf16756_evt2_03_10_clean.fits  \
##	     outroot=psf_ideal_no                      \
##	     ra=83.866516                               \
##	     dec=-69.26973                              \
##	     spectrum=spectra/cha.txt                   \
##	     blur=0.07                                  \
##	     readout_streak=yes                         \
##	     pileup=yes                                 \
##	     ideal=no                                  \
##	     extended=no                                \
##	     binsize=0.1                                \
##	     minsize=128                                \
##	     numsig=0                                   \
##	     numiter=1024
##
###dmcopy psf_ideal_yes.psf"[534:734,537:737]" psf_ideal_yes.fits clobber=yes
