'''
This script reads a bunch of EMP runs and plots the integrated elve brightness vs. pkI and v_rs
'''

from __future__ import division
import json
import glob
import os
import numpy as np
import sys
import matplotlib.pyplot as plt

vp = 2.998e8

RUN_DIR = '/shared/users/prblaes/empmodel/runs/elve_detection/'


def get_elve(run_dir, inputs):

    elve = dict()

    maxdist = np.sqrt(inputs['range']**2 + inputs['maxalt']**2)
    tsteps = np.floor(1.1*maxdist / vp / inputs['dt'])

    with open(os.path.join(run_dir, 'camera.dat'), 'rb') as fid:
        camtype = np.fromfile(fid, count=1, dtype=np.int32)
        totalpixels = np.fromfile(fid, count=1, dtype=np.int32)
        az = np.fromfile(fid, count=totalpixels, dtype=np.double)
        el = np.fromfile(fid, count=totalpixels, dtype=np.double)
    
    elvesteps = inputs['elvesteps']
    numaz = np.unique(az).shape[0]
    numel = np.unique(el).shape[0]
    imsize = totalpixels

    eti = (inputs['camdist'] - inputs['range']) / vp
    etf = (inputs['camdist'] + inputs['range']) / vp + tsteps*inputs['dt']
    elvedt = (etf - eti) / (inputs['elvesteps'] - 1)

    with open(os.path.join(run_dir, 'elve.dat'), 'rb') as fid:
        elve['N21P'] = np.fromfile(fid, count=imsize*inputs['elvesteps'], dtype=np.float64) / elvedt 
        elve['N22P'] = np.fromfile(fid, count=imsize*inputs['elvesteps'], dtype=np.float64) / elvedt 
        elve['N2P1N'] = np.fromfile(fid, count=imsize*inputs['elvesteps'], dtype=np.float64) / elvedt 
        elve['N2PM'] = np.fromfile(fid, count=imsize*inputs['elvesteps'], dtype=np.float64) / elvedt 
        elve['O2P1N'] = np.fromfile(fid, count=imsize*inputs['elvesteps'], dtype=np.float64) / elvedt 
       
    elve['N21P'][np.isnan(elve['N21P'])] = 0
    elve['N22P'][np.isnan(elve['N22P'])] = 0
    elve['N2P1N'][np.isnan(elve['N2P1N'])] = 0
    elve['N2PM'][np.isnan(elve['N2PM'])] = 0
    elve['O2P1N'][np.isnan(elve['O2P1N'])] = 0

    elve['N21P'] = np.mean(np.transpose(np.reshape(elve['N21P'], (numaz, numel, elvesteps)), axes=[0, 1, 2]), axis=2).T
    elve['N22P'] = np.mean(np.transpose(np.reshape(elve['N22P'], (numaz, numel, elvesteps)), axes=[0, 1, 2]), axis=2).T
    elve['N2P1N'] = np.mean(np.transpose(np.reshape(elve['N2P1N'], (numaz, numel, elvesteps)), axes=[0, 1, 2]), axis=2).T
    elve['N2PM'] = np.mean(np.transpose(np.reshape(elve['N2PM'], (numaz, numel, elvesteps)), axes=[0, 1, 2]) , axis=2).T
    elve['O2P1N'] = np.mean(np.transpose(np.reshape(elve['O2P1N'], (numaz, numel, elvesteps)), axes=[0, 1, 2]), axis=2).T

    elve['az'] = az
    elve['el'] = el

    return elve
    
    
    

if __name__ == '__main__':
    from ipdb import launch_ipdb_on_exception
    
    plt.ion()
    with launch_ipdb_on_exception():
        pkIs = []
        rsspeeds = []
        elve_intensities = []

        #get list of runs in the run directory
        run_list = glob.glob(os.path.join(RUN_DIR, '*'))
        
        for i, run in enumerate(run_list):

            sys.stdout.write('\rReading: %d/%d'%(i+1, len(run_list)))
            sys.stdout.flush()

            #read the inputs from this run
            with open(os.path.join(run, 'inputs.json'), 'r') as fid:
                inputs = json.load(fid)

                elve = get_elve(run, inputs)
                
                pkIs.append(inputs['I0']/1e3)
                rsspeeds.append(-1*inputs['rsspeed']/vp)
                elve_intensities.append(np.mean(elve['N21P']))

        print('')

        cm = plt.cm.get_cmap('jet') 
        plt.figure(facecolor='white')
        plt.scatter(pkIs, rsspeeds, c=np.log(elve_intensities), lw=0, s=500, cmap=cm)
        plt.xlabel('peak current, kA', fontsize=14)
        plt.ylabel('return stroke speed, $c$', fontsize=14)
        plt.title('Elve $\mathrm{N}_2\,1\mathrm{P}$ Brightness')
        cbar = plt.colorbar()
        cbar.set_label('log(kR)')
        plt.savefig('figures/brightness_vs_source_params.eps', format='eps')
