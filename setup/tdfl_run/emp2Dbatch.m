%% launch batch of EMP 2D jobs. Use also for single jobs.

clear all; close all;
addpath('/shared/users/prblaes/empmodel/setup/')

loadconstants;

% set defaults
emp2Ddefaults;

% anything you want to change?
inputs.submitjob = 1;

% master directory for set of runs
toprundir = '/shared/users/prblaes/empmodel/runs/rs_comparison/';

inputs.savefields = [0 0 0 0 0 0];

inputs.maxalt = 50e3;
inputs.range = 400e3;
inputs.dr1 = 50;
inputs.dr2 = 50;
inputs.drange = 50;

inputs.doionosphere = 0;
inputs.doioniz = 0;
inputs.doelve = 0;
inputs.dodetach = 0;


% variable for batch of runs. name must match an input!
inputs.I0 = 30e3;
inputs.lightningtype=0;
inputs.sourcealt=6e3;
inputs.taur = 1e-6;
inputs.tauf = 30e-6;

inputs.proberange = (50e3:50e3:inputs.range);
inputs.probealt = 100 * ones(size(inputs.proberange)); %probe 100m off of ground

%run_names = {'tdfl_emp', 'mtll_emp', 'mtle_emp'};
run_names = {'mtll_emp', 'mtle_emp'};

for i=1:length(run_names)
    % change variables as requested
    inputs.runname = run_names{i};
    inputs.runname(strfind(inputs.runname,'+')) = '';
    inputs.rundir = [toprundir inputs.runname];

    if strcmp(inputs.runname, 'tdfl_emp')

        inputs.decaytype = -1;

        tdfl = load('/shared/users/prblaes/TDFL/SimulationResults/RS_TwoTs/Core_R40T20P10_CoreSlope_R0T0P0_Sheath_R4MU10_RSGroundI_Pk30T10P30/FlashDataFile.mat');
        seg_length = 6;
        dt = seg_length/2.998e8;
        Jsv = tdfl.coreIHtry';
        ntsteps = size(Jsv, 2);
        nsegs = size(Jsv, 1);

        t = linspace(0, ntsteps*dt, ntsteps);
        h = linspace(0, nsegs*seg_length, nsegs);

        [tv, hv] = meshgrid(t, h);

        t_interp = 0:inputs.dt:t(end);
        h_interp = 0:inputs.dr1:h(end);

        [tv_interp, hv_interp] = meshgrid(t_interp, h_interp);

        Jsv_interp = interp2(tv, hv, Jsv, tv_interp, hv_interp);

        inputs.source = Jsv_interp;

        figure;
        subplot(1,2,1);
        imagesc(t/1e-6, h/1e3, Jsv/1e3);
        axis xy;
        colorbar

        subplot(1,2,2);
        imagesc(t_interp/1e-6, h_interp/1e3, Jsv_interp/1e3);
        axis xy;
        colorbar

    elseif strcmp(inputs.runname, 'mtll_emp')
        inputs.rsspeed = -0.6*vp;
        inputs.decaytype = 1;
    elseif strcmp(inputs.runname, 'mtle_emp')
        inputs.rsspeed = -0.6*vp;
        inputs.decaytype = 2;
    end

    % launch job
    [in,jobid] = emp2Drun(inputs);
end        
