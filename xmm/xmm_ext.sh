#!/bin/bash
source /Users/$USER/sas/xmmsas_20180620_1732/setsas.sh

WD='/Users/silver/dat/xmm/kes/0550671801_dalp'
odf='/Users/silver/dat/xmm/kes/0550671801/odf'
ra=283.160709
dec=0.6721667
WD='/Users/silver/dat/xmm/cas/0650450201_dalp'
odf='/Users/silver/dat/xmm/cas/0650450201/odf'
ra=350.8664292
dec=58.8118083

# REFINE # mkdir -p ${WD}
cd ${WD}
export SAS_CCFPATH=/Users/silver/ccf
# REFINE # export SAS_ODF=${odf}
# REFINE # cifbuild
export SAS_CCF=ccf.cif
# REFINE # odfingest
export SAS_ODF=$(ls -1 *SUM.SAS)
# REFINE # 
# REFINE # # Raw event list
# REFINE # epproc
# REFINE # mv *ImagingEvts.ds epn.evt

# Light curve for flares
evselect table=epn.evt \
	 withrateset=Y \
	 rateset=bkg.lc \
	 maketimecolumn=Y \
	 timebinsize=100 \
	 makeratecolumn=Y \
	 expression='#XMMEA_EP && (PI>10000&&PI<12000) && (PATTERN==0)'

# GTI
tabgtigen table=bkg.lc \
	  expression='RATE<=0.4' \
	  gtiset=epn.gti

# Clean event list
evselect table=epn.evt \
	 withfilteredset=yes \
	 expression="(PATTERN <= 12) && (PI in [150:15000]) && #XMMEA_EP && gti(epn.gti,TIME)" \
	 filteredset=epn_cl.evt \
	 filtertype=expression \
	 keepfilteroutput=yes \
	 updateexposure=yes \
	 filterexposure=yes

# Raw image
evselect table=epn.evt \
	 withimageset=yes \
	 imageset=epn.img \
	 xcolumn=X \
	 ycolumn=Y \
	 imagebinning=imageSize \
	 ximagesize=600 \
	 yimagesize=600

# Clean image
evselect table=epn_cl.evt \
	 withimageset=yes \
	 imageset=epn_cl.img \
	 xcolumn=X \
	 ycolumn=Y \
	 imagebinning=imageSize \
	 ximagesize=600 \
	 yimagesize=600

# Clean light curve
evselect table=epn_cl.evt \
	 withrateset=yes \
	 rateset=epn_cl.lc \
	 maketimecolumn=yes \
	 timecolumn=TIME \
	 timebinsize=100 \
	 makeratecolumn=yes

# Check for pile-up
epatplot set=epn_cl.evt \
	 plotfile=epn_pu.ps \
	 useplotfile=yes

# Barycentric correction
cp epn_cl.evt epn_cl_bc.evt
barycen table=epn_cl_bc.evt:EVENTS \
	srcra=${ra} \
	srcdec=${dec}

# PSF
psfgen image=epn_cl.img \
       energy=500 \
       level=ELLBETA \
       coordtype=EQPOS \
       x=${ra} \
       y=${dec} \
       xsize=400 \
       ysize=400 \
       output=epn_0500.psf

psfgen image=epn_cl.img \
       energy=1000 \
       level=ELLBETA \
       coordtype=EQPOS \
       x=${ra} \
       y=${dec} \
       xsize=400 \
       ysize=400 \
       output=epn_1000.psf

psfgen image=epn_cl.img \
       energy=2000 \
       level=ELLBETA \
       coordtype=EQPOS \
       x=${ra} \
       y=${dec} \
       xsize=400 \
       ysize=400 \
       output=epn_2000.psf

# 0650450201, 0650450301, 0650450401 BY HAND
evselect table=epn.evt \
	 withfilteredset=yes \
	 expression="(PATTERN <= 12) && (PI in [150:15000]) && #XMMEA_EP" \
	 filteredset=byh_epn_cl.evt \
	 filtertype=expression \
	 keepfilteroutput=yes \
	 updateexposure=yes \
	 filterexposure=yes

evselect table=byh_epn_cl.evt \
	 withimageset=yes \
	 imageset=byh_epn_cl.img \
	 xcolumn=X \
	 ycolumn=Y \
	 imagebinning=imageSize \
	 ximagesize=600 \
	 yimagesize=600

evselect table=byh_epn_cl.evt \
	 withrateset=yes \
	 rateset=byh_epn_cl.lc \
	 maketimecolumn=yes \
	 timecolumn=TIME \
	 timebinsize=100 \
	 makeratecolumn=yes

cp byh_epn_cl.evt byh_epn_cl_bc.evt
barycen table=byh_epn_cl_bc.evt:EVENTS \
	srcra=${ra} \
	srcdec=${dec}
