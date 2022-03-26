#!/bin/bash -x
#/home/$USER/Dropbox/bin/xray_pn_xtractor.sh >> output.log 2>&1 &
#tar -xf *.tar
#find . -name "*.gz" | while read filename; do uncompress "`dirname "$filename"`" "$filename"; done;

wd=/home/$USER/Dropbox/science/rosmm/survey_xmm
dat_dir=/home/$USER/data/xmm/zhou06_15min
ccf_dir=/home/$USER/ccf
preprocess=true
process=true
flare_limit=0.4
min_cts=25
oversample=3
dtnb=1000
soft=200
mid=2000
hard=12000

cd $wd
coords=($(ps -u $USER | awk '{print $1}' aux/meta_data_insignificant100.dat))
ids=($(ps -u $USER | awk '{print $2}' aux/meta_data_insignificant100.dat))
src=($(ps -u $USER | awk '{print $5}' aux/meta_data_insignificant100.dat))
bkg=($(ps -u $USER | awk '{print $6}' aux/meta_data_insignificant100.dat))

#########
function prep {
    do_sas
    check_flares
    filter
    make_image
}

#########
function proc {
    setup_sas
    make_reg
    print_img
    make_spec_tot
    make_lc
    make_lc_soft_hard
    print_lc
    check_pileup
    cleanup
}

#########
function print_help {
    ps2pdf $1.ps
    pdfcrop $1.pdf
    rm $1.ps $1.pdf
    mv $1-crop.pdf $1.pdf
}

#########
#Initiate and do SAS stuff
function do_sas {
    . /home/$USER/sas_15.0.0-Ubuntu14.04-64/xmmsas_20160201_1833/setsas.sh
    
    export SAS_ODF=$dat_dir/${ids[i]}/ODF/
    export SAS_CCFPATH=$ccf_dir/
    cifbuild
    export SAS_CCF=ccf.cif
    odfingest
    export SAS_ODF=$(ls *SUM.SAS)
    
    epchain    
    mv *PIEVLI* ${coords[i]}_raw.fits
    rm *.FIT
}

#Check background flares
function check_flares {
    evselect table=${coords[i]}_raw.fits withrateset=yes rateset=${coords[i]}_flare.fits timecolumn=TIME timebinsize=1000 makeratecolumn=yes maketimecolumn=yes expression="#XMMEA_EP && PI in [10000:12000] && (PATTERN==0)"
    
    dsplot table=${coords[i]}_flare.fits x=TIME y=RATE plotter="gracebat -printfile ${coords[i]}_flare.ps"
    print_help ${coords[i]}_flare
    
    tabgtigen table=${coords[i]}_flare.fits gtiset=${coords[i]}_gti.fits expression="RATE<$flare_limit"
}

#Create filtered event list
function filter {
    evselect table=${coords[i]}_raw.fits withfilteredset=true filteredset=${coords[i]}_filt.fits keepfilteroutput=true destruct=true expression="(gti(${coords[i]}_gti.fits,TIME) && (PI in [$soft:$hard]) && (PATTERN<=4))"

    evselect table=${coords[i]}_filt.fits withrateset=yes rateset=${coords[i]}_filt_flare.fits timecolumn=TIME timebinsize=1000 makeratecolumn=yes maketimecolumn=yes expression="#XMMEA_EP && PI in [10000:12000] && (PATTERN==0)"
    
    dsplot table=${coords[i]}_filt_flare.fits x=TIME y=RATE plotter="gracebat -printfile ${coords[i]}_filt_flare.ps"
    print_help ${coords[i]}_filt_flare
}

#Create a sky image of the filtered data set
function make_image {
    evselect table=${coords[i]}_filt.fits withimageset=true imageset=${coords[i]}_img.fits xcolumn=X ycolumn=Y imagebinning=binSize ximagebinsize=80 yimagebinsize=80
}

#########
#Initiate and setup SAS variables
function setup_sas {
    . /home/$USER/sas_15.0.0-Ubuntu14.04-64/xmmsas_20160201_1833/setsas.sh
    export SAS_CCFPATH=$ccf_dir/
    export SAS_CCF=ccf.cif
    export SAS_ODF=$(ls *SUM.SAS)
}

#Make ds9 region files
function make_reg {
    header="# Region file format: DS9 version 4.1\nglobal color=green dashlist=8 3 width=1 font=\"helvetica 10 normal roman\" select=1 highlite=1 dash=0 fixed=0 edit=1 move=1 delete=1 include=1 source=1\nphysical\n"
    printf "$header${src[i]}\n">${coords[i]}_src.reg
    header="# Region file format: DS9 version 4.1\nglobal color=red dashlist=8 3 width=1 font=\"helvetica 10 normal roman\" select=1 highlite=1 dash=0 fixed=0 edit=1 move=1 delete=1 include=1 source=1\nphysical\n"
    printf "$header${bkg[i]}\n">${coords[i]}_bkg.reg
}

#Print images
function print_img {
    ds9 ${coords[i]}_img.fits -scale log -cmap Heat -regions load "*.reg" -print destination file -print filename ${coords[i]}_img.ps -print -exit
    print_help ${coords[i]}_img
}

#Create spectra
function make_spec_tot {
    #Source spectra
    evselect table=${coords[i]}_filt.fits withspectrumset=yes spectrumset=${coords[i]}_src.fits energycolumn=PI withspecranges=yes specchannelmin=0 specchannelmax=20479 spectralbinsize=5 expression="((X,Y) IN ${src[i]}) && (FLAG==0) && (PATTERN<=4)"
    
    backscale spectrumset=${coords[i]}_src.fits badpixlocation=${coords[i]}_filt.fits

    #Background spectra
    evselect table=${coords[i]}_filt.fits withspectrumset=yes spectrumset=${coords[i]}_bkg.fits energycolumn=PI withspecranges=yes specchannelmin=0 specchannelmax=20479 spectralbinsize=5 expression="((X,Y) IN ${bkg[i]}) && (FLAG==0) && (PATTERN<=4)"

    backscale spectrumset=${coords[i]}_bkg.fits badpixlocation=${coords[i]}_filt.fits

    #Create response files
    rmfgen spectrumset=${coords[i]}_src.fits rmfset=${coords[i]}_rmf.fits
    arfgen spectrumset=${coords[i]}_src.fits arfset=${coords[i]}_arf.fits withrmfset=yes rmfset=${coords[i]}_rmf.fits badpixlocation=${coords[i]}_filt.fits
    
    #Group spectrum and associate files
    specgroup spectrumset=${coords[i]}_src.fits mincounts=$min_cts oversample=$oversample rmfset=${coords[i]}_rmf.fits arfset=${coords[i]}_arf.fits backgndset=${coords[i]}_bkg.fits groupedset=${coords[i]}_grp.fits 
}

#Make background subtracted light curve
function make_lc {
    evselect table=${coords[i]}_filt.fits withrateset=yes rateset=${coords[i]}_lc_src.fits timecolumn=TIME timebinsize=$dtnb maketimecolumn=yes makeratecolumn=yes expression="((X,Y) IN ${src[i]}) && (PI IN [$soft:$hard])"

    evselect table=${coords[i]}_filt.fits withrateset=yes rateset=${coords[i]}_lc_bkg.fits timecolumn=TIME timebinsize=$dtnb maketimecolumn=yes makeratecolumn=yes expression="((X,Y) IN ${bkg[i]}) && (PI IN [$soft:$hard])"
    
    epiclccorr srctslist=${coords[i]}_lc_src.fits eventlist=${coords[i]}_filt.fits outset=${coords[i]}_lc.fits bkgtslist=${coords[i]}_lc_bkg.fits withbkgset=yes applyabsolutecorrections=yes
}

#Light curves in different energy bands, hardness ratios
function make_lc_soft_hard {
    evselect table=${coords[i]}_filt.fits withrateset=yes rateset=${coords[i]}_lc_soft_src.fits timecolumn=TIME timebinsize=$dtnb maketimecolumn=yes makeratecolumn=yes expression="((X,Y) IN ${src[i]}) && (PI IN [$soft:$mid])"
    evselect table=${coords[i]}_filt.fits withrateset=yes rateset=${coords[i]}_lc_hard_src.fits timecolumn=TIME timebinsize=$dtnb maketimecolumn=yes makeratecolumn=yes expression="((X,Y) IN ${src[i]}) && (PI IN [$mid:$hard])"

    evselect table=${coords[i]}_filt.fits withrateset=yes rateset=${coords[i]}_lc_soft_bkg.fits timecolumn=TIME timebinsize=$dtnb maketimecolumn=yes makeratecolumn=yes expression="((X,Y) IN ${bkg[i]}) && (PI IN [$soft:$mid])"
    evselect table=${coords[i]}_filt.fits withrateset=yes rateset=${coords[i]}_lc_hard_bkg.fits timecolumn=TIME timebinsize=$dtnb maketimecolumn=yes makeratecolumn=yes expression="((X,Y) IN ${bkg[i]}) && (PI IN [$mid:$hard])"
    
    epiclccorr srctslist=${coords[i]}_lc_soft_src.fits eventlist=${coords[i]}_filt.fits outset=${coords[i]}_lc_soft.fits bkgtslist=${coords[i]}_lc_soft_bkg.fits withbkgset=yes applyabsolutecorrections=yes
    epiclccorr srctslist=${coords[i]}_lc_hard_src.fits eventlist=${coords[i]}_filt.fits outset=${coords[i]}_lc_hard.fits bkgtslist=${coords[i]}_lc_hard_bkg.fits withbkgset=yes applyabsolutecorrections=yes
}

#Print light curve related stuff
function print_lc {
    lcplot set=${coords[i]}_lc.fits binsize=1 plotfile=${coords[i]}_lc.ps
    print_help ${coords[i]}_lc

    printf "hardcopy ${coords[i]}_lc.ps/ps \nexit">${coords[i]}_lc.pco
    lcurve nser=1 cfile1=${coords[i]}_lc.fits window=- dtnb=$dtnb nbint=INDEF outfile=temp.fits plot=yes plotdev=/xw plotdnum=3 plotfile=${coords[i]}_lc.pco
    print_help ${coords[i]}_lc

    printf "hardcopy ${coords[i]}_hardness.ps/ps \nexit">${coords[i]}_hardness.pco
    lcurve nser=2 cfile1=${coords[i]}_lc_soft.fits cfile2=${coords[i]}_lc_hard.fits window=- dtnb=$dtnb nbint=INDEF outfile=temp.fits plot=yes plotdev=/xw plotdnum=1 plotfile=${coords[i]}_hardness.pco
    print_help ${coords[i]}_hardness

    rm temp.fits
}

#Check for pileup
function check_pileup {
    evselect table=${coords[i]}_raw.fits withfilteredset=true filteredset=${coords[i]}_filt_src.fits keepfilteroutput=true destruct=true expression="(gti(${coords[i]}_gti.fits,TIME) && (PI IN [100:15000]) && (PATTERN<=4) && (FLAG==0) && ((X,Y) IN ${src[i]}))"
    
    evselect table=${coords[i]}_raw.fits withfilteredset=true filteredset=${coords[i]}_filt_bkg.fits keepfilteroutput=true destruct=true expression="(gti(${coords[i]}_gti.fits,TIME) && (PI IN [100:15000]) && (PATTERN<=4) && (FLAG==0) && ((X,Y) IN ${bkg[i]}))"
    
    epatplot set=${coords[i]}_filt_src.fits plotfile=${coords[i]}_epat.ps useplotfile=yes withbackgroundset=yes backgroundset=${coords[i]}_filt_bkg.fits
    print_help ${coords[i]}_epat
}

#Convert, merge, delete, and move some stuff
function cleanup {
    pdftk *.pdf cat output output.pdf
    rm pgplot.ps *_*.pdf
    mv output.pdf ../outputs/${coords[i]}_output.pdf
    rm *.SAS *flare* 
    rm *filt* *.pco *raw*
}

############################################################################################################################################
############################################################################################################################################

echo "PARAMETERS"
echo ${coords[*]}
echo $preprocess
echo $process
echo $flare_limit
echo $min_cts
echo $oversample
echo $dtnb
echo $soft
echo $mid
echo $hard

n=${#coords[*]}
mkdir -p reduction/outputs
for i in $(seq 0 $(($n-1)))
do
    mkdir -p reduction/${coords[i]}
    cd reduction/${coords[i]}
    if $preprocess ; then
	prep
    fi
    if $process ; then
	proc
    fi
    cd ../../
done

echo "EOF"
