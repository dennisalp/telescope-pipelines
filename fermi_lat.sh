#!/bin/bash -x
# ds9 -bin factor 0.1 0.1 -bin buffersize 4096 -cmap heat evt_flt_??.fits &

cd /Users/${USER}/dat/lat/87a
ls *_PH* > files.txt

# 00:00:00.000 UTC
# 2008-08-05 (from ackermann16)
# 2009-01-01
# 2010-01-01
# 2011-01-01
# 2012-01-01
# 2013-01-01
# 2014-01-01
# 2015-01-01
# 2016-01-01
# 2017-01-01
# 2018-01-01
# 2019-01-01
# 2019-03-18
tbins=(239587201.000 252460801.000 283996802.000 315532802.000 347068802.000 378691203.000 410227203.000 441763203.000 473299204.000 504921604.000 536457605.000 567993605.000 574560005.000)
nt=${#tbins[*]}

#python -c "from astropy.coordinates import SkyCoord; print(SkyCoord('05h35m27.9875s', '-69d16m11.107s', frame='icrs').fk5)"
ra=83.86661274
de=-69.26975717
# From HEASOFT/NED download
# circle(83.86675000,-69.26974200)
scfile=$(ls *_SC*.fits)



################################################################



gtselect infile=@files.txt \
	 outfile=evt.fits \
	 ra=83.86675000 \
	 dec=-69.26974200 \
	 rad=24 \
	 tmin=${tbins[0]} \
	 tmax=${tbins[nt-1]} \
	 emin=100 \
	 emax=300000 \
	 zmax=90 \
	 evclass=128 \
	 evtype=3

gtmktime scfile=${scfile} \
	 filter="(DATA_QUAL>0)&&(LAT_CONFIG==1)" \
	 roicut=no \
	 evfile=evt.fits \
	 outfile=evt_flt.fits

gtbary evfile=evt_flt.fits \
       scfile=${scfile} \
       outfile=evt_flt_bc.fits \
       ra=${ra} \
       dec=${de}

#for ii in $(seq 0 $(($nt-2)))
#do
#    echo ${ii} ${tbins[ii]} ${tbins[ii+1]}
#    gtselect infile=@files.txt \
#	     outfile=evt_$(printf %02d ${ii}).fits \
#	     ra=83.86675000 \
#	     dec=-69.26974200 \
#	     rad=24 \
#	     tmin=${tbins[ii]} \
#	     tmax=${tbins[ii+1]} \
#	     emin=100 \
#	     emax=300000 \
#	     zmax=90 \
#	     evclass=128 \
#	     evtype=3
#
#    gtmktime scfile=${scfile} \
#	     filter="(DATA_QUAL>0)&&(LAT_CONFIG==1)" \
#	     roicut=no \
#	     evfile=evt_$(printf %02d ${ii}).fits \
#	     outfile=evt_flt_$(printf %02d ${ii}).fits
#
#    gtbary evfile=evt_flt_$(printf %02d ${ii}).fits \
#	   scfile=${scfile} \
#	   outfile=evt_flt_bc_$(printf %02d ${ii}).fits \
#	   ra=${ra} \
#	   dec=${de}
#done
