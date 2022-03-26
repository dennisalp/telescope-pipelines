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

# Add coordinate system and equinox (DS9 requires this)
fmt_wcs () {
    fthedit ${1} EQUINOX add 2000
    fthedit ${1} RADESYS add FK5
    # This convert engineering to decimal format (wasn't the problem)
    # fthedit ${1} CRVAL1 add $(fkeyprint ${1} CRVAL1 | tr " " "\n" | tail -1 | xargs printf "%.7f")
    # fthedit ${1} CRPIX1 add $(fkeyprint ${1} CRPIX1 | tr " " "\n" | tail -1 | xargs printf "%3.f")
    # fthedit ${1} CRVAL2 add $(fkeyprint ${1} CRVAL2 | tr " " "\n" | tail -1 | xargs printf "%.7f")
    # fthedit ${1} CRPIX2 add $(fkeyprint ${1} CRPIX2 | tr " " "\n" | tail -1 | xargs printf "%3.f")
}



################################################################
# Parameters
################################################################
id="0770380201"
t_INF=9999999999
pn_exp=1
m1_exp=1
m2_exp=1
rate_pn=0.5
rate_m1=0.15
rate_m2=0.2

timemin=549525000
timemax=549554000
tbin=200
pn_src_prel="circle(18586.896,38598.279,400)"
m2_src_prel="circle(18586.896,38598.279,400)"
pn_bkg="circle(16194.826,37778.446,1765.3009)"
m2_bkg="annulus(18586.896,38598.279,800,2400)"

# emllist_idx=1
# DET_ML=154.8458, (173.530957148171, 0.873571383485428)
# uncertainty (1.008628**2+1.2**2)**0.5/3600.=0.0004354409609015489=1.567587459245576 arcsec
coo="11:34:07.4297 +0:52:24.857"
coo_fit="circle(18586.896,38598.279,400)"

# optradius: 32 arcsecs 640 image units
# optradius: 28 arcsecs 560 image units
pn_src="circle(18586.896,38598.279,400)"
m2_src="circle(18586.896,38598.279,400)"



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

. ${SAS_DIR}/setsas.sh



################################################################
# Make raw event lists
################################################################
# cifbuild
# odfingest
# export SAS_ODF=$(ls -1 *SUM.SAS)
# epproc
# emproc



################################################################
# Make background flare light curves
################################################################
# evselect table=$(ls *EPN*ImagingEvts.ds | head -${pn_exp} | tail -1) withrateset=Y rateset=${id}_pn_bkg_flare.fits \
#         maketimecolumn=Y timebinsize=100 makeratecolumn=Y \
#         expression="#XMMEA_EP && (PI>10000&&PI<12000) && (PATTERN==0)"
# evselect table=$(ls *EMOS1*ImagingEvts.ds | head -${m1_exp} | tail -1) withrateset=Y rateset=${id}_m1_bkg_flare.fits \
#         maketimecolumn=Y timebinsize=100 makeratecolumn=Y \
#         expression="#XMMEA_EM && (PI>10000) && (PATTERN==0)"
# evselect table=$(ls *EMOS2*ImagingEvts.ds | head -${m2_exp} | tail -1) withrateset=Y rateset=${id}_m2_bkg_flare.fits \
#         maketimecolumn=Y timebinsize=100 makeratecolumn=Y \
#         expression="#XMMEA_EM && (PI>10000) && (PATTERN==0)"
# dsplot table=${id}_pn_bkg_flare.fits x=TIME y=RATE
# dsplot table=${id}_m1_bkg_flare.fits x=TIME y=RATE
# dsplot table=${id}_m2_bkg_flare.fits x=TIME y=RATE



################################################################
# Make filtered event lists and images
# Need to set background flare conditions
################################################################
# tabgtigen table=${id}_pn_bkg_flare.fits expression="RATE<=${rate_pn}" gtiset=${id}_pn_gti.fits
# tabgtigen table=${id}_m1_bkg_flare.fits expression="RATE<=${rate_m1}" gtiset=${id}_m1_gti.fits
# tabgtigen table=${id}_m2_bkg_flare.fits expression="RATE<=${rate_m2}" gtiset=${id}_m2_gti.fits
# evselect table=$(ls *EPN*ImagingEvts.ds | head -${pn_exp} | tail -1) withfilteredset=Y \
#         filteredset=${id}_pn_clean_evt.fits \
#         destruct=Y keepfilteroutput=T \
#         expression="#XMMEA_EP && gti(${id}_pn_gti.fits,TIME) && (PI in [300:10000]) && (PATTERN<=4)"
# evselect table=$(ls *EMOS1*ImagingEvts.ds | head -${m1_exp} | tail -1) withfilteredset=Y \
#         filteredset=${id}_m1_clean_evt.fits \
#         destruct=Y keepfilteroutput=T \
#         expression="#XMMEA_EM && gti(${id}_m1_gti.fits,TIME) && (PI in [300:10000]) && (PATTERN<=12)"
# evselect table=$(ls *EMOS2*ImagingEvts.ds | head -${m2_exp} | tail -1) withfilteredset=Y \
#         filteredset=${id}_m2_clean_evt.fits \
#         destruct=Y keepfilteroutput=T \
#         expression="#XMMEA_EM && gti(${id}_m2_gti.fits,TIME) && (PI in [300:10000]) && (PATTERN<=12)"

# evselect table=${id}_pn_clean_evt.fits imagebinning=binSize \
#         imageset=${id}_pn_clean_img.fits withimageset=yes \
#         xcolumn=X ycolumn=Y ximagebinsize=80 yimagebinsize=80
# evselect table=${id}_m1_clean_evt.fits imagebinning=binSize \
#         imageset=${id}_m1_clean_img.fits withimageset=yes \
#         xcolumn=X ycolumn=Y ximagebinsize=80 yimagebinsize=80
# evselect table=${id}_m2_clean_evt.fits imagebinning=binSize \
#         imageset=${id}_m2_clean_img.fits withimageset=yes \
#         xcolumn=X ycolumn=Y ximagebinsize=80 yimagebinsize=80

# emosaic imagesets="${id}_pn_clean_img.fits ${id}_m1_clean_img.fits ${id}_m2_clean_img.fits" \
#         mosaicedset=${id}_ep_clean_img.fits
# fmt_wcs ${id}_ep_clean_img.fits



################################################################
# Make preliminary light curves
# Need to set timemin, timemax, and tbin
# Need to set preliminary spatial source and background regions
################################################################
# print_src "${id}_pn_src_prel.reg" ${pn_src_prel}
# print_src "${id}_m2_src_prel.reg" ${m2_src_prel}
# print_bkg "${id}_pn_bkg.reg" ${pn_bkg}
# print_bkg "${id}_m2_bkg.reg" ${m2_bkg}

# evselect table=${id}_pn_clean_evt.fits energycolumn=PI \
#         expression="(X,Y) IN ${pn_src_prel}" \
#         withrateset=yes rateset=${id}_pn_raw_src_prel_lc.fits timebinsize=${tbin} \
#         maketimecolumn=yes makeratecolumn=yes timemin=${timemin} timemax=${timemax}
# evselect table=${id}_pn_clean_evt.fits energycolumn=PI \
#         expression="(X,Y) IN ${pn_bkg}" \
#         withrateset=yes rateset=${id}_pn_raw_bkg_lc.fits timebinsize=${tbin} \
#         maketimecolumn=yes makeratecolumn=yes timemin=${timemin} timemax=${timemax}
# epiclccorr srctslist=${id}_pn_raw_src_prel_lc.fits eventlist=${id}_pn_clean_evt.fits \
#           outset=${id}_pn_lccorr_prel.fits bkgtslist=${id}_pn_raw_bkg_lc.fits \
#           withbkgset=yes applyabsolutecorrections=yes

# evselect table=${id}_m2_clean_evt.fits energycolumn=PI \
#         expression="(X,Y) IN ${m2_src_prel}" \
#         withrateset=yes rateset=${id}_m2_raw_src_prel_lc.fits timebinsize=${tbin} \
#         maketimecolumn=yes makeratecolumn=yes timemin=${timemin} timemax=${timemax}
# evselect table=${id}_m2_clean_evt.fits energycolumn=PI \
#         expression="(X,Y) IN ${m2_bkg}" \
#         withrateset=yes rateset=${id}_m2_raw_bkg_lc.fits timebinsize=${tbin} \
#         maketimecolumn=yes makeratecolumn=yes timemin=${timemin} timemax=${timemax}
# epiclccorr srctslist=${id}_m2_raw_src_prel_lc.fits eventlist=${id}_m2_clean_evt.fits \
#           outset=${id}_m2_lccorr_prel.fits bkgtslist=${id}_m2_raw_bkg_lc.fits \
#           withbkgset=yes applyabsolutecorrections=yes

# python -c "
# import matplotlib.pyplot as plt
# from astropy.io import fits
# pn = fits.open('${id}_pn_lccorr_prel.fits')[1].data
# plt.plot(pn['TIME'], pn['RATE'])
# m2 = fits.open('${id}_m2_lccorr_prel.fits')[1].data
# plt.plot(m2['TIME'], m2['RATE'])
# plt.plot(pn['TIME'], pn['RATE']+m2['RATE'])
# plt.legend(['pn', 'm2', 'tot'])
# plt.title('${id}_ep_lccorr')
# plt.xlabel('Time (s)')
# plt.ylabel('Rate (cts/s)')
# plt.show()
# "





################################################################
################################################################
################################################################
# Make event lists, images, source lists, sensitivity maps, and
# spectra for all time intervals and cameras (and combined; ep)
# Need to set everything
################################################################
################################################################
################################################################

mk_evt () {
    evselect table=${id}_pn_clean_evt.fits withfilteredset=Y \
             filteredset=${id}_pn_clean_evt_${1}.fits \
             destruct=Y keepfilteroutput=T \
             expression="(TIME>${2}) && (TIME<${3})"

    evselect table=${id}_m2_clean_evt.fits withfilteredset=Y \
             filteredset=${id}_m2_clean_evt_${1}.fits \
             destruct=Y keepfilteroutput=T \
             expression="(TIME>${2}) && (TIME<${3})"

    merge set1=${id}_pn_clean_evt_${1}.fits \
          set2=${id}_m2_clean_evt_${1}.fits \
          outset=${id}_ep_clean_evt_${1}.fits
    rm ${id}_tmp_clean_evt_${1}.fits

    evselect table=${id}_ep_clean_evt_${1}.fits withfilteredset=Y \
             filteredset=${id}_ep_clean_evt_src_${1}.fits \
             destruct=Y keepfilteroutput=T \
             expression="(X,Y) in ${pn_src}"
}

mk_img () {
    # evselect table=${id}_pn_clean_evt_${1}.fits imagebinning=binSize \
    #          imageset=${id}_pn_clean_img_${1}_flag0.fits withimageset=yes \
    #          xcolumn=X ycolumn=Y ximagebinsize=80 yimagebinsize=80 \
    #          expression="(FLAG==0)"
    
    evselect table=${id}_pn_clean_evt_${1}.fits imagebinning=binSize \
             imageset=${id}_pn_clean_img_${1}.fits withimageset=yes \
             xcolumn=X ycolumn=Y ximagebinsize=80 yimagebinsize=80

    evselect table=${id}_m2_clean_evt_${1}.fits imagebinning=binSize \
             imageset=${id}_m2_clean_img_${1}.fits withimageset=yes \
             xcolumn=X ycolumn=Y ximagebinsize=80 yimagebinsize=80

    emosaic imagesets="${id}_pn_clean_img_${1}.fits ${id}_m2_clean_img_${1}.fits" \
            mosaicedset=${id}_ep_clean_img_${1}.fits
    fmt_wcs ${id}_ep_clean_img_${1}.fits
}

print_img() {
    ${ds9} ${id}_pn_clean_img_${1}.fits -scale linear -cmap Heat -regions ${id}_pn_src.reg -pan to ${coo} wcs -zoom 2 -regions ${id}_pn_bkg.reg -print destination file -print filename ${id}_pn_clean_img_${1}.ps -print -exit
    ${ds9} ${id}_m2_clean_img_${1}.fits -scale linear -cmap Heat -regions ${id}_m2_src.reg -pan to ${coo} wcs -zoom 2 -regions ${id}_m2_bkg.reg -print destination file -print filename ${id}_m2_clean_img_${1}.ps -print -exit
    ${ds9} ${id}_ep_clean_img_${1}.fits -scale linear -cmap Heat -pan to ${coo} wcs -zoom 2 -print destination file -print filename ${id}_ep_clean_img_${1}.ps -print -exit
    
    for ff in *.ps
    do
       ps2pdf ${ff}
    done
    rm *.ps
}

mk_src_list () {
    # edetect_chain imagesets="${id}_pn_clean_img_${1}.fits ${id}_m2_clean_img_${1}.fits" \
    #               eventsets="${id}_pn_clean_evt_${1}.fits ${id}_m2_clean_evt_${1}.fits" \
    #               attitudeset=$(ls *AttHk.ds) \
    #               pimin="300 300" \
    #               pimax="10000 10000" \
    #               eboxl_list=${id}_eboxlist_l_${1}.fits eboxm_list=${id}_eboxlist_m_${1}.fits \
    #               eml_list=${id}_emllist_${1}.fits eml_threshold=10

    # esensmap detmasksets="${id}_pn_clean_img_${1}mask.fits ${id}_m2_clean_img_${1}mask.fits" \
    #          expimagesets="${id}_pn_clean_img_${1}exp.fits ${id}_m2_clean_img_${1}exp.fits" \
    #          bkgimagesets="${id}_pn_clean_img_${1}bkg.fits ${id}_m2_clean_img_${1}bkg.fits" \
    #          sensimageset=${id}_ep_clean_img_${1}sen.fits \
    #          mlmin=5.91457904095048

    srcdisplay boxlistset=${id}_emllist_${1}.fits imageset=${id}_ep_clean_img_${1}.fits \
               useposerr=yes syserr=1.2 withregionfile=yes \
               regionfile=${id}_emllist_${1}.reg srccolor=green
    
    srcdisplay boxlistset=${id}_emllist_${1}.fits imageset=${id}_ep_clean_img_${1}.fits \
               withregionfile=yes regionfile=${id}_emllist_display_${1}.reg
}

mk_spec () {
    evselect table=${id}_pn_clean_evt_${1}.fits withspectrumset=yes \
             spectrumset=${id}_pn_spec_src_${1}.fits energycolumn=PI spectralbinsize=5 \
             withspecranges=yes specchannelmin=0 specchannelmax=20479 \
             expression="(FLAG==0)&&((X,Y) IN ${pn_src})"
    evselect table=${id}_pn_clean_evt_${1}.fits withspectrumset=yes \
             spectrumset=${id}_pn_spec_bkg_${1}.fits energycolumn=PI spectralbinsize=5 \
             withspecranges=yes specchannelmin=0 specchannelmax=20479 \
             expression="(FLAG==0)&&((X,Y) IN ${pn_bkg})"
    backscale spectrumset=${id}_pn_spec_src_${1}.fits badpixlocation=${id}_pn_clean_evt_${1}.fits
    backscale spectrumset=${id}_pn_spec_bkg_${1}.fits badpixlocation=${id}_pn_clean_evt_${1}.fits
    rmfgen spectrumset=${id}_pn_spec_src_${1}.fits rmfset=${id}_pn_spec_rmf_${1}.fits
    arfgen spectrumset=${id}_pn_spec_src_${1}.fits arfset=${id}_pn_spec_arf_${1}.fits withrmfset=yes \
           rmfset=${id}_pn_spec_rmf_${1}.fits badpixlocation=${id}_pn_clean_evt_${1}.fits \
           detmaptype=psf
    specgroup spectrumset=${id}_pn_spec_src_${1}.fits mincounts=1 \
              rmfset=${id}_pn_spec_rmf_${1}.fits arfset=${id}_pn_spec_arf_${1}.fits \
              backgndset=${id}_pn_spec_bkg_${1}.fits groupedset=${id}_pn_spec_grp_${1}.fits
    fthedit "${id}_pn_spec_src_${1}.fits" BACKFILE add "${id}_pn_spec_bkg_${1}.fits"
    fthedit "${id}_pn_spec_src_${1}.fits" RESPFILE add "${id}_pn_spec_rmf_${1}.fits"
    fthedit "${id}_pn_spec_src_${1}.fits" ANCRFILE add "${id}_pn_spec_arf_${1}.fits"
    
    evselect table=${id}_m2_clean_evt_${1}.fits withspectrumset=yes \
             spectrumset=${id}_m2_spec_src_${1}.fits energycolumn=PI spectralbinsize=5 \
             withspecranges=yes specchannelmin=0 specchannelmax=11999 \
             expression="(X,Y) IN ${m2_src}"
    evselect table=${id}_m2_clean_evt_${1}.fits withspectrumset=yes \
             spectrumset=${id}_m2_spec_bkg_${1}.fits energycolumn=PI spectralbinsize=5 \
             withspecranges=yes specchannelmin=0 specchannelmax=11999 \
             expression="(X,Y) IN ${m2_bkg}"
    backscale spectrumset=${id}_m2_spec_src_${1}.fits badpixlocation=${id}_m2_clean_evt_${1}.fits
    backscale spectrumset=${id}_m2_spec_bkg_${1}.fits badpixlocation=${id}_m2_clean_evt_${1}.fits
    rmfgen spectrumset=${id}_m2_spec_src_${1}.fits rmfset=${id}_m2_spec_rmf_${1}.fits
    arfgen spectrumset=${id}_m2_spec_src_${1}.fits arfset=${id}_m2_spec_arf_${1}.fits withrmfset=yes \
           rmfset=${id}_m2_spec_rmf_${1}.fits badpixlocation=${id}_m2_clean_evt_${1}.fits \
           detmaptype=psf
    specgroup spectrumset=${id}_m2_spec_src_${1}.fits mincounts=1 \
              rmfset=${id}_m2_spec_rmf_${1}.fits arfset=${id}_m2_spec_arf_${1}.fits \
              backgndset=${id}_m2_spec_bkg_${1}.fits groupedset=${id}_m2_spec_grp_${1}.fits
    fthedit "${id}_m2_spec_src_${1}.fits" BACKFILE add "${id}_m2_spec_bkg_${1}.fits"
    fthedit "${id}_m2_spec_src_${1}.fits" RESPFILE add "${id}_m2_spec_rmf_${1}.fits"
    fthedit "${id}_m2_spec_src_${1}.fits" ANCRFILE add "${id}_m2_spec_arf_${1}.fits"
}

mk_spec_ep () {    
    evselect table=${id}_pn_clean_evt_${1}.fits withspectrumset=yes \
             spectrumset=${id}_pn_spec_src_tmp_${1}.fits energycolumn=PI spectralbinsize=200 \
             withspecranges=yes specchannelmin=0 specchannelmax=11999 \
             expression="(FLAG==0)&&((X,Y) IN ${pn_src})"
    evselect table=${id}_pn_clean_evt_${1}.fits withspectrumset=yes \
             spectrumset=${id}_pn_spec_bkg_tmp_${1}.fits energycolumn=PI spectralbinsize=200 \
             withspecranges=yes specchannelmin=0 specchannelmax=11999 \
             expression="(FLAG==0)&&((X,Y) IN ${pn_bkg})"
    backscale spectrumset=${id}_pn_spec_src_tmp_${1}.fits badpixlocation=${id}_pn_clean_evt_${1}.fits
    backscale spectrumset=${id}_pn_spec_bkg_tmp_${1}.fits badpixlocation=${id}_pn_clean_evt_${1}.fits
    rmfgen spectrumset=${id}_pn_spec_src_tmp_${1}.fits rmfset=${id}_pn_spec_rmf_tmp_${1}.fits \
           withenergybins=yes energymin=0.1 energymax=12.0 nenergybins=2400 \
           acceptchanrange=yes
    arfgen spectrumset=${id}_pn_spec_src_tmp_${1}.fits arfset=${id}_pn_spec_arf_tmp_${1}.fits \
           withrmfset=yes rmfset=${id}_pn_spec_rmf_tmp_${1}.fits
    
    evselect table=${id}_m2_clean_evt_${1}.fits withspectrumset=yes \
            spectrumset=${id}_m2_spec_src_tmp_${1}.fits energycolumn=PI spectralbinsize=200 \
            withspecranges=yes specchannelmin=0 specchannelmax=11999 \
            expression="(X,Y) IN ${m2_src}"
    evselect table=${id}_m2_clean_evt_${1}.fits withspectrumset=yes \
            spectrumset=${id}_m2_spec_bkg_tmp_${1}.fits energycolumn=PI spectralbinsize=200 \
            withspecranges=yes specchannelmin=0 specchannelmax=11999 \
            expression="(X,Y) IN ${m2_bkg}"
    backscale spectrumset=${id}_m2_spec_src_tmp_${1}.fits badpixlocation=${id}_m2_clean_evt_${1}.fits
    backscale spectrumset=${id}_m2_spec_bkg_tmp_${1}.fits badpixlocation=${id}_m2_clean_evt_${1}.fits
    rmfgen spectrumset=${id}_m2_spec_src_tmp_${1}.fits rmfset=${id}_m2_spec_rmf_tmp_${1}.fits \
          withenergybins=yes energymin=0.1 energymax=12.0 nenergybins=2400
    arfgen spectrumset=${id}_m2_spec_src_tmp_${1}.fits arfset=${id}_m2_spec_arf_tmp_${1}.fits \
          withrmfset=yes rmfset=${id}_m2_spec_rmf_tmp_${1}.fits 
    
    epicspeccombine pha="${id}_pn_spec_src_tmp_${1}.fits ${id}_m2_spec_src_tmp_${1}.fits" \
      bkg="${id}_pn_spec_bkg_tmp_${1}.fits ${id}_m2_spec_bkg_tmp_${1}.fits" \
      rmf="${id}_pn_spec_rmf_tmp_${1}.fits ${id}_m2_spec_rmf_tmp_${1}.fits" \
      arf="${id}_pn_spec_arf_tmp_${1}.fits ${id}_m2_spec_arf_tmp_${1}.fits" \
      filepha="${id}_ep_spec_src_${1}.fits" \
      filebkg="${id}_ep_spec_bkg_${1}.fits" \
      filersp="${id}_ep_spec_rsp_${1}.fits"
    
    fthedit "${id}_ep_spec_src_${1}.fits" BACKFILE add "${id}_ep_spec_bkg_${1}.fits"
    fthedit "${id}_ep_spec_src_${1}.fits" RESPFILE add "${id}_ep_spec_rsp_${1}.fits"
    fthedit "${id}_ep_spec_src_${1}.fits" ANCRFILE add "none    "

    rm *_tmp_${1}.fits
}
 
# print_src "${id}_pn_src.reg" ${pn_src}
# print_src "${id}_m2_src.reg" ${m2_src}
# print_bkg "${id}_pn_bkg.reg" ${pn_bkg}
# print_bkg "${id}_m2_bkg.reg" ${m2_bkg}

# mk_evt before 0 ${t_INF}
# mk_img before
# print_img before
mk_src_list before
# mk_spec before
# mk_spec_ep before
