#!/bin/bash -x



################################################################
# Help functions
################################################################
print_src () {
  printf "# Region file format: DS9 version 4.1
global color=green dashlist=8 3 width=2 font=\"helvetica 10 normal roman\" select=1 highlite=1 dash=0 fixed=0 edit=1 move=1 delete=1 include=1 source=1
detector
${2}" > ${1}
}
print_bkg () {
  printf "# Region file format: DS9 version 4.1
global color=white dashlist=8 3 width=2 font=\"helvetica 10 normal roman\" select=1 highlite=1 dash=0 fixed=0 edit=1 move=1 delete=1 include=1 source=1
detector
${2}" > ${1}
}



################################################################
# Parameters
################################################################
id="default"
rate_pn=0.4
rate_m1=0.35
rate_m2=0.35

id="0149780101"
rate_pn=0.4
rate_m1=0.24
rate_m2=0.24
pn_src="circle(34540.688,14569.293,400)"
m1_src="circle(34540.688,14569.293,400)"
m2_src="circle(34540.688,14569.293,400)"
pn_bkg="annulus(34540.688,14569.293,1000,2000)"
m1_bkg="annulus(34540.688,14569.293,1000,2000)"
m2_bkg="annulus(34540.688,14569.293,700,1400)"
t0=160890800
t1=160891450
timemin=160880000
timemax=160920000
tbin=10
coo="01:57:09.1118 +37:37:39.5687"

id="0203560201"
rate_pn=0.4
rate_m1=0.24
rate_m2=0.24
pn_src="circle(34540.688,14569.293,400)"
m1_src="circle(34540.688,14569.293,400)"
m2_src="circle(34540.688,14569.293,400)"
pn_bkg="annulus(34540.688,14569.293,1000,2000)"
m1_bkg="annulus(34540.688,14569.293,1000,2000)"
m2_bkg="annulus(34540.688,14569.293,700,1400)"
t0=160890800
t1=160891450
timemin=160880000
timemax=160920000
tbin=10
coo="01:57:09.1118 +37:37:39.5687"

id="0300240501"
rate_pn=0.4
rate_m1=0.24
rate_m2=0.24
pn_src="circle(34540.688,14569.293,400)"
m1_src="circle(34540.688,14569.293,400)"
m2_src="circle(34540.688,14569.293,400)"
pn_bkg="annulus(34540.688,14569.293,1000,2000)"
m1_bkg="annulus(34540.688,14569.293,1000,2000)"
m2_bkg="annulus(34540.688,14569.293,700,1400)"
t0=160890800
t1=160891450
timemin=160880000
timemax=160920000
tbin=10
coo="01:57:09.1118 +37:37:39.5687"

id="0300930301"
rate_pn=0.4
rate_m1=0.24
rate_m2=0.24
pn_src="circle(34540.688,14569.293,400)"
m1_src="circle(34540.688,14569.293,400)"
m2_src="circle(34540.688,14569.293,400)"
pn_bkg="annulus(34540.688,14569.293,1000,2000)"
m1_bkg="annulus(34540.688,14569.293,1000,2000)"
m2_bkg="annulus(34540.688,14569.293,700,1400)"
t0=160890800
t1=160891450
timemin=160880000
timemax=160920000
tbin=10
coo="01:57:09.1118 +37:37:39.5687"

id="0502020101"
rate_pn=1.5
rate_m1=0.35
rate_m2=0.35
pn_src="circle(35299.705,25221.758,400)"
m1_src="circle(35299.705,25221.758,400)"
m2_src="circle(35299.705,25221.758,400)"
pn_bkg="circle(36794.32,24507.207,1008.2344)"
m1_bkg="annulus(35299.705,25221.768,1400,1800)"
m2_bkg="circle(34071.746,24905.465,775.63339)"
t0=298587650
t1=298587900
timemin=298540000
timemax=298620000
tbin=10
coo="01:37:06.0815 -12:57:09.1395"

id="0555780101"
rate_pn=1.5
rate_m1=0.35
rate_m2=0.35
pn_src="circle(35299.705,25221.758,400)"
m1_src="circle(35299.705,25221.758,400)"
m2_src="circle(35299.705,25221.758,400)"
pn_bkg="circle(36794.32,24507.207,1008.2344)"
m1_bkg="annulus(35299.705,25221.768,1400,1800)"
m2_bkg="circle(34071.746,24905.465,775.63339)"
t0=298587650
t1=298587900
timemin=298540000
timemax=298620000
tbin=10
coo="01:37:06.0815 -12:57:09.1395"

id="0604740101"
rate_pn=1.5
rate_m1=0.35
rate_m2=0.35
pn_src="circle(35299.705,25221.758,400)"
m1_src="circle(35299.705,25221.758,400)"
m2_src="circle(35299.705,25221.758,400)"
pn_bkg="circle(36794.32,24507.207,1008.2344)"
m1_bkg="annulus(35299.705,25221.768,1400,1800)"
m2_bkg="circle(34071.746,24905.465,775.63339)"
t0=298587650
t1=298587900
timemin=298540000
timemax=298620000
tbin=10
coo="01:37:06.0815 -12:57:09.1395"

id="0651690101"
rate_pn=1.5
rate_m1=0.35
rate_m2=0.35
pn_src="circle(35299.705,25221.758,400)"
m1_src="circle(35299.705,25221.758,400)"
m2_src="circle(35299.705,25221.758,400)"
pn_bkg="circle(36794.32,24507.207,1008.2344)"
m1_bkg="annulus(35299.705,25221.768,1400,1800)"
m2_bkg="circle(34071.746,24905.465,775.63339)"
t0=298587650
t1=298587900
timemin=298540000
timemax=298620000
tbin=10
coo="01:37:06.0815 -12:57:09.1395"

id="0675010401"
rate_pn=1.5
rate_m1=0.35
rate_m2=0.35
pn_src="circle(35299.705,25221.758,400)"
m1_src="circle(35299.705,25221.758,400)"
m2_src="circle(35299.705,25221.758,400)"
pn_bkg="circle(36794.32,24507.207,1008.2344)"
m1_bkg="annulus(35299.705,25221.768,1400,1800)"
m2_bkg="circle(34071.746,24905.465,775.63339)"
t0=298587650
t1=298587900
timemin=298540000
timemax=298620000
tbin=10
coo="01:37:06.0815 -12:57:09.1395"

id="0743650701"
rate_pn=1.5
rate_m1=0.35
rate_m2=0.35
pn_src="circle(35299.705,25221.758,400)"
m1_src="circle(35299.705,25221.758,400)"
m2_src="circle(35299.705,25221.758,400)"
pn_bkg="circle(36794.32,24507.207,1008.2344)"
m1_bkg="annulus(35299.705,25221.768,1400,1800)"
m2_bkg="circle(34071.746,24905.465,775.63339)"
t0=298587650
t1=298587900
timemin=298540000
timemax=298620000
tbin=10
coo="01:37:06.0815 -12:57:09.1395"

id="0760380201"
rate_pn=1.5
rate_m1=0.35
rate_m2=0.35
pn_src="circle(35299.705,25221.758,400)"
m1_src="circle(35299.705,25221.758,400)"
m2_src="circle(35299.705,25221.758,400)"
pn_bkg="circle(36794.32,24507.207,1008.2344)"
m1_bkg="annulus(35299.705,25221.768,1400,1800)"
m2_bkg="circle(34071.746,24905.465,775.63339)"
t0=298587650
t1=298587900
timemin=298540000
timemax=298620000
tbin=10
coo="01:37:06.0815 -12:57:09.1395"

id="0765041301"
rate_pn=1.5
rate_m1=0.35
rate_m2=0.35
pn_src="circle(35299.705,25221.758,400)"
m1_src="circle(35299.705,25221.758,400)"
m2_src="circle(35299.705,25221.758,400)"
pn_bkg="circle(36794.32,24507.207,1008.2344)"
m1_bkg="annulus(35299.705,25221.768,1400,1800)"
m2_bkg="circle(34071.746,24905.465,775.63339)"
t0=298587650
t1=298587900
timemin=298540000
timemax=298620000
tbin=10
coo="01:37:06.0815 -12:57:09.1395"

# This event is not covered by M1
id="0770380401"
rate_pn=99999
rate_m1=99999
rate_m2=99999
pn_src="circle(17805.535,34487.674,400)"
m1_src="circle(17805.535,34487.674,400)"
m2_src="circle(17805.535,34487.674,400)"
pn_bkg="circle(20729.02,34386.429,1940.049)"
m1_bkg="annulus(17805.535,34487.674,800,2400)"
m2_bkg="annulus(17805.535,34487.674,800,2400)"
t0=566882270
t1=566882770
timemin=566869000
timemax=566896000
tbin=30
coo="11:34:07.5046 +00:52:23.8266"

id="0781890401"
rate_pn=1.5
rate_m1=0.35
rate_m2=0.35
pn_src="circle(35299.705,25221.758,400)"
m1_src="circle(35299.705,25221.758,400)"
m2_src="circle(35299.705,25221.758,400)"
pn_bkg="circle(36794.32,24507.207,1008.2344)"
m1_bkg="annulus(35299.705,25221.768,1400,1800)"
m2_bkg="circle(34071.746,24905.465,775.63339)"
t0=298587650
t1=298587900
timemin=298540000
timemax=298620000
tbin=10
coo="01:37:06.0815 -12:57:09.1395"


################################################################
# Some preparation
################################################################
wrk="/Users/silver/dat/xmm/sbo/${id}_repro"
dat="/Users/silver/dat/xmm/sbo/${id}"

if [[ $wrk =~ " " ]]
then
    echo "Path to working is not allowed to contain spaces! (SAS issue)"
    exit 1
fi

ds9='/Applications/SAOImageDS9.app/Contents/MacOS/ds9'
export SAS_DIR="/Users/silver/sas_18.0.0-Darwin-16.7.0-64/xmmsas_20190531_1155"
export SAS_CCFPATH="/Users/silver/ccf"
export SAS_ODF="${dat}/ODF"
export SAS_CCF="${wrk}/ccf.cif"
mkdir -p ${wrk}
cd ${wrk}

print_src "${id}_pn_src.reg" ${pn_src}
print_src "${id}_m1_src.reg" ${m1_src}
print_src "${id}_m2_src.reg" ${m2_src}
print_bkg "${id}_pn_bkg.reg" ${pn_bkg}
print_bkg "${id}_m1_bkg.reg" ${m1_bkg}
print_bkg "${id}_m2_bkg.reg" ${m2_bkg}
. ${SAS_DIR}/setsas.sh



################################################################
# Prepare/setup
################################################################
# cifbuild
# odfingest
export SAS_ODF=$(ls -1 *SUM.SAS)

# odfParamCreator outputFileName=par.xml
# xmmextractor paramfile=par.xml

################################################################
# Run until background flare conditions need to be decided
################################################################
# epproc
# emproc
evselect table=$(ls *EPN*ImagingEvts.ds | head -${pn_exp} | tail -1) withrateset=Y rateset=${id}_pn_bkg_flare.fits \
        maketimecolumn=Y timebinsize=100 makeratecolumn=Y \
        expression="#XMMEA_EP && (PI>10000&&PI<12000) && (PATTERN==0)"
evselect table=$(ls *EMOS1*ImagingEvts.ds | head -${m1_exp} | tail -1) withrateset=Y rateset=${id}_m1_bkg_flare.fits \
        maketimecolumn=Y timebinsize=100 makeratecolumn=Y \
        expression="#XMMEA_EM && (PI>10000) && (PATTERN==0)"
evselect table=$(ls *EMOS2*ImagingEvts.ds | head -${m2_exp} | tail -1) withrateset=Y rateset=${id}_m2_bkg_flare.fits \
        maketimecolumn=Y timebinsize=100 makeratecolumn=Y \
        expression="#XMMEA_EM && (PI>10000) && (PATTERN==0)"
dsplot table=${id}_pn_bkg_flare.fits x=TIME y=RATE
dsplot table=${id}_m1_bkg_flare.fits x=TIME y=RATE
dsplot table=${id}_m2_bkg_flare.fits x=TIME y=RATE

################################################################
# Run until spatial source and background regions need to be selected
# The coordinates and times need to be provided
################################################################
# tabgtigen table=${id}_pn_bkg_flare.fits expression="RATE<=${rate_pn}" gtiset=${id}_pn_gti.fits
# tabgtigen table=${id}_m1_bkg_flare.fits expression="RATE<=${rate_m1}" gtiset=${id}_m1_gti.fits
# tabgtigen table=${id}_m2_bkg_flare.fits expression="RATE<=${rate_m2}" gtiset=${id}_m2_gti.fits
# evselect table=$(ls *EPN*ImagingEvts.ds | head -${pn_exp} | tail -1) withfilteredset=Y \
#         filteredset=${id}_pn_clean_evt.fits \
#         destruct=Y keepfilteroutput=T \
#         expression="#XMMEA_EP && gti(${id}_pn_gti.fits,TIME) && (PI>150)"
# evselect table=$(ls *EMOS1*ImagingEvts.ds | head -${m1_exp} | tail -1) withfilteredset=Y \
#         filteredset=${id}_m1_clean_evt.fits \
#         destruct=Y keepfilteroutput=T \
#         expression="#XMMEA_EM && gti(${id}_m1_gti.fits,TIME) && (PI>150)"
# evselect table=$(ls *EMOS2*ImagingEvts.ds | head -${m2_exp} | tail -1) withfilteredset=Y \
#         filteredset=${id}_m2_clean_evt.fits \
#         destruct=Y keepfilteroutput=T \
#         expression="#XMMEA_EM && gti(${id}_m1_gti.fits,TIME) && (PI>150)"
# cp ${id}_pn_clean_evt.fits ${id}_pn_clean_evt_bary.fits
# cp ${id}_m1_clean_evt.fits ${id}_m1_clean_evt_bary.fits
# cp ${id}_m2_clean_evt.fits ${id}_m2_clean_evt_bary.fits
# ### barycen table=${id}_pn_clean_evt_bary.fits:EVENTS
# ### barycen table=${id}_m1_clean_evt_bary.fits:EVENTS
# ### barycen table=${id}_m2_clean_evt_bary.fits:EVENTS
# evselect table=${id}_pn_clean_evt_bary.fits imagebinning=binSize \
#         imageset=${id}_pn_clean_img.fits withimageset=yes \
#         xcolumn=X ycolumn=Y ximagebinsize=80 yimagebinsize=80
# evselect table=${id}_m1_clean_evt_bary.fits imagebinning=binSize \
#         imageset=${id}_m1_clean_img.fits withimageset=yes \
#         xcolumn=X ycolumn=Y ximagebinsize=80 yimagebinsize=80
# evselect table=${id}_m2_clean_evt_bary.fits imagebinning=binSize \
#         imageset=${id}_m2_clean_img.fits withimageset=yes \
#         xcolumn=X ycolumn=Y ximagebinsize=80 yimagebinsize=80



################################################################
# Run until spatial source and background regions need to be selected
# The extraction regions need to be provided
################################################################
# evselect table=${id}_pn_clean_evt_bary.fits imagebinning=binSize \
#         imageset=${id}_pn_clean_img_short.fits withimageset=yes \
#         xcolumn=X ycolumn=Y ximagebinsize=80 yimagebinsize=80 \
#         expression="TIME>${t0}&&TIME<${t1}"
# ${ds9} ${id}_pn_clean_img.fits -scale log -cmap Heat -regions ${id}_pn_src.reg -pan to ${coo} wcs -zoom 2 -regions ${id}_pn_bkg.reg -print destination file -print filename ${id}_pn_clean_img.ps -print -exit
# ${ds9} ${id}_pn_clean_img_short.fits -scale linear -cmap Heat -regions ${id}_pn_src.reg -pan to ${coo} wcs -zoom 2 -regions ${id}_pn_bkg.reg -print destination file -print filename ${id}_pn_clean_img_short.ps -print -exit

# evselect table=${id}_m1_clean_evt_bary.fits imagebinning=binSize \
#         imageset=${id}_m1_clean_img_short.fits withimageset=yes \
#         xcolumn=X ycolumn=Y ximagebinsize=80 yimagebinsize=80 \
#         expression="TIME>${t0}&&TIME<${t1}"
# ${ds9} ${id}_m1_clean_img.fits -scale log -cmap Heat -regions ${id}_m1_src.reg -pan to ${coo} wcs -zoom 2 -regions ${id}_m1_bkg.reg -print destination file -print filename ${id}_m1_clean_img.ps -print -exit
# ${ds9} ${id}_m1_clean_img_short.fits -scale linear -cmap Heat -regions ${id}_m1_src.reg -pan to ${coo} wcs -zoom 2 -regions ${id}_m1_bkg.reg -print destination file -print filename ${id}_m1_clean_img_short.ps -print -exit

# evselect table=${id}_m2_clean_evt_bary.fits imagebinning=binSize \
#         imageset=${id}_m2_clean_img_short.fits withimageset=yes \
#         xcolumn=X ycolumn=Y ximagebinsize=80 yimagebinsize=80 \
#         expression="TIME>${t0}&&TIME<${t1}"
# ${ds9} ${id}_m2_clean_img.fits -scale log -cmap Heat -regions ${id}_m2_src.reg -pan to ${coo} wcs -zoom 2 -regions ${id}_m2_bkg.reg -print destination file -print filename ${id}_m2_clean_img.ps -print -exit
# ${ds9} ${id}_m2_clean_img_short.fits -scale linear -cmap Heat -regions ${id}_m2_src.reg -pan to ${coo} wcs -zoom 2 -regions ${id}_m2_bkg.reg -print destination file -print filename ${id}_m2_clean_img_short.ps -print -exit

# for ff in *.ps
# do
#    ps2pdf ${ff}
# done
# rm *.ps



################################################################
# Light curves, need to set timemin and timemax
################################################################
# evselect table=${id}_pn_clean_evt_bary.fits energycolumn=PI \
#         expression="#XMMEA_EP&&(PATTERN<=4)&&((X,Y) IN ${pn_src})&&(PI in [200:10000])" \
#         withrateset=yes rateset=${id}_pn_raw_src_lc.fits timebinsize=${tbin} \
#         maketimecolumn=yes makeratecolumn=yes timemin=${timemin} timemax=${timemax}
# evselect table=${id}_pn_clean_evt_bary.fits energycolumn=PI \
#         expression="#XMMEA_EP&&(PATTERN<=4)&&((X,Y) IN ${pn_bkg})&&(PI in [200:10000])" \
#         withrateset=yes rateset=${id}_pn_raw_bkg_lc.fits timebinsize=${tbin} \
#         maketimecolumn=yes makeratecolumn=yes timemin=${timemin} timemax=${timemax}
# epiclccorr srctslist=${id}_pn_raw_src_lc.fits eventlist=${id}_pn_clean_evt_bary.fits \
#           outset=${id}_pn_lccorr.fits bkgtslist=${id}_pn_raw_bkg_lc.fits \
#           withbkgset=yes applyabsolutecorrections=yes
# dsplot table=${id}_pn_lccorr.fits withx=yes x=TIME withy=yes y=RATE

# evselect table=${id}_m1_clean_evt_bary.fits energycolumn=PI \
#         expression="#XMMEA_EM&&(PATTERN<=12)&&((X,Y) IN ${m1_src})&&(PI in [200:10000])" \
#         withrateset=yes rateset=${id}_m1_raw_src_lc.fits timebinsize=${tbin} \
#         maketimecolumn=yes makeratecolumn=yes timemin=${timemin} timemax=${timemax}
# evselect table=${id}_m1_clean_evt_bary.fits energycolumn=PI \
#         expression="#XMMEA_EM&&(PATTERN<=12)&&((X,Y) IN ${m1_bkg})&&(PI in [200:10000])" \
#         withrateset=yes rateset=${id}_m1_raw_bkg_lc.fits timebinsize=${tbin} \
#         maketimecolumn=yes makeratecolumn=yes timemin=${timemin} timemax=${timemax}
# epiclccorr srctslist=${id}_m1_raw_src_lc.fits eventlist=${id}_m1_clean_evt_bary.fits \
#           outset=${id}_m1_lccorr.fits bkgtslist=${id}_m1_raw_bkg_lc.fits \
#           withbkgset=yes applyabsolutecorrections=yes
# dsplot table=${id}_m1_lccorr.fits withx=yes x=TIME withy=yes y=RATE

# evselect table=${id}_m2_clean_evt_bary.fits energycolumn=PI \
#         expression="#XMMEA_EM&&(PATTERN<=12)&&((X,Y) IN ${m2_src})&&(PI in [200:10000])" \
#         withrateset=yes rateset=${id}_m2_raw_src_lc.fits timebinsize=${tbin} \
#         maketimecolumn=yes makeratecolumn=yes timemin=${timemin} timemax=${timemax}
# evselect table=${id}_m2_clean_evt_bary.fits energycolumn=PI \
#         expression="#XMMEA_EM&&(PATTERN<=12)&&((X,Y) IN ${m2_bkg})&&(PI in [200:10000])" \
#         withrateset=yes rateset=${id}_m2_raw_bkg_lc.fits timebinsize=${tbin} \
#         maketimecolumn=yes makeratecolumn=yes timemin=${timemin} timemax=${timemax}
# epiclccorr srctslist=${id}_m2_raw_src_lc.fits eventlist=${id}_m2_clean_evt_bary.fits \
#           outset=${id}_m2_lccorr.fits bkgtslist=${id}_m2_raw_bkg_lc.fits \
#           withbkgset=yes applyabsolutecorrections=yes
# dsplot table=${id}_m2_lccorr.fits withx=yes x=TIME withy=yes y=RATE
# python -c "
# import matplotlib.pyplot as plt
# from astropy.io import fits
# pn = fits.open('${id}_pn_lccorr.fits')[1].data
# plt.plot(pn['TIME']-${timemin}, pn['RATE'])
# m1 = fits.open('${id}_m1_lccorr.fits')[1].data
# plt.plot(m1['TIME']-${timemin}, m1['RATE'])
# m2 = fits.open('${id}_m2_lccorr.fits')[1].data
# plt.plot(m2['TIME']-${timemin}, m2['RATE'])
# plt.legend(['pn', 'm1', 'm2'])
# plt.title('${id}_ep_lccorr')
# plt.xlabel('Time-${timemin} (s)')
# plt.ylabel('Rate (cts/s)')
# plt.savefig('${id}_ep_lccorr.pdf', bbox_inches='tight', pad_inches=0.1, dpi=300)
# plt.show()
# "



################################################################
# Spectra
################################################################
# evselect table=${id}_pn_clean_evt_bary.fits withspectrumset=yes \
#          spectrumset=${id}_pn_spec_src.fits energycolumn=PI spectralbinsize=5 \
#          withspecranges=yes specchannelmin=0 specchannelmax=20479 \
#          expression="(FLAG==0)&&(PATTERN<=4)&&((X,Y) IN ${pn_src})&&TIME>${t0}&&TIME<${t1}"
# evselect table=${id}_pn_clean_evt_bary.fits withspectrumset=yes \
#          spectrumset=${id}_pn_spec_bkg.fits energycolumn=PI spectralbinsize=5 \
#          withspecranges=yes specchannelmin=0 specchannelmax=20479 \
#          expression="(FLAG==0)&&(PATTERN<=4)&&((X,Y) IN ${pn_bkg})&&TIME>${t0}&&TIME<${t1}"
# backscale spectrumset=${id}_pn_spec_src.fits badpixlocation=${id}_pn_clean_evt_bary.fits
# backscale spectrumset=${id}_pn_spec_bkg.fits badpixlocation=${id}_pn_clean_evt_bary.fits
# rmfgen spectrumset=${id}_pn_spec_src.fits rmfset=${id}_pn_spec_rmf.fits
# arfgen spectrumset=${id}_pn_spec_src.fits arfset=${id}_pn_spec_arf.fits withrmfset=yes \
#        rmfset=${id}_pn_spec_rmf.fits badpixlocation=${id}_pn_clean_evt_bary.fits \
#        detmaptype=psf
# specgroup spectrumset=${id}_pn_spec_src.fits mincounts=25 oversample=3 \
#           rmfset=${id}_pn_spec_rmf.fits arfset=${id}_pn_spec_arf.fits \
#           backgndset=${id}_pn_spec_bkg.fits groupedset=${id}_pn_spec_grp.fits

# evselect table=${id}_m1_clean_evt_bary.fits withspectrumset=yes \
#         spectrumset=${id}_m1_spec_src.fits energycolumn=PI spectralbinsize=5 \
#         withspecranges=yes specchannelmin=0 specchannelmax=11999 \
#         expression="#XMMEA_EM&&(PATTERN<=12)&&((X,Y) IN ${m1_src})&&TIME>${t0}&&TIME<${t1}"
# evselect table=${id}_m1_clean_evt_bary.fits withspectrumset=yes \
#         spectrumset=${id}_m1_spec_bkg.fits energycolumn=PI spectralbinsize=5 \
#         withspecranges=yes specchannelmin=0 specchannelmax=11999 \
#         expression="#XMMEA_EM&&(PATTERN<=12)&&((X,Y) IN ${m1_bkg})&&TIME>${t0}&&TIME<${t1}"
# backscale spectrumset=${id}_m1_spec_src.fits badpixlocation=${id}_m1_clean_evt_bary.fits
# backscale spectrumset=${id}_m1_spec_bkg.fits badpixlocation=${id}_m1_clean_evt_bary.fits
# rmfgen spectrumset=${id}_m1_spec_src.fits rmfset=${id}_m1_spec_rmf.fits
# arfgen spectrumset=${id}_m1_spec_src.fits arfset=${id}_m1_spec_arf.fits withrmfset=yes \
#       rmfset=${id}_m1_spec_rmf.fits badpixlocation=${id}_m1_clean_evt_bary.fits \
#       detmaptype=psf
# specgroup spectrumset=${id}_m1_spec_src.fits mincounts=25 oversample=3 \
#          rmfset=${id}_m1_spec_rmf.fits arfset=${id}_m1_spec_arf.fits \
#          backgndset=${id}_m1_spec_bkg.fits groupedset=${id}_m1_spec_grp.fits

# evselect table=${id}_m2_clean_evt_bary.fits withspectrumset=yes \
#          spectrumset=${id}_m2_spec_src.fits energycolumn=PI spectralbinsize=5 \
#          withspecranges=yes specchannelmin=0 specchannelmax=11999 \
#          expression="#XMMEA_EM&&(PATTERN<=12)&&((X,Y) IN ${m2_src})&&TIME>${t0}&&TIME<${t1}"
# evselect table=${id}_m2_clean_evt_bary.fits withspectrumset=yes \
#          spectrumset=${id}_m2_spec_bkg.fits energycolumn=PI spectralbinsize=5 \
#          withspecranges=yes specchannelmin=0 specchannelmax=11999 \
#          expression="#XMMEA_EM&&(PATTERN<=12)&&((X,Y) IN ${m2_bkg})&&TIME>${t0}&&TIME<${t1}"
# backscale spectrumset=${id}_m2_spec_src.fits badpixlocation=${id}_m2_clean_evt_bary.fits
# backscale spectrumset=${id}_m2_spec_bkg.fits badpixlocation=${id}_m2_clean_evt_bary.fits
# rmfgen spectrumset=${id}_m2_spec_src.fits rmfset=${id}_m2_spec_rmf.fits
# arfgen spectrumset=${id}_m2_spec_src.fits arfset=${id}_m2_spec_arf.fits withrmfset=yes \
#        rmfset=${id}_m2_spec_rmf.fits badpixlocation=${id}_m2_clean_evt_bary.fits \
#        detmaptype=psf
# specgroup spectrumset=${id}_m2_spec_src.fits mincounts=25 oversample=3 \
#           rmfset=${id}_m2_spec_rmf.fits arfset=${id}_m2_spec_arf.fits \
#           backgndset=${id}_m2_spec_bkg.fits groupedset=${id}_m2_spec_grp.fits

################################################################
# Combined spectrum
################################################################
# evselect table=${id}_pn_clean_evt_bary.fits withspectrumset=yes \
#          spectrumset=${id}_pn_spec_src_tmp.fits energycolumn=PI spectralbinsize=200 \
#          withspecranges=yes specchannelmin=0 specchannelmax=11999 \
#          expression="(FLAG==0)&&(PATTERN<=4)&&((X,Y) IN ${pn_src})&&TIME>${t0}&&TIME<${t1}"
# evselect table=${id}_pn_clean_evt_bary.fits withspectrumset=yes \
#          spectrumset=${id}_pn_spec_bkg_tmp.fits energycolumn=PI spectralbinsize=200 \
#          withspecranges=yes specchannelmin=0 specchannelmax=11999 \
#          expression="(FLAG==0)&&(PATTERN<=4)&&((X,Y) IN ${pn_bkg})&&TIME>${t0}&&TIME<${t1}"
# backscale spectrumset=${id}_pn_spec_src_tmp.fits badpixlocation=${id}_pn_clean_evt_bary.fits
# backscale spectrumset=${id}_pn_spec_bkg_tmp.fits badpixlocation=${id}_pn_clean_evt_bary.fits
# rmfgen spectrumset=${id}_pn_spec_src_tmp.fits rmfset=${id}_pn_spec_rmf_tmp.fits \
#        withenergybins=yes energymin=0.1 energymax=12.0 nenergybins=2400 \
#        acceptchanrange=yes
# arfgen spectrumset=${id}_pn_spec_src_tmp.fits arfset=${id}_pn_spec_arf_tmp.fits \
#        withrmfset=yes rmfset=${id}_pn_spec_rmf_tmp.fits

# evselect table=${id}_m1_clean_evt_bary.fits withspectrumset=yes \
#         spectrumset=${id}_m1_spec_src_tmp.fits energycolumn=PI spectralbinsize=200 \
#         withspecranges=yes specchannelmin=0 specchannelmax=11999 \
#         expression="#XMMEA_EM&&(PATTERN<=12)&&((X,Y) IN ${m1_src})&&TIME>${t0}&&TIME<${t1}"
# evselect table=${id}_m1_clean_evt_bary.fits withspectrumset=yes \
#         spectrumset=${id}_m1_spec_bkg_tmp.fits energycolumn=PI spectralbinsize=200 \
#         withspecranges=yes specchannelmin=0 specchannelmax=11999 \
#         expression="#XMMEA_EM&&(PATTERN<=12)&&((X,Y) IN ${m1_bkg})&&TIME>${t0}&&TIME<${t1}"
# backscale spectrumset=${id}_m1_spec_src_tmp.fits badpixlocation=${id}_m1_clean_evt_bary.fits
# backscale spectrumset=${id}_m1_spec_bkg_tmp.fits badpixlocation=${id}_m1_clean_evt_bary.fits
# rmfgen spectrumset=${id}_m1_spec_src_tmp.fits rmfset=${id}_m1_spec_rmf_tmp.fits \
#       withenergybins=yes energymin=0.1 energymax=12.0 nenergybins=2400
# arfgen spectrumset=${id}_m1_spec_src_tmp.fits arfset=${id}_m1_spec_arf_tmp.fits \
#       withrmfset=yes rmfset=${id}_m1_spec_rmf_tmp.fits 

# evselect table=${id}_m2_clean_evt_bary.fits withspectrumset=yes \
#         spectrumset=${id}_m2_spec_src_tmp.fits energycolumn=PI spectralbinsize=200 \
#         withspecranges=yes specchannelmin=0 specchannelmax=11999 \
#         expression="#XMMEA_EM&&(PATTERN<=12)&&((X,Y) IN ${m2_src})&&TIME>${t0}&&TIME<${t1}"
# evselect table=${id}_m2_clean_evt_bary.fits withspectrumset=yes \
#         spectrumset=${id}_m2_spec_bkg_tmp.fits energycolumn=PI spectralbinsize=200 \
#         withspecranges=yes specchannelmin=0 specchannelmax=11999 \
#         expression="#XMMEA_EM&&(PATTERN<=12)&&((X,Y) IN ${m2_bkg})&&TIME>${t0}&&TIME<${t1}"
# backscale spectrumset=${id}_m2_spec_src_tmp.fits badpixlocation=${id}_m2_clean_evt_bary.fits
# backscale spectrumset=${id}_m2_spec_bkg_tmp.fits badpixlocation=${id}_m2_clean_evt_bary.fits
# rmfgen spectrumset=${id}_m2_spec_src_tmp.fits rmfset=${id}_m2_spec_rmf_tmp.fits \
#       withenergybins=yes energymin=0.1 energymax=12.0 nenergybins=2400
# arfgen spectrumset=${id}_m2_spec_src_tmp.fits arfset=${id}_m2_spec_arf_tmp.fits \
#       withrmfset=yes rmfset=${id}_m2_spec_rmf_tmp.fits 

# All
# epicspeccombine pha="${id}_pn_spec_src_tmp.fits ${id}_m1_spec_src_tmp.fits ${id}_m2_spec_src_tmp.fits" \
#   bkg="${id}_pn_spec_bkg_tmp.fits ${id}_m1_spec_bkg_tmp.fits ${id}_m2_spec_bkg_tmp.fits" \
#   rmf="${id}_pn_spec_rmf_tmp.fits ${id}_m1_spec_rmf_tmp.fits ${id}_m2_spec_rmf_tmp.fits" \
#   arf="${id}_pn_spec_arf_tmp.fits ${id}_m1_spec_arf_tmp.fits ${id}_m2_spec_arf_tmp.fits" \
#   filepha="${id}_ep_spec_src.fits" \
#   filebkg="${id}_ep_spec_bkg.fits" \
#   filersp="${id}_ep_spec_rsp.fits"

# PN+M2
# epicspeccombine pha="${id}_pn_spec_src_tmp.fits ${id}_m2_spec_src_tmp.fits" \
#   bkg="${id}_pn_spec_bkg_tmp.fits ${id}_m2_spec_bkg_tmp.fits" \
#   rmf="${id}_pn_spec_rmf_tmp.fits ${id}_m2_spec_rmf_tmp.fits" \
#   arf="${id}_pn_spec_arf_tmp.fits ${id}_m2_spec_arf_tmp.fits" \
#   filepha="${id}_ep_spec_src.fits" \
#   filebkg="${id}_ep_spec_bkg.fits" \
#   filersp="${id}_ep_spec_rsp.fits"

# fthedit "${id}_ep_spec_src.fits" BACKFILE add "${id}_ep_spec_bkg.fits"
# fthedit "${id}_ep_spec_src.fits" RESPFILE add "${id}_ep_spec_rsp.fits"
# fthedit "${id}_ep_spec_src.fits" ANCRFILE add "none    "
