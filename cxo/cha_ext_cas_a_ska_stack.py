'''
2019-08-22, Dennis Alp, dalp@kth.se

Look at images in narrow energy intervals of Cas A to search for Sc Ka emission from 44Ti.
'''

from __future__ import division, print_function
import os
from pdb import set_trace as db
import sys
from glob import glob
from datetime import date
from tqdm import tqdm

import numpy as np
import matplotlib.pyplot as plt
from astropy.coordinates import SkyCoord
from astropy import wcs
from astropy.io import fits
from astropy import units
from scipy.ndimage import gaussian_filter

#For LaTeX style font in plots
plt.rc('font', **{'family': 'serif', 'serif': ['Computer Modern']})
plt.rc('text', usetex=True)

# Constants, cgs
cc = 2.99792458e10 # cm s-1
GG = 6.67259e-8 # cm3 g-1 s-2
hh = 6.6260755e-27 # erg s
DD = 51.2 # kpc
pc = 3.086e18 # cm
kpc = 3.086e21 # cm
mpc = 3.086e24 # cm
kev2erg = 1.60218e-9 # erg keV-1
Msun = 1.989e33 # g
Lsun = 3.828e33 # erg s-1
Rsun = 6.957e10 # cm
Tsun = 5772 # K
uu = 1.660539040e-24 # g
SBc = 5.670367e-5 # erg cm-2 K-4 s-1
kB = 1.38064852e-16 # erg K-1




################################################################
def get_wcs(ff):
    raref = fits.getval(ff,'TCRVL11', 1)
    radel = fits.getval(ff,'TCDLT11', 1)
    rapix = fits.getval(ff,'TCRPX11', 1)
    deref = fits.getval(ff,'TCRVL12', 1)
    dedel = fits.getval(ff,'TCDLT12', 1)
    depix = fits.getval(ff,'TCRPX12', 1)

    coords = wcs.WCS(fits.open(ff)[0].header)
    coords.wcs.crpix = [fov//2, fov//2]
    coords.wcs.cdelt = np.array([scale*radel, scale*dedel])
    coords.wcs.crval = [sc.ra.value, sc.dec.value]
    coords.wcs.ctype = ["RA---TAN", "DEC--TAN"]
    coords.wcs.set_pv([(2, 1, 45.0)])
    
    pixcrd = np.array([[0, 0], [24, 38], [45, 98]], dtype=np.float64)
    world = coords.wcs_pix2world(pixcrd, 0)
    pixcrd2 = coords.wcs_world2pix(world, 0)
    assert np.max(np.abs(pixcrd - pixcrd2)) < 1e-6
    return coords
    
# Utility for making fits image out of a numpy array
def mk_fits(image, output, coords):
    hdu = fits.PrimaryHDU(image, header=coords.to_header())
    hdulist = fits.HDUList([hdu])
    hdulist.writeto(output, clobber=True)
    hdulist.close()

def coords2pix(ff, ra, de):
    raref = fits.getval(ff,'TCRVL11', 1)
    radel = fits.getval(ff,'TCDLT11', 1)
    rapix = fits.getval(ff,'TCRPX11', 1)
    deref = fits.getval(ff,'TCRVL12', 1)
    dedel = fits.getval(ff,'TCDLT12', 1)
    depix = fits.getval(ff,'TCRPX12', 1)
    x0 = (ra-raref)*np.cos(np.deg2rad(de))/radel+rapix
    y0 = (de-deref)/dedel+depix
    return x0, y0

#########
files = sorted(glob('/Users/silver/dat/cxo/cas/*/repro/acisf?????_repro_evt2_03_10_clean.fits'))
img_path = '/Users/silver/box/phd/pro/cas/ska/img/'
scale = 1
zscale=32
ns = 512
sc = SkyCoord('23h23m27.542s', '+58d48m54.41s', frame='icrs') # Cas A
sig = 5

# Allocations
fov = 1024
bin_cou = [fov*scale, fov*scale]
bin_lim = [[-fov//2*scale, fov//2*scale], [-fov//2*scale, fov//2*scale]]
img = [np.zeros(bin_cou), np.zeros(bin_cou), np.zeros(bin_cou), np.zeros(bin_cou)]
exp_tim = 0
my_wcs = get_wcs(files[0])
sbins = np.linspace(0, 10000, ns+1)
spec = np.zeros(ns)

# Zoomed
zfov = fov//zscale
zbin_cou = [zfov, zfov]
zbin_lim = [[-zfov//2*zscale, zfov//2*zscale], [-zfov//2*zscale, zfov//2*zscale]]
zimg = [np.zeros(zbin_cou), np.zeros(zbin_cou), np.zeros(zbin_cou), np.zeros(zbin_cou)]

################################################################
# Main
for ii, ff in enumerate(tqdm(files)):
    dat = fits.open(ff)[1].data
#    print(dat.dtype.names)
    xx = dat['x'].astype('float64')
    yy = dat['y'].astype('float64')
    ee = dat['energy'].astype('float64')
    
    x0, y0 = coords2pix(ff, sc.ra.degree, sc.dec.degree)
    xx = xx-x0
    yy = yy-y0
    exp_tim += fits.getval(ff, 'EXPOSURE', 1)
    
    # Make Images
    efilter = (ee > 3500) & (ee < 3750)
    tmp, xedges, yedges = np.histogram2d(xx[efilter], yy[efilter], bins=bin_cou, range=bin_lim)
#    mk_fits(tmp.T, img_path + ff.split('/')[-1].split('.')[0] + '_3p50-3p75.fits', my_wcs)
    img[0] = img[0] + tmp
    tmp, xedges, yedges = np.histogram2d(xx[efilter], yy[efilter], bins=zbin_cou, range=zbin_lim)
    zimg[0] = zimg[0] + tmp

    efilter = (ee > 3750) & (ee < 4000)
    tmp, xedges, yedges = np.histogram2d(xx[efilter], yy[efilter], bins=bin_cou, range=bin_lim)
#    mk_fits(tmp.T, img_path + ff.split('/')[-1].split('.')[0] + '_3p75-4p00.fits', my_wcs)
    img[1] = img[1] + tmp
    tmp, xedges, yedges = np.histogram2d(xx[efilter], yy[efilter], bins=zbin_cou, range=zbin_lim)
    zimg[1] = zimg[1] + tmp

    efilter = (ee > 4050) & (ee < 4150)
    tmp, xedges, yedges = np.histogram2d(xx[efilter], yy[efilter], bins=bin_cou, range=bin_lim)
#    mk_fits(tmp.T, img_path + ff.split('/')[-1].split('.')[0] + '_4p05-4p15.fits', my_wcs)
    img[2] = img[2] + tmp
    tmp, xedges, yedges = np.histogram2d(xx[efilter], yy[efilter], bins=zbin_cou, range=zbin_lim)
    zimg[2] = zimg[2] + tmp

    efilter = (ee > 4200) & (ee < 5000)
    tmp, xedges, yedges = np.histogram2d(xx[efilter], yy[efilter], bins=bin_cou, range=bin_lim)
#    mk_fits(tmp.T, img_path + ff.split('/')[-1].split('.')[0] + '_4p20-5p00.fits', my_wcs)
    img[3] = img[3] + tmp
    tmp, xedges, yedges = np.histogram2d(xx[efilter], yy[efilter], bins=zbin_cou, range=zbin_lim)
    zimg[3] = zimg[3] + tmp

    # Make spectrum
    tmp, _ = np.histogram(ee, bins=sbins)
    spec = spec + tmp
    


################################################################
# Image
print('Exposure time:', exp_tim)

plt.imsave(img_path + '3p50-3p75.png', gaussian_filter(img[0], sigma=sig).T, origin='lower')
mk_fits(img[0].T, img_path + '3p50-3p75.fits', my_wcs)

plt.imsave(img_path + '3p75-4p00.png', gaussian_filter(img[1], sigma=sig).T, origin='lower')
mk_fits(img[1].T, img_path + '3p75-4p00.fits', my_wcs)

plt.imsave(img_path + '4p05-4p15.png', gaussian_filter(img[2], sigma=sig).T, origin='lower')
mk_fits(img[2].T, img_path + '4p05-4p15.fits', my_wcs)

plt.imsave(img_path + '4p20-5p00.png', gaussian_filter(img[3], sigma=sig).T, origin='lower')
mk_fits(img[3].T, img_path + '4p20-5p00.fits', my_wcs)

plt.imsave(img_path + '4p05-4p15_minus_4p20-5p00.png', gaussian_filter(img[2]-np.sum(img[2])/np.sum(img[3])*img[3], sigma=sig).T, origin='lower')
mk_fits(img[2].T-np.sum(img[2])/np.sum(img[3])*img[3].T, img_path + '4p05-4p15_minus_4p20-5p00.fits', my_wcs)

# Smooth before taking ratios
sig=10
tmp=gaussian_filter(img[2], sigma=sig).T/(gaussian_filter(img[0], sigma=sig).T+gaussian_filter(img[3], sigma=sig).T)
plt.imsave(img_path + '4p05-4p15_over_4p20-5p00.png', tmp, origin='lower')
mk_fits(tmp, img_path + '4p05-4p15_over_4p20-5p00.fits', my_wcs)

# Simple two-bin fit and map the excess
def power(xx, aa, cc):
    return aa*xx**cc

xx = np.array([3.6, 4.5])
exc = np.zeros(zimg[0].shape)
for ii, row in enumerate(zimg[3]):
    print(ii)
    for jj, col in enumerate(row):
        yy = np.array([zimg[0][ii,jj]/0.25, zimg[3][ii,jj]/0.8])
        if yy.min() < 1:
            exc[ii,jj] = 1.
            continue
        cc = np.log(yy[0]/yy[1])/np.log(xx[0]/xx[1])
        aa = yy[0]*xx[0]**-cc
        ff = power(4.1, aa, cc)
        exc[ii,jj] = (zimg[2][ii,jj]/0.1)/ff
        db()

plt.imsave(img_path + 'two-bin_fit_excess.png', exc, origin='lower')
zwcs = my_wcs.copy()
zwcs.wcs.cdelt = zwcs.wcs.cdelt*zscale
mk_fits(exc, img_path + 'two-bin_fit_excess.fits', zwcs)
db()

#ds9 ../img/?p??-?p??.fits -scale log -cmap Heat &
