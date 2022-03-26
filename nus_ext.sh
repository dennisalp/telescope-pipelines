#!/bin/bash

# Crab
wrk_dir=/Users/$USER/dat/nus/cra/
ra=83.63321037531692
dec=22.014468824483345

# SN 1987A
wrk_dir=/Users/$USER/dat/nus/87a/
ra=83.86661458333332
dec=-69.26975194444444

# North of SN 1987A
ra=83.858739
dec=-69.229282

# Dry
#wrk_dir=/Users/$USER/dat/tmp/
#ra=83.86661458333332
#dec=-69.26975194444444

################################################################

cd $wrk_dir
ids=($(ls -d */ | sed 's#/##'))
nid=${#ids[*]}
#ids=(40101015002 40101015004)
#nid=2
#ids=(40001014013)
#nid=1

for id in $(seq 0 $(($nid-1)))
do
    cd ${ids[id]}
    echo ${ids[id]}
#    nupipeline indir=. steminputs=nu${ids[id]} outdir=./pro obsmode=SCIENCE
#    barycorr infile=./pro/nu${ids[id]}A01_cl.evt outfile=./pro/nu${ids[id]}A01_bc.evt orbitfiles=./auxil/nu${ids[id]}_orb.fits ra=${ra} dec=${dec} refframe=ICRS
#    barycorr infile=./pro/nu${ids[id]}B01_cl.evt outfile=./pro/nu${ids[id]}B01_bc.evt orbitfiles=./auxil/nu${ids[id]}_orb.fits ra=${ra} dec=${dec} refframe=ICRS

#    nuscreen infile=./pro/nu${ids[id]}A01_cl.evt gtiscreen=no evtscreen=yes gtiexpr=NONE gradeexpr=0 statusexpr=NONE outdir=./pro hkfile=./pro/nu${ids[id]}A_fpm.hk outfile=DEFAULT
#    nuscreen infile=./pro/nu${ids[id]}B01_cl.evt gtiscreen=no evtscreen=yes gtiexpr=NONE gradeexpr=0 statusexpr=NONE outdir=./pro hkfile=./pro/nu${ids[id]}B_fpm.hk outfile=DEFAULT

#    nuproducts indir=./pro infile=./pro/nu${ids[id]}A01_cl.evt instrument=FPMA steminputs=nu${ids[id]} outdir=./pro srcra=${ra} srcdec=${dec} srcradius=12 bkgra=${ra} bkgdec=${dec} bkgradius1=28 bkgradius2=36 rungrppha=yes grpmincounts=25 grppibadlow=35 grppibadhigh=1909
#    nuproducts indir=./pro infile=./pro/nu${ids[id]}B01_cl.evt instrument=FPMB steminputs=nu${ids[id]} outdir=./pro srcra=${ra} srcdec=${dec} srcradius=12 bkgra=${ra} bkgdec=${dec} bkgradius1=28 bkgradius2=36 rungrppha=yes grpmincounts=25 grppibadlow=35 grppibadhigh=1909

    nuproducts indir=./pro infile=./pro/nu${ids[id]}A01_cl.evt instrument=FPMA steminputs=nu${ids[id]} outdir=./pro srcregionfile=srcA.reg bkgregionfile=bkgA.reg rungrppha=yes grpmincounts=25 grppibadlow=35 grppibadhigh=1909 binsize=5808
    nuproducts indir=./pro infile=./pro/nu${ids[id]}B01_cl.evt instrument=FPMB steminputs=nu${ids[id]} outdir=./pro srcregionfile=srcB.reg bkgregionfile=bkgB.reg rungrppha=yes grpmincounts=25 grppibadlow=35 grppibadhigh=1909 binsize=5808
    
    /Applications/SAOImage\ DS9.app/Contents/MacOS/ds9 ./pro/nu${ids[id]}A01_cl.evt -scale lin -cmap Heat -regions ./srcA.reg -regions ./bkgA.reg -print destination file -print filename ./pro/nu${ids[id]}A01_img.ps -print -exit
    /Applications/SAOImage\ DS9.app/Contents/MacOS/ds9 ./pro/nu${ids[id]}B01_cl.evt -scale lin -cmap Heat -regions ./srcB.reg -regions ./bkgB.reg -print destination file -print filename ./pro/nu${ids[id]}B01_img.ps -print -exit

    for ff in ./pro/*.ps
    do
	ps2pdf ${ff}
    done
    rm ./pro/*.ps
    cd ${wrk_dir}
done

echo "EOF"
#nupipeline indir=. outdir=./pro steminputs=nu40001014012 srcra=83.86661458333332 srcdec=-69.26975194444444 obsmode=SCIENCE instrument=FPMA exitstage=3 bkgra=83.86661458333332 bkgdec=-69.26975194444444
#nuproducts indir=./pipeline_out instrument=FPMB steminputs=nu10012001002 outdir=./products srcregionfile=source.reg bkgregionfile=background.reg rungrppha=yes grpmincounts=30 grppibadlow=35 grppibadhigh=1909
