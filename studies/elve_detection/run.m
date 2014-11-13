%% launch batch of EMP 2D jobs. Use also for single jobs.

clear all; close all;
addpath('../../setup/');

%limit myself to MAX_JOBS in the pbs job queue
USER = 'prblaes';
MAX_JOBS = 8;

loadconstants;

%load json library
addpath('/shared/users/prblaes/software/jsonlab/');

% set defaults
emp2Ddefaults;

% anything you want to change?
inputs.submitjob = 1;
inputs.cluster = 'batch';
inputs.numnodes = '8';

inputs.submission_script = [mfilename('fullpath') '.m'];

% master directory for set of runs
toprundir = '/shared/users/prblaes/empmodel/runs/elve_detection/';

%simulation/grid parameters
inputs.exedir = '/shared/users/prblaes/empmodel/emp2/';
inputs.savefields = [0 0 0 0 0 0];

%ionosphere parameters
inputs.doionosphere = 1;
inputs.doioniz = 1;
inputs.doelve = 1;
inputs.dodetach = 1;

%elve camera view
inputs.camdist = 500e3;

%lightning source parameters
inputs.taur = 5e-6;
inputs.tauf = 50e-5;
inputs.sourcealt = 8e3;


% variable for batch of runs. name must match an input!
I0_vec = (25:50:225) * 1e3;
rsspeed_vec = -1*(1/3:1/3:1) * vp;

% submit jobs
run_index = 1;

for m = 1:length(I0_vec),
    for n = 1:length(rsspeed_vec)
    
        % change variables as requested
        eval(sprintf('inputs.I0 = %f;', I0_vec(m)));
        eval(sprintf('inputs.rsspeed = %f;', rsspeed_vec(n)));
    
        
        inputs.runname = sprintf('run%03d', run_index);
        run_index = run_index + 1;
        inputs.rundir = [toprundir inputs.runname];

        %save the inputs to a JSON file, for easy reference
        save_input_to_json(inputs);
        
        % launch job
        [in,jobid] = emp2Drun(inputs);
        
        drawnow;

        %limit myself to MAX_JOBS jobs in the queue
        numjobs = inf;
        while numjobs >= MAX_JOBS
            [~, result] = system(['qstat -u ' USER ' | grep ' USER ' | wc -l']);
            numjobs = str2double(result);
            pause(10);
        end
    end
end
