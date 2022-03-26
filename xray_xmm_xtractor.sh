#!/bin/bash -x
#Requires Python 2.* as python in path with matplotlib and numpy
#./Xtractor.sh >> output.log 2>&1 &

src_rad=120
lc_binsize=400
username=dalp
wd=/home/dalp/Dropbox/astrophysics/survey_xmm/
ids=($(ps -u $username | awk '{print $1}' meta_data.txt))
src=($(ps -u $username | awk '{print $2}' meta_data.txt))
bkg=($(ps -u $username | awk '{print $3}' meta_data.txt))

preprocess=true
process=true
pn_flare_limit=0.4
m1_flare_limit=0.35
m2_flare_limit=0.35
min_cts=25
oversample=3
dtnb=1000
dtnb2=1000
dtnb_hardness=4000
dtnb_py=1000 #Must be >= dtnb
flux_bins=5
soft=300
mid=2000
hard=10000

pn_src=circle\(25261.964,27877.058,680\)
pn_bkg=circle\(26639.55,29641.763,680\)
m1_src=circle\(25261.964,27877.058,680\)
m1_bkg=polygon\(24719.103,31450.139,26140.353,31101.287,26941.42,29589.595,25055.035,30171.015,23233.252,28711.005,22677.673,28995.255\)
m2_src=circle\(25261.964,27877.058,680\)
m2_bkg=polygon\(23363.5,27604.6,24276.9,26410.3,25626.3,26386.7,26273.8,26568.8,26759.4,26609.2,27199.5,25834.2,25667.5,24922.1,24347.1,25187.8,23157.9,26001.8,22351.9,26972.3,22084.9,27745.1,23279.2,29824.7,23785.1,29239.6,23813.2,29234.5\)

############################################################################################################################################
############################################################################################################################################

function prep {
#    setup_sas
    do_sas
    check_flares
    filter
    make_image
}

############################################################################################################################################
############################################################################################################################################

function proc {
    setup_sas
    make_reg
    print_img
    make_spec_tot
    make_lc_tot
    make_lc_tot_2
    make_lc_gti_tot
    make_lc_soft_hard
    print_lc
    check_pileup
    cleanup
}

############################################################################################################################################
############################################################################################################################################

#Initiate and do SAS stuff
function do_sas {
    . /home/dalp/sas_15.0.0-Ubuntu14.04-64/xmmsas_20160201_1833/setsas.sh
    
    export SAS_ODF=$wd/data/${ids[i]}/ODF/
    export SAS_CCFPATH=/home/dalp/ccf/
    cifbuild
    export SAS_CCF=ccf.cif
    odfingest
    export SAS_ODF=$(ls *SUM.SAS)
    
    epchain
    emchain
    
    mv *PIEVLI* raw_pn.fits
    mv *M1*MIEVLI* raw_m1.fits
    mv *M2*MIEVLI* raw_m2.fits
    mkdir chain
    mv *.FIT chain/
}

#Check background flares
function check_flares {
    evselect table=raw_pn.fits withrateset=yes rateset=${obs_id}_pn_bkgrate.fits timecolumn=TIME timebinsize=50 makeratecolumn=yes maketimecolumn=yes expression="(PATTERN == 0)&&(#XMMEA_EP)&&(PI IN [10000:12000])"
    evselect table=raw_m1.fits withrateset=yes rateset=${obs_id}_m1_bkgrate.fits timecolumn=TIME timebinsize=50 makeratecolumn=yes maketimecolumn=yes expression="(PATTERN == 0)&&(#XMMEA_EM)&&(PI>10000)"
    evselect table=raw_m2.fits withrateset=yes rateset=${obs_id}_m2_bkgrate.fits timecolumn=TIME timebinsize=50 makeratecolumn=yes maketimecolumn=yes expression="(PATTERN == 0)&&(#XMMEA_EM)&&(PI>10000)"
    
    dsplot table=${obs_id}_pn_bkgrate.fits x=TIME y=RATE plotter="gracebat -printfile ${obs_id}_pn_bkgrate.ps"
    dsplot table=${obs_id}_m1_bkgrate.fits x=TIME y=RATE plotter="gracebat -printfile ${obs_id}_m1_bkgrate.ps"
    dsplot table=${obs_id}_m2_bkgrate.fits x=TIME y=RATE plotter="gracebat -printfile ${obs_id}_m2_bkgrate.ps"
    
    tabgtigen table=${obs_id}_pn_bkgrate.fits gtiset=${obs_id}_pn_gti.fits expression="RATE<$pn_flare_limit"
    tabgtigen table=${obs_id}_m1_bkgrate.fits gtiset=${obs_id}_m1_gti.fits expression="RATE<$m1_flare_limit"
    tabgtigen table=${obs_id}_m2_bkgrate.fits gtiset=${obs_id}_m2_gti.fits expression="RATE<$m2_flare_limit"
}

#Create filtered event list
function filter {
    evselect table=raw_pn.fits withfilteredset=true filteredset=${obs_id}_pn_filt_gti.fits keepfilteroutput=true destruct=true expression="(gti(${obs_id}_pn_gti.fits,TIME)&&gti(${obs_id}_m1_gti.fits,TIME)&&gti(${obs_id}_m2_gti.fits,TIME)&&(PI IN [$soft:$hard])&&(PATTERN<=4)&&(FLAG==0))"
    evselect table=raw_m1.fits withfilteredset=true filteredset=${obs_id}_m1_filt_gti.fits keepfilteroutput=true destruct=true expression="(gti(${obs_id}_pn_gti.fits,TIME)&&gti(${obs_id}_m1_gti.fits,TIME)&&gti(${obs_id}_m2_gti.fits,TIME)&&(PI IN [$soft:$hard])&&(PATTERN<=12)&&(FLAG==0))"
    evselect table=raw_m2.fits withfilteredset=true filteredset=${obs_id}_m2_filt_gti.fits keepfilteroutput=true destruct=true expression="(gti(${obs_id}_pn_gti.fits,TIME)&&gti(${obs_id}_m1_gti.fits,TIME)&&gti(${obs_id}_m2_gti.fits,TIME)&&(PI IN [$soft:$hard])&&(PATTERN<=12)&&(FLAG==0))"

    evselect table=raw_pn.fits withfilteredset=true filteredset=${obs_id}_pn_filt.fits keepfilteroutput=true destruct=true expression="((PI IN [$soft:$hard])&&(PATTERN<=4)&&(FLAG==0))"
    evselect table=raw_m1.fits withfilteredset=true filteredset=${obs_id}_m1_filt.fits keepfilteroutput=true destruct=true expression="((PI IN [$soft:$hard])&&(PATTERN<=12)&&(FLAG==0))"
    evselect table=raw_m2.fits withfilteredset=true filteredset=${obs_id}_m2_filt.fits keepfilteroutput=true destruct=true expression="((PI IN [$soft:$hard])&&(PATTERN<=12)&&(FLAG==0))"
}

#Create a sky image of the filtered data set
function make_image {
    evselect table=${obs_id}_pn_filt_gti.fits withimageset=true imageset=${obs_id}_pn_img_filt_gti.fits xcolumn=X ycolumn=Y imagebinning=binSize ximagebinsize=80 yimagebinsize=80
    evselect table=${obs_id}_m1_filt_gti.fits withimageset=true imageset=${obs_id}_m1_img_filt_gti.fits xcolumn=X ycolumn=Y imagebinning=binSize ximagebinsize=80 yimagebinsize=80
    evselect table=${obs_id}_m2_filt_gti.fits withimageset=true imageset=${obs_id}_m2_img_filt_gti.fits xcolumn=X ycolumn=Y imagebinning=binSize ximagebinsize=80 yimagebinsize=80
}

############################################################################################################################################
############################################################################################################################################

#Initiate and setup SAS variables
function setup_sas {
    . /home/dalp/sas_15.0.0-Ubuntu14.04-64/xmmsas_20160201_1833/setsas.sh
    export SAS_CCFPATH=/home/dalp/ccf/
    export SAS_CCF=ccf.cif
    export SAS_ODF=$(ls *SUM.SAS)
}

#Make ds9 region files
function make_reg {
    header="# Region file format: DS9 version 4.1\nglobal color=green dashlist=8 3 width=1 font=\"helvetica 10 normal roman\" select=1 highlite=1 dash=0 fixed=0 edit=1 move=1 delete=1 include=1 source=1\nphysical\n"
    printf "$header$pn_src""\n">src_pn.reg
    printf "$header$m1_src\n">src_m1.reg
    printf "$header$m2_src\n">src_m2.reg
    header="# Region file format: DS9 version 4.1\nglobal color=red dashlist=8 3 width=1 font=\"helvetica 10 normal roman\" select=1 highlite=1 dash=0 fixed=0 edit=1 move=1 delete=1 include=1 source=1\nphysical\n"
    printf "$header$pn_bkg\n">bkg_pn.reg
    printf "$header$m1_bkg\n">bkg_m1.reg
    printf "$header$m2_bkg\n">bkg_m2.reg
}

#Print images
function print_img {
    ds9 ${obs_id}_pn_img_filt_gti.fits -scale log -cmap Heat -regions load "*_pn.reg" -print destination file -print filename ${obs_id}_pn_img_filt_gti.ps -print -exit
    sleep 30 #Because ds9 has some issues
    ds9 ${obs_id}_m1_img_filt_gti.fits -scale log -cmap Heat -regions load "*_m1.reg" -print destination file -print filename ${obs_id}_m1_img_filt_gti.ps -print -exit
    sleep 30
    ds9 ${obs_id}_m2_img_filt_gti.fits -scale log -cmap Heat -regions load "*_m2.reg" -print destination file -print filename ${obs_id}_m2_img_filt_gti.ps -print -exit
}

#Create spectra
function make_spec_tot {
    #Source spectra
    evselect table=${obs_id}_pn_filt_gti.fits updateexposure=yes withspecranges=yes withspectrumset=yes energycolumn=PI expression="(X,Y) IN $pn_src" specchannelmax=20479 specchannelmin=0 spectralbinsize=5 spectrumset=${obs_id}_pn_spec_src.fits
    evselect table=${obs_id}_m1_filt_gti.fits updateexposure=yes withspecranges=yes withspectrumset=yes energycolumn=PI expression="(X,Y) IN $m1_src" specchannelmax=11999 specchannelmin=0 spectralbinsize=5 spectrumset=${obs_id}_m1_spec_src.fits
    evselect table=${obs_id}_m2_filt_gti.fits updateexposure=yes withspecranges=yes withspectrumset=yes energycolumn=PI expression="(X,Y) IN $m2_src" specchannelmax=11999 specchannelmin=0 spectralbinsize=5 spectrumset=${obs_id}_m2_spec_src.fits
    
    backscale spectrumset=${obs_id}_pn_spec_src.fits badpixlocation=${obs_id}_pn_filt_gti.fits withbadpixcorr=yes useodfatt=no
    backscale spectrumset=${obs_id}_m1_spec_src.fits badpixlocation=${obs_id}_m1_filt_gti.fits withbadpixcorr=yes useodfatt=no
    backscale spectrumset=${obs_id}_m2_spec_src.fits badpixlocation=${obs_id}_m2_filt_gti.fits withbadpixcorr=yes useodfatt=no
    
    #Background spectra
    evselect table=${obs_id}_pn_filt_gti.fits updateexposure=yes withspecranges=yes withspectrumset=yes energycolumn=PI expression="(X,Y) IN $pn_bkg" specchannelmax=20479 specchannelmin=0 spectralbinsize=5 spectrumset=${obs_id}_pn_spec_bkg.fits
    evselect table=${obs_id}_m1_filt_gti.fits updateexposure=yes withspecranges=yes withspectrumset=yes energycolumn=PI expression="(X,Y) IN $m1_bkg" specchannelmax=11999 specchannelmin=0 spectralbinsize=5 spectrumset=${obs_id}_m1_spec_bkg.fits
    evselect table=${obs_id}_m2_filt_gti.fits updateexposure=yes withspecranges=yes withspectrumset=yes energycolumn=PI expression="(X,Y) IN $m2_bkg" specchannelmax=11999 specchannelmin=0 spectralbinsize=5 spectrumset=${obs_id}_m2_spec_bkg.fits

    backscale spectrumset=${obs_id}_pn_spec_bkg.fits badpixlocation=${obs_id}_pn_filt_gti.fits withbadpixcorr=yes useodfatt=no
    backscale spectrumset=${obs_id}_m1_spec_bkg.fits badpixlocation=${obs_id}_m1_filt_gti.fits withbadpixcorr=yes useodfatt=no
    backscale spectrumset=${obs_id}_m2_spec_bkg.fits badpixlocation=${obs_id}_m2_filt_gti.fits withbadpixcorr=yes useodfatt=no
    
    #Create response files
    rmfgen rmfset=${obs_id}_pn_rmf.fits spectrumset=${obs_id}_pn_spec_src.fits
    rmfgen rmfset=${obs_id}_m1_rmf.fits spectrumset=${obs_id}_m1_spec_src.fits
    rmfgen rmfset=${obs_id}_m2_rmf.fits spectrumset=${obs_id}_m2_spec_src.fits
    
    arfgen arfset=${obs_id}_pn_arf.fits spectrumset=${obs_id}_pn_spec_src.fits withrmfset=yes rmfset=${obs_id}_pn_rmf.fits badpixlocation=${obs_id}_pn_filt_gti.fits
    arfgen arfset=${obs_id}_m1_arf.fits spectrumset=${obs_id}_m1_spec_src.fits withrmfset=yes rmfset=${obs_id}_m1_rmf.fits badpixlocation=${obs_id}_m1_filt_gti.fits
    arfgen arfset=${obs_id}_m2_arf.fits spectrumset=${obs_id}_m2_spec_src.fits withrmfset=yes rmfset=${obs_id}_m2_rmf.fits badpixlocation=${obs_id}_m2_filt_gti.fits
    
    #Group spectrum and associate files
    specgroup spectrumset=${obs_id}_pn_spec_src.fits groupedset=${obs_id}_pn_spec_grp.fits mincounts=$min_cts oversample=$oversample rmfset=${obs_id}_pn_rmf.fits arfset=${obs_id}_pn_arf.fits backgndset=${obs_id}_pn_spec_bkg.fits
    specgroup spectrumset=${obs_id}_m1_spec_src.fits groupedset=${obs_id}_m1_spec_grp.fits mincounts=$min_cts oversample=$oversample rmfset=${obs_id}_m1_rmf.fits arfset=${obs_id}_m1_arf.fits backgndset=${obs_id}_m1_spec_bkg.fits
    specgroup spectrumset=${obs_id}_m2_spec_src.fits groupedset=${obs_id}_m2_spec_grp.fits mincounts=$min_cts oversample=$oversample rmfset=${obs_id}_m2_rmf.fits arfset=${obs_id}_m2_arf.fits backgndset=${obs_id}_m2_spec_bkg.fits
}

#Make background subtracted light curve
function make_lc_tot {
    evselect table=${obs_id}_pn_filt.fits withrateset=yes rateset=${obs_id}_pn_lc_src.fits timecolumn=TIME timebinsize=$dtnb maketimecolumn=yes makeratecolumn=yes expression="((X,Y) IN $pn_src)&&(PI IN [$soft:$hard])"
    evselect table=${obs_id}_m1_filt.fits withrateset=yes rateset=${obs_id}_m1_lc_src.fits timecolumn=TIME timebinsize=$dtnb maketimecolumn=yes makeratecolumn=yes expression="((X,Y) IN $m1_src)&&(PI IN [$soft:$hard])"
    evselect table=${obs_id}_m2_filt.fits withrateset=yes rateset=${obs_id}_m2_lc_src.fits timecolumn=TIME timebinsize=$dtnb maketimecolumn=yes makeratecolumn=yes expression="((X,Y) IN $m2_src)&&(PI IN [$soft:$hard])"

    evselect table=${obs_id}_pn_filt.fits withrateset=yes rateset=${obs_id}_pn_lc_bkg.fits timecolumn=TIME timebinsize=$dtnb maketimecolumn=yes makeratecolumn=yes expression="((X,Y) IN $pn_bkg)&&(PI IN [$soft:$hard])"
    evselect table=${obs_id}_m1_filt.fits withrateset=yes rateset=${obs_id}_m1_lc_bkg.fits timecolumn=TIME timebinsize=$dtnb maketimecolumn=yes makeratecolumn=yes expression="((X,Y) IN $m1_bkg)&&(PI IN [$soft:$hard])"
    evselect table=${obs_id}_m2_filt.fits withrateset=yes rateset=${obs_id}_m2_lc_bkg.fits timecolumn=TIME timebinsize=$dtnb maketimecolumn=yes makeratecolumn=yes expression="((X,Y) IN $m2_bkg)&&(PI IN [$soft:$hard])"
    
    epiclccorr srctslist=${obs_id}_pn_lc_src.fits eventlist=${obs_id}_pn_filt.fits outset=${obs_id}_pn_lc_cor.fits bkgtslist=${obs_id}_pn_lc_bkg.fits withbkgset=yes applyabsolutecorrections=yes
    epiclccorr srctslist=${obs_id}_m1_lc_src.fits eventlist=${obs_id}_m1_filt.fits outset=${obs_id}_m1_lc_cor.fits bkgtslist=${obs_id}_m1_lc_bkg.fits withbkgset=yes applyabsolutecorrections=yes
    epiclccorr srctslist=${obs_id}_m2_lc_src.fits eventlist=${obs_id}_m2_filt.fits outset=${obs_id}_m2_lc_cor.fits bkgtslist=${obs_id}_m2_lc_bkg.fits withbkgset=yes applyabsolutecorrections=yes
}

#Make coarse background subtracted light curve
function make_lc_tot_2 {
    evselect table=${obs_id}_pn_filt.fits withrateset=yes rateset=${obs_id}_pn_lc_src_2.fits timecolumn=TIME timebinsize=$dtnb2 maketimecolumn=yes makeratecolumn=yes expression="((X,Y) IN $pn_src)&&(PI IN [$soft:$hard])"
    evselect table=${obs_id}_m1_filt.fits withrateset=yes rateset=${obs_id}_m1_lc_src_2.fits timecolumn=TIME timebinsize=$dtnb2 maketimecolumn=yes makeratecolumn=yes expression="((X,Y) IN $m1_src)&&(PI IN [$soft:$hard])"
    evselect table=${obs_id}_m2_filt.fits withrateset=yes rateset=${obs_id}_m2_lc_src_2.fits timecolumn=TIME timebinsize=$dtnb2 maketimecolumn=yes makeratecolumn=yes expression="((X,Y) IN $m2_src)&&(PI IN [$soft:$hard])"

    evselect table=${obs_id}_pn_filt.fits withrateset=yes rateset=${obs_id}_pn_lc_bkg_2.fits timecolumn=TIME timebinsize=$dtnb2 maketimecolumn=yes makeratecolumn=yes expression="((X,Y) IN $pn_bkg)&&(PI IN [$soft:$hard])"
    evselect table=${obs_id}_m1_filt.fits withrateset=yes rateset=${obs_id}_m1_lc_bkg_2.fits timecolumn=TIME timebinsize=$dtnb2 maketimecolumn=yes makeratecolumn=yes expression="((X,Y) IN $m1_bkg)&&(PI IN [$soft:$hard])"
    evselect table=${obs_id}_m2_filt.fits withrateset=yes rateset=${obs_id}_m2_lc_bkg_2.fits timecolumn=TIME timebinsize=$dtnb2 maketimecolumn=yes makeratecolumn=yes expression="((X,Y) IN $m2_bkg)&&(PI IN [$soft:$hard])"
    
    epiclccorr srctslist=${obs_id}_pn_lc_src_2.fits eventlist=${obs_id}_pn_filt.fits outset=${obs_id}_pn_lc_cor_2.fits bkgtslist=${obs_id}_pn_lc_bkg_2.fits withbkgset=yes applyabsolutecorrections=yes
    epiclccorr srctslist=${obs_id}_m1_lc_src_2.fits eventlist=${obs_id}_m1_filt.fits outset=${obs_id}_m1_lc_cor_2.fits bkgtslist=${obs_id}_m1_lc_bkg_2.fits withbkgset=yes applyabsolutecorrections=yes
    epiclccorr srctslist=${obs_id}_m2_lc_src_2.fits eventlist=${obs_id}_m2_filt.fits outset=${obs_id}_m2_lc_cor_2.fits bkgtslist=${obs_id}_m2_lc_bkg_2.fits withbkgset=yes applyabsolutecorrections=yes
}

#Make background subtracted light curve during good time interval for flux cuts
function make_lc_gti_tot {
    evselect table=${obs_id}_pn_filt_gti.fits withrateset=yes rateset=${obs_id}_pn_lc_src_gti.fits timecolumn=TIME timebinsize=$dtnb2 maketimecolumn=yes makeratecolumn=yes expression="((X,Y) IN $pn_src)&&(PI IN [$soft:$hard])"
    evselect table=${obs_id}_m1_filt_gti.fits withrateset=yes rateset=${obs_id}_m1_lc_src_gti.fits timecolumn=TIME timebinsize=$dtnb2 maketimecolumn=yes makeratecolumn=yes expression="((X,Y) IN $m1_src)&&(PI IN [$soft:$hard])"
    evselect table=${obs_id}_m2_filt_gti.fits withrateset=yes rateset=${obs_id}_m2_lc_src_gti.fits timecolumn=TIME timebinsize=$dtnb2 maketimecolumn=yes makeratecolumn=yes expression="((X,Y) IN $m2_src)&&(PI IN [$soft:$hard])"

    evselect table=${obs_id}_pn_filt_gti.fits withrateset=yes rateset=${obs_id}_pn_lc_bkg_gti.fits timecolumn=TIME timebinsize=$dtnb2 maketimecolumn=yes makeratecolumn=yes expression="((X,Y) IN $pn_bkg)&&(PI IN [$soft:$hard])"
    evselect table=${obs_id}_m1_filt_gti.fits withrateset=yes rateset=${obs_id}_m1_lc_bkg_gti.fits timecolumn=TIME timebinsize=$dtnb2 maketimecolumn=yes makeratecolumn=yes expression="((X,Y) IN $m1_bkg)&&(PI IN [$soft:$hard])"
    evselect table=${obs_id}_m2_filt_gti.fits withrateset=yes rateset=${obs_id}_m2_lc_bkg_gti.fits timecolumn=TIME timebinsize=$dtnb2 maketimecolumn=yes makeratecolumn=yes expression="((X,Y) IN $m2_bkg)&&(PI IN [$soft:$hard])"
    
    epiclccorr srctslist=${obs_id}_pn_lc_src_gti.fits eventlist=${obs_id}_pn_filt_gti.fits outset=${obs_id}_pn_lc_cor_gti.fits bkgtslist=${obs_id}_pn_lc_bkg_gti.fits withbkgset=yes applyabsolutecorrections=yes
    epiclccorr srctslist=${obs_id}_m1_lc_src_gti.fits eventlist=${obs_id}_m1_filt_gti.fits outset=${obs_id}_m1_lc_cor_gti.fits bkgtslist=${obs_id}_m1_lc_bkg_gti.fits withbkgset=yes applyabsolutecorrections=yes
    epiclccorr srctslist=${obs_id}_m2_lc_src_gti.fits eventlist=${obs_id}_m2_filt_gti.fits outset=${obs_id}_m2_lc_cor_gti.fits bkgtslist=${obs_id}_m2_lc_bkg_gti.fits withbkgset=yes applyabsolutecorrections=yes
}

#Light curves in different energy bands, hardness ratios
function make_lc_soft_hard {
    evselect table=${obs_id}_pn_filt.fits withrateset=yes rateset=${obs_id}_pn_lc_soft_src.fits timecolumn=TIME timebinsize=$dtnb maketimecolumn=yes makeratecolumn=yes expression="((X,Y) IN $pn_src)&&(PI IN [$soft:$mid])"
    evselect table=${obs_id}_m1_filt.fits withrateset=yes rateset=${obs_id}_m1_lc_soft_src.fits timecolumn=TIME timebinsize=$dtnb maketimecolumn=yes makeratecolumn=yes expression="((X,Y) IN $m1_src)&&(PI IN [$soft:$mid])"
    evselect table=${obs_id}_m2_filt.fits withrateset=yes rateset=${obs_id}_m2_lc_soft_src.fits timecolumn=TIME timebinsize=$dtnb maketimecolumn=yes makeratecolumn=yes expression="((X,Y) IN $m2_src)&&(PI IN [$soft:$mid])"
    evselect table=${obs_id}_pn_filt.fits withrateset=yes rateset=${obs_id}_pn_lc_hard_src.fits timecolumn=TIME timebinsize=$dtnb maketimecolumn=yes makeratecolumn=yes expression="((X,Y) IN $pn_src)&&(PI IN [$mid:$hard])"
    evselect table=${obs_id}_m1_filt.fits withrateset=yes rateset=${obs_id}_m1_lc_hard_src.fits timecolumn=TIME timebinsize=$dtnb maketimecolumn=yes makeratecolumn=yes expression="((X,Y) IN $m1_src)&&(PI IN [$mid:$hard])"
    evselect table=${obs_id}_m2_filt.fits withrateset=yes rateset=${obs_id}_m2_lc_hard_src.fits timecolumn=TIME timebinsize=$dtnb maketimecolumn=yes makeratecolumn=yes expression="((X,Y) IN $m2_src)&&(PI IN [$mid:$hard])"

    evselect table=${obs_id}_pn_filt.fits withrateset=yes rateset=${obs_id}_pn_lc_soft_bkg.fits timecolumn=TIME timebinsize=$dtnb maketimecolumn=yes makeratecolumn=yes expression="((X,Y) IN $pn_bkg)&&(PI IN [$soft:$mid])"
    evselect table=${obs_id}_m1_filt.fits withrateset=yes rateset=${obs_id}_m1_lc_soft_bkg.fits timecolumn=TIME timebinsize=$dtnb maketimecolumn=yes makeratecolumn=yes expression="((X,Y) IN $m1_bkg)&&(PI IN [$soft:$mid])"
    evselect table=${obs_id}_m2_filt.fits withrateset=yes rateset=${obs_id}_m2_lc_soft_bkg.fits timecolumn=TIME timebinsize=$dtnb maketimecolumn=yes makeratecolumn=yes expression="((X,Y) IN $m2_bkg)&&(PI IN [$soft:$mid])"
    evselect table=${obs_id}_pn_filt.fits withrateset=yes rateset=${obs_id}_pn_lc_hard_bkg.fits timecolumn=TIME timebinsize=$dtnb maketimecolumn=yes makeratecolumn=yes expression="((X,Y) IN $pn_bkg)&&(PI IN [$mid:$hard])"
    evselect table=${obs_id}_m1_filt.fits withrateset=yes rateset=${obs_id}_m1_lc_hard_bkg.fits timecolumn=TIME timebinsize=$dtnb maketimecolumn=yes makeratecolumn=yes expression="((X,Y) IN $m1_bkg)&&(PI IN [$mid:$hard])"
    evselect table=${obs_id}_m2_filt.fits withrateset=yes rateset=${obs_id}_m2_lc_hard_bkg.fits timecolumn=TIME timebinsize=$dtnb maketimecolumn=yes makeratecolumn=yes expression="((X,Y) IN $m2_bkg)&&(PI IN [$mid:$hard])"
    
    epiclccorr srctslist=${obs_id}_pn_lc_soft_src.fits eventlist=${obs_id}_pn_filt.fits outset=${obs_id}_pn_lc_soft_cor.fits bkgtslist=${obs_id}_pn_lc_soft_bkg.fits withbkgset=yes applyabsolutecorrections=yes
    epiclccorr srctslist=${obs_id}_m1_lc_soft_src.fits eventlist=${obs_id}_m1_filt.fits outset=${obs_id}_m1_lc_soft_cor.fits bkgtslist=${obs_id}_m1_lc_soft_bkg.fits withbkgset=yes applyabsolutecorrections=yes
    epiclccorr srctslist=${obs_id}_m2_lc_soft_src.fits eventlist=${obs_id}_m2_filt.fits outset=${obs_id}_m2_lc_soft_cor.fits bkgtslist=${obs_id}_m2_lc_soft_bkg.fits withbkgset=yes applyabsolutecorrections=yes
    epiclccorr srctslist=${obs_id}_pn_lc_hard_src.fits eventlist=${obs_id}_pn_filt.fits outset=${obs_id}_pn_lc_hard_cor.fits bkgtslist=${obs_id}_pn_lc_hard_bkg.fits withbkgset=yes applyabsolutecorrections=yes
    epiclccorr srctslist=${obs_id}_m1_lc_hard_src.fits eventlist=${obs_id}_m1_filt.fits outset=${obs_id}_m1_lc_hard_cor.fits bkgtslist=${obs_id}_m1_lc_hard_bkg.fits withbkgset=yes applyabsolutecorrections=yes
    epiclccorr srctslist=${obs_id}_m2_lc_hard_src.fits eventlist=${obs_id}_m2_filt.fits outset=${obs_id}_m2_lc_hard_cor.fits bkgtslist=${obs_id}_m2_lc_hard_bkg.fits withbkgset=yes applyabsolutecorrections=yes
}

#Print light curve related stuff
function print_lc {
    lcplot set=${obs_id}_pn_lc_cor.fits binsize=1 plotfile=${obs_id}_pn_lc_cor.ps
    lcplot set=${obs_id}_m1_lc_cor.fits binsize=1 plotfile=${obs_id}_m1_lc_cor.ps
    lcplot set=${obs_id}_m2_lc_cor.fits binsize=1 plotfile=${obs_id}_m2_lc_cor.ps

    exposure=$(python -c "print $(hexdump -e '80/1 "%_p" "\n"' ${obs_id}_pn_lc_soft_cor.fits | grep -m 1 TSTOP | awk '{print $3}')-$(hexdump -e '80/1 "%_p" "\n"' ${obs_id}_pn_lc_soft_cor.fits | grep -m 1 TSTART | awk '{print $3}')")
    bins_hardness=$((echo "import math~print math.ceil(float($exposure)/float($dtnb_hardness))" | tr "~" "\n") | python)
    bins_ratio=$((echo "import math~print math.ceil(float($exposure)/float($dtnb))" | tr "~" "\n") | python)
    bins_py=$((echo "import math~print math.ceil(float($exposure)/float($dtnb_py))" | tr "~" "\n") | python)
    printf "hardcopy ${obs_id}_pn_lc_hardness.ps/ps \nexit">temp.pco
    printf "hardcopy lc_both_pn.ps/ps \nexit">temp2.pco
    lcurve nser=2 cfile1=${obs_id}_pn_lc_soft_cor.fits cfile2=${obs_id}_pn_lc_hard_cor.fits window=- dtnb=$dtnb_hardness nbint=$bins_hardness outfile=${obs_id}_pn_lc_grp_coarse.fits plot=yes plotdev=/xw plotdnum=1 plotfile=temp.pco
    lcurve nser=2 cfile1=${obs_id}_pn_lc_soft_cor.fits cfile2=${obs_id}_pn_lc_hard_cor.fits window=- dtnb=$dtnb nbint=$bins_ratio outfile=${obs_id}_pn_lc_grp.fits plot=yes plotdev=/xw plotdnum=3 plotfile=temp2.pco
    lcurve nser=2 cfile1=${obs_id}_pn_lc_soft_cor.fits cfile2=${obs_id}_pn_lc_hard_cor.fits window=- dtnb=$dtnb_py nbint=$bins_py outfile=${obs_id}_pn_lc_grp_py.fits plot=no
    
    exposure=$(python -c "print $(hexdump -e '80/1 "%_p" "\n"' ${obs_id}_m1_lc_soft_cor.fits | grep -m 1 TSTOP | awk '{print $3}')-$(hexdump -e '80/1 "%_p" "\n"' ${obs_id}_m1_lc_soft_cor.fits | grep -m 1 TSTART | awk '{print $3}')")
    bins_hardness=$((echo "import math~print math.ceil(float($exposure)/float($dtnb_hardness))" | tr "~" "\n") | python)
    bins_ratio=$((echo "import math~print math.ceil(float($exposure)/float($dtnb))" | tr "~" "\n") | python)
    bins_py=$((echo "import math~print math.ceil(float($exposure)/float($dtnb_py))" | tr "~" "\n") | python)
    printf "hardcopy ${obs_id}_m1_lc_hardness.ps/ps \nexit">temp.pco
    printf "hardcopy lc_both_m1.ps/ps \nexit">temp2.pco
    lcurve nser=2 cfile1=${obs_id}_m1_lc_soft_cor.fits cfile2=${obs_id}_m1_lc_hard_cor.fits window=- dtnb=$dtnb_hardness nbint=$bins_hardness outfile=${obs_id}_m1_lc_grp_coarse.fits plot=yes plotdev=/xw plotdnum=1 plotfile=temp.pco
    lcurve nser=2 cfile1=${obs_id}_m1_lc_soft_cor.fits cfile2=${obs_id}_m1_lc_hard_cor.fits window=- dtnb=$dtnb nbint=$bins_ratio outfile=${obs_id}_m1_lc_grp.fits plot=yes plotdev=/xw plotdnum=3 plotfile=temp2.pco
    lcurve nser=2 cfile1=${obs_id}_m1_lc_soft_cor.fits cfile2=${obs_id}_m1_lc_hard_cor.fits window=- dtnb=$dtnb_py nbint=$bins_py outfile=${obs_id}_m1_lc_grp_py.fits plot=no
    
    exposure=$(python -c "print $(hexdump -e '80/1 "%_p" "\n"' ${obs_id}_m2_lc_soft_cor.fits | grep -m 1 TSTOP | awk '{print $3}')-$(hexdump -e '80/1 "%_p" "\n"' ${obs_id}_m2_lc_soft_cor.fits | grep -m 1 TSTART | awk '{print $3}')")
    bins_hardness=$((echo "import math~print math.ceil(float($exposure)/float($dtnb_hardness))" | tr "~" "\n") | python)
    bins_ratio=$((echo "import math~print math.ceil(float($exposure)/float($dtnb))" | tr "~" "\n") | python)
    bins_py=$((echo "import math~print math.ceil(float($exposure)/float($dtnb_py))" | tr "~" "\n") | python)
    printf "hardcopy ${obs_id}_m2_lc_hardness.ps/ps \nexit">temp.pco
    printf "hardcopy lc_both_m2.ps/ps \nexit">temp2.pco
    lcurve nser=2 cfile1=${obs_id}_m2_lc_soft_cor.fits cfile2=${obs_id}_m2_lc_hard_cor.fits window=- dtnb=$dtnb_hardness nbint=$bins_hardness outfile=${obs_id}_m2_lc_grp_coarse.fits plot=yes plotdev=/xw plotdnum=1 plotfile=temp.pco
    lcurve nser=2 cfile1=${obs_id}_m2_lc_soft_cor.fits cfile2=${obs_id}_m2_lc_hard_cor.fits window=- dtnb=$dtnb nbint=$bins_ratio outfile=${obs_id}_m2_lc_grp.fits plot=yes plotdev=/xw plotdnum=3 plotfile=temp2.pco
    lcurve nser=2 cfile1=${obs_id}_m2_lc_soft_cor.fits cfile2=${obs_id}_m2_lc_hard_cor.fits window=- dtnb=$dtnb_py nbint=$bins_py outfile=${obs_id}_m2_lc_grp_py.fits plot=no

    rm *.pco
    print_python
}

function print_python {
    dstoplot table=${obs_id}_pn_lc_grp_py.fits x=SUM12 y=RATIO_12 outputfile=pn.dat
    dstoplot table=${obs_id}_m1_lc_grp_py.fits x=SUM12 y=RATIO_12 outputfile=m1.dat
    dstoplot table=${obs_id}_m2_lc_grp_py.fits x=SUM12 y=RATIO_12 outputfile=m2.dat
    printf "import numpy as np
import matplotlib.pyplot as plt

nbins = $flux_bins
cams = ['pn','m1','m2']
for i in range(0,3):
    data = open(cams[i]+'.dat', 'r')

    for j in range(0,12):
        data.readline()
        
    x = []
    y = []
    for line in data:
        if line == '&"'\\n'"':
            break
        temp1,temp2=line.split(' ')
        x.append(float(temp1))
        y.append(float(temp2))
    x=np.array(x)
    y=np.array(y)

    n, _ = np.histogram(x, bins=nbins)
    sy, _ = np.histogram(x, bins=nbins, weights=y)
    sy2, _ = np.histogram(x, bins=nbins, weights=y*y)
    mean = sy / n
    std = np.sqrt(sy2/n - mean*mean)

    z = np.polyfit(x, y, 1)
    pol = np.poly1d(z)
    
    plt.clf()
    plt.plot(x, y, 'bo')
    plt.plot(x, pol(x), 'g')
    plt.errorbar((_[1:] + _[:-1])/2, mean, yerr=std, fmt='r-')
    plt.xlabel('Ser 1+2 [counts/s]')
    plt.ylabel('Ser 2/Ser 1')
    plt.savefig('lc_hardness_python_'+cams[i]+'.pdf', bbox_inches='tight')
    
    data.close()" > temp.py
    python temp.py
    rm temp.py *.dat
}

#Check for pileup
function check_pileup {
    evselect table=raw_pn.fits withfilteredset=true filteredset=${obs_id}_pn_filt_src.fits keepfilteroutput=true destruct=true expression="(gti(${obs_id}_pn_gti.fits,TIME)&&(PI IN [100:15000])&&(PATTERN<=4)&&(FLAG==0)&&((X,Y) IN $pn_src))"
    evselect table=raw_m1.fits withfilteredset=true filteredset=${obs_id}_m1_filt_src.fits keepfilteroutput=true destruct=true expression="(gti(${obs_id}_m1_gti.fits,TIME)&&(PI IN [100:15000])&&(PATTERN<=12)&&(FLAG==0)&&((X,Y) IN $m1_src))"
    evselect table=raw_m2.fits withfilteredset=true filteredset=${obs_id}_m2_filt_src.fits keepfilteroutput=true destruct=true expression="(gti(${obs_id}_m2_gti.fits,TIME)&&(PI IN [100:15000])&&(PATTERN<=12)&&(FLAG==0)&&((X,Y) IN $m2_src))"
    
    evselect table=raw_pn.fits withfilteredset=true filteredset=${obs_id}_pn_filt_bkg.fits keepfilteroutput=true destruct=true expression="(gti(${obs_id}_pn_gti.fits,TIME)&&(PI IN [100:15000])&&(PATTERN<=4)&&(FLAG==0)&&((X,Y) IN $pn_bkg))"
    evselect table=raw_m1.fits withfilteredset=true filteredset=${obs_id}_m1_filt_bkg.fits keepfilteroutput=true destruct=true expression="(gti(${obs_id}_m1_gti.fits,TIME)&&(PI IN [100:15000])&&(PATTERN<=12)&&(FLAG==0)&&((X,Y) IN $m1_bkg))"
    evselect table=raw_m2.fits withfilteredset=true filteredset=${obs_id}_m2_filt_bkg.fits keepfilteroutput=true destruct=true expression="(gti(${obs_id}_m2_gti.fits,TIME)&&(PI IN [100:15000])&&(PATTERN<=12)&&(FLAG==0)&&((X,Y) IN $m2_bkg))"
    
    epatplot set=${obs_id}_pn_filt_src.fits plotfile=${obs_id}_pn_epat.ps useplotfile=yes withbackgroundset=yes backgroundset=${obs_id}_pn_filt_bkg.fits
    epatplot set=${obs_id}_m1_filt_src.fits plotfile=${obs_id}_m1_epat.ps useplotfile=yes withbackgroundset=yes backgroundset=${obs_id}_m1_filt_bkg.fits
    epatplot set=${obs_id}_m2_filt_src.fits plotfile=${obs_id}_m2_epat.ps useplotfile=yes withbackgroundset=yes backgroundset=${obs_id}_m2_filt_bkg.fits
    rm pgplot.ps
}

#Convert, merge, delete, and move some stuff
function cleanup {
    for FILE in *.ps
    do
	ps2pdf $FILE
    done
    pdftk *pn*.pdf cat output pn.pdf
    pdftk *m1*.pdf cat output m1.pdf
    pdftk *m2*.pdf cat output m2.pdf
    rm *_pn*.p* *_m1*.p* *_m2*.p*
    
    mkdir check
    mv *.pdf check/
}

############################################################################################################################################
############################################################################################################################################

echo "PARAMETERS"
echo ${ids[i]}
echo $preprocess
echo $process
echo $pn_flare_limit
echo $m1_flare_limit
echo $m2_flare_limit
echo $min_cts
echo $oversample
echo $dtnb
echo $dtnb2
echo $dtnb_hardness
echo $dtnb_py
echo $flux_bins
echo $soft
echo $mid
echo $hard
echo $pn_src
echo $pn_bkg
echo $m1_src
echo $m1_bkg
echo $m2_src
echo $m2_bkg

if $preprocess ; then
    prep
fi
if $process ; then
    proc
fi

echo "EOF"
