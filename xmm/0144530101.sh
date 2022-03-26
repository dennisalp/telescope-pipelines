#!/bin/bash -x

################################################################
# Parameters
################################################################
     
coo="5:35:27.9884 -69:16:11.1132"
id="0144530101"
cams=(pn m1 m2)
rate_pn=0.16
rate_m1=0.2
rate_m2=0.14

pn_src="circle(25384.104,27858.729,400)"
m1_src="circle(25384.104,27858.729,500)"
m2_src="circle(25384.104,27858.729,500)"
pn_bkg="circle(26486.698,28978.599,1102.8433)"
m1_bkg="annulus(25384.104,27858.729,600,2400)"
m2_bkg="circle(23650.721,25120.065,2486)"

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
# Some preparation
################################################################
wrk="/Users/silver/dat/xmm/87a/${id}_rka"
dat="/Users/silver/dat/xmm/87a/${id}"

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

. ${SAS_DIR}/setsas.sh



################################################################
# Make raw event lists
################################################################
# cifbuild
# odfingest
export SAS_ODF=$(ls -1 *SUM.SAS)
# epproc
# emproc


################################################################
# Make background flare light curves
################################################################
# evselect table=$(ls *EPN*ImagingEvts.ds) withrateset=Y rateset=${id}_pn_bkg_flare.fits \
#          maketimecolumn=Y timebinsize=100 makeratecolumn=Y \
#          expression="#XMMEA_EP && (PI>10000&&PI<12000) && (PATTERN==0)"
# dsplot table=${id}_pn_bkg_flare.fits x=TIME y=RATE

# evselect table=0626_0144530101_EMOS1_U002_ImagingEvts.ds \
#          withrateset=Y rateset=${id}_m1_bkg_flare.fits \
#          maketimecolumn=Y timebinsize=100 makeratecolumn=Y \
#          expression="#XMMEA_EM && (PI>10000) && (PATTERN==0)"
# dsplot table=${id}_m1_bkg_flare.fits x=TIME y=RATE

# evselect table=0626_0144530101_EMOS2_U002_ImagingEvts.ds \
#          withrateset=Y rateset=${id}_m2_bkg_flare.fits \
#          maketimecolumn=Y timebinsize=100 makeratecolumn=Y \
#          expression="#XMMEA_EM && (PI>10000) && (PATTERN==0)"
# dsplot table=${id}_m2_bkg_flare.fits x=TIME y=RATE


################################################################
# Make filtered event lists and images
# Need to set background flare conditions
################################################################
# tabgtigen table=${id}_pn_bkg_flare.fits expression="RATE<=${rate_pn}" gtiset=${id}_pn_gti.fits
# tabgtigen table=${id}_m1_bkg_flare.fits expression="RATE<=${rate_m1}" gtiset=${id}_m1_gti.fits
# tabgtigen table=${id}_m2_bkg_flare.fits expression="RATE<=${rate_m2}" gtiset=${id}_m2_gti.fits

# evselect table=$(ls *EPN*ImagingEvts.ds) withfilteredset=Y \
#         filteredset=${id}_pn_clean_evt.fits \
#         destruct=Y keepfilteroutput=T \
#         expression="#XMMEA_EP && gti(${id}_pn_gti.fits,TIME) && (PI in [300:10000]) && (PATTERN<=4)"
# evselect table=0626_0144530101_EMOS1_U002_ImagingEvts.ds withfilteredset=Y \
#         filteredset=${id}_m1_clean_evt.fits \
#         destruct=Y keepfilteroutput=T \
#         expression="#XMMEA_EM && gti(${id}_m1_gti.fits,TIME) && (PI in [300:10000]) && (PATTERN<=12)"
# evselect table=0626_0144530101_EMOS2_U002_ImagingEvts.ds withfilteredset=Y \
#         filteredset=${id}_m2_clean_evt.fits \
#         destruct=Y keepfilteroutput=T \
#         expression="#XMMEA_EM && gti(${id}_m2_gti.fits,TIME) && (PI in [300:10000]) && (PATTERN<=12)"

# for cam in "${cams[@]}"; do
#     evselect table=${id}_${cam}_clean_evt.fits imagebinning=binSize \
#              imageset=${id}_${cam}_clean_img.fits withimageset=yes \
#              xcolumn=X ycolumn=Y ximagebinsize=80 yimagebinsize=80
# done

################################################################
# Make spectra
# Need to set spatial source and background regions
################################################################
print_src "${id}_pn_src.reg" ${pn_src}
print_bkg "${id}_pn_bkg.reg" ${pn_bkg}
print_src "${id}_m1_src.reg" ${m1_src}
print_bkg "${id}_m1_bkg.reg" ${m1_bkg}
print_src "${id}_m2_src.reg" ${m2_src}
print_bkg "${id}_m2_bkg.reg" ${m2_bkg}


${ds9} ${id}_pn_clean_img.fits -scale linear -cmap Heat -regions ${id}_pn_src.reg -pan to ${coo} wcs -zoom 6 -regions ${id}_pn_bkg.reg -print destination file -print filename ${id}_pn_clean_img.ps -print -exit
${ds9} ${id}_m1_clean_img.fits -scale linear -cmap Heat -regions ${id}_m1_src.reg -pan to ${coo} wcs -zoom 6 -regions ${id}_m1_bkg.reg -print destination file -print filename ${id}_m1_clean_img.ps -print -exit
${ds9} ${id}_m2_clean_img.fits -scale linear -cmap Heat -regions ${id}_m2_src.reg -pan to ${coo} wcs -zoom 6 -regions ${id}_m2_bkg.reg -print destination file -print filename ${id}_m2_clean_img.ps -print -exit
for ff in *.ps
do
    ps2pdf ${ff}
done
rm *.ps


evselect table=${id}_pn_clean_evt.fits withspectrumset=yes \
         spectrumset=${id}_pn_spec_src.fits energycolumn=PI spectralbinsize=5 \
         withspecranges=yes specchannelmin=0 specchannelmax=20479 \
         expression="(FLAG==0)&&((X,Y) IN ${pn_src})"
evselect table=${id}_pn_clean_evt.fits withspectrumset=yes \
         spectrumset=${id}_pn_spec_bkg.fits energycolumn=PI spectralbinsize=5 \
         withspecranges=yes specchannelmin=0 specchannelmax=20479 \
         expression="(FLAG==0)&&((X,Y) IN ${pn_bkg})"
backscale spectrumset=${id}_pn_spec_src.fits badpixlocation=${id}_pn_clean_evt.fits
backscale spectrumset=${id}_pn_spec_bkg.fits badpixlocation=${id}_pn_clean_evt.fits
rmfgen spectrumset=${id}_pn_spec_src.fits rmfset=${id}_pn_spec_rmf.fits
arfgen spectrumset=${id}_pn_spec_src.fits arfset=${id}_pn_spec_arf.fits withrmfset=yes \
       rmfset=${id}_pn_spec_rmf.fits badpixlocation=${id}_pn_clean_evt.fits \
       detmaptype=psf psfenergy=5
specgroup spectrumset=${id}_pn_spec_src.fits \
          mincounts=1 \
          rmfset=${id}_pn_spec_rmf.fits \
          arfset=${id}_pn_spec_arf.fits \
          backgndset=${id}_pn_spec_bkg.fits \
          groupedset=${id}_pn_spec_grp.fits
fthedit "${id}_pn_spec_src.fits" BACKFILE add "${id}_pn_spec_bkg.fits"
fthedit "${id}_pn_spec_src.fits" RESPFILE add "${id}_pn_spec_rmf.fits"
fthedit "${id}_pn_spec_src.fits" ANCRFILE add "${id}_pn_spec_arf.fits"

evselect table=${id}_pn_clean_evt.fits withspectrumset=yes \
         spectrumset=${id}_p2_spec_src.fits energycolumn=PI spectralbinsize=5 \
         withspecranges=yes specchannelmin=0 specchannelmax=11999 \
         expression="(FLAG==0)&&((X,Y) IN ${pn_src})"
evselect table=${id}_pn_clean_evt.fits withspectrumset=yes \
         spectrumset=${id}_p2_spec_bkg.fits energycolumn=PI spectralbinsize=5 \
         withspecranges=yes specchannelmin=0 specchannelmax=11999 \
         expression="(FLAG==0)&&((X,Y) IN ${pn_bkg})"
backscale spectrumset=${id}_p2_spec_src.fits badpixlocation=${id}_pn_clean_evt.fits
backscale spectrumset=${id}_p2_spec_bkg.fits badpixlocation=${id}_pn_clean_evt.fits
rmfgen spectrumset=${id}_p2_spec_src.fits rmfset=${id}_p2_spec_rmf.fits \
       withenergybins=yes energymin=0.1 energymax=12.0 nenergybins=2400 \
       acceptchanrange=yes # necessary override
arfgen spectrumset=${id}_p2_spec_src.fits arfset=${id}_p2_spec_arf.fits withrmfset=yes \
       rmfset=${id}_p2_spec_rmf.fits badpixlocation=${id}_pn_clean_evt.fits \
       detmaptype=psf psfenergy=5
specgroup spectrumset=${id}_p2_spec_src.fits \
          mincounts=1 \
          rmfset=${id}_p2_spec_rmf.fits \
          arfset=${id}_p2_spec_arf.fits \
          backgndset=${id}_p2_spec_bkg.fits \
          groupedset=${id}_p2_spec_grp.fits
fthedit "${id}_p2_spec_src.fits" BACKFILE add "${id}_p2_spec_bkg.fits"
fthedit "${id}_p2_spec_src.fits" RESPFILE add "${id}_p2_spec_rmf.fits"
fthedit "${id}_p2_spec_src.fits" ANCRFILE add "${id}_p2_spec_arf.fits"


evselect table=${id}_m1_clean_evt.fits withspectrumset=yes \
         spectrumset=${id}_m1_spec_src.fits energycolumn=PI spectralbinsize=5 \
         withspecranges=yes specchannelmin=0 specchannelmax=11999 \
         expression="(X,Y) IN ${m1_src}"
evselect table=${id}_m1_clean_evt.fits withspectrumset=yes \
         spectrumset=${id}_m1_spec_bkg.fits energycolumn=PI spectralbinsize=5 \
         withspecranges=yes specchannelmin=0 specchannelmax=11999 \
         expression="(X,Y) IN ${m1_bkg}"
backscale spectrumset=${id}_m1_spec_src.fits badpixlocation=${id}_m1_clean_evt.fits
backscale spectrumset=${id}_m1_spec_bkg.fits badpixlocation=${id}_m1_clean_evt.fits

rmfgen spectrumset=${id}_m1_spec_src.fits rmfset=${id}_m1_spec_rmf.fits \
       withenergybins=yes energymin=0.1 energymax=12.0 nenergybins=2400
arfgen spectrumset=${id}_m1_spec_src.fits arfset=${id}_m1_spec_arf.fits withrmfset=yes \
       rmfset=${id}_m1_spec_rmf.fits badpixlocation=${id}_m1_clean_evt.fits \
       detmaptype=psf psfenergy=5
specgroup spectrumset=${id}_m1_spec_src.fits \
          mincounts=1 \
          rmfset=${id}_m1_spec_rmf.fits \
          arfset=${id}_m1_spec_arf.fits \
          backgndset=${id}_m1_spec_bkg.fits \
          groupedset=${id}_m1_spec_grp.fits
fthedit "${id}_m1_spec_src.fits" BACKFILE add "${id}_m1_spec_bkg.fits"
fthedit "${id}_m1_spec_src.fits" RESPFILE add "${id}_m1_spec_rmf.fits"
fthedit "${id}_m1_spec_src.fits" ANCRFILE add "${id}_m1_spec_arf.fits"


evselect table=${id}_m2_clean_evt.fits withspectrumset=yes \
         spectrumset=${id}_m2_spec_src.fits energycolumn=PI spectralbinsize=5 \
         withspecranges=yes specchannelmin=0 specchannelmax=11999 \
         expression="(X,Y) IN ${m2_src}"
evselect table=${id}_m2_clean_evt.fits withspectrumset=yes \
         spectrumset=${id}_m2_spec_bkg.fits energycolumn=PI spectralbinsize=5 \
         withspecranges=yes specchannelmin=0 specchannelmax=11999 \
         expression="(X,Y) IN ${m2_bkg}"
backscale spectrumset=${id}_m2_spec_src.fits badpixlocation=${id}_m2_clean_evt.fits
backscale spectrumset=${id}_m2_spec_bkg.fits badpixlocation=${id}_m2_clean_evt.fits

rmfgen spectrumset=${id}_m2_spec_src.fits rmfset=${id}_m2_spec_rmf.fits \
       withenergybins=yes energymin=0.1 energymax=12.0 nenergybins=2400
arfgen spectrumset=${id}_m2_spec_src.fits arfset=${id}_m2_spec_arf.fits withrmfset=yes \
       rmfset=${id}_m2_spec_rmf.fits badpixlocation=${id}_m2_clean_evt.fits \
       detmaptype=psf psfenergy=5
specgroup spectrumset=${id}_m2_spec_src.fits \
          mincounts=1 \
          rmfset=${id}_m2_spec_rmf.fits \
          arfset=${id}_m2_spec_arf.fits \
          backgndset=${id}_m2_spec_bkg.fits \
          groupedset=${id}_m2_spec_grp.fits
fthedit "${id}_m2_spec_src.fits" BACKFILE add "${id}_m2_spec_bkg.fits"
fthedit "${id}_m2_spec_src.fits" RESPFILE add "${id}_m2_spec_rmf.fits"
fthedit "${id}_m2_spec_src.fits" ANCRFILE add "${id}_m2_spec_arf.fits"

epicspeccombine pha="${id}_p2_spec_src.fits ${id}_m1_spec_src.fits ${id}_m2_spec_src.fits" \
  bkg="${id}_p2_spec_bkg.fits ${id}_m1_spec_bkg.fits ${id}_m2_spec_bkg.fits" \
  rmf="${id}_p2_spec_rmf.fits ${id}_m1_spec_rmf.fits ${id}_m2_spec_rmf.fits" \
  arf="${id}_p2_spec_arf.fits ${id}_m1_spec_arf.fits ${id}_m2_spec_arf.fits" \
  filepha="${id}_ep_spec_src.fits" \
  filebkg="${id}_ep_spec_bkg.fits" \
  filersp="${id}_ep_spec_rsp.fits"
specgroup spectrumset=${id}_ep_spec_src.fits \
          mincounts=1 \
          rmfset=${id}_ep_spec_rsp.fits \
          backgndset=${id}_ep_spec_bkg.fits \
          groupedset=${id}_ep_spec_grp.fits

fthedit "${id}_ep_spec_src.fits" BACKFILE add "${id}_ep_spec_bkg.fits"
fthedit "${id}_ep_spec_src.fits" RESPFILE add "${id}_ep_spec_rsp.fits"
fthedit "${id}_ep_spec_src.fits" ANCRFILE add "none    "
