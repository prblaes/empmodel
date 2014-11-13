%% launch batch of EMP 2D jobs. Use also for single jobs.

clear all; close all;
addpath('../../setup/');

%limit myself to MAX_JOBS in the pbs job queue
USER = 'prblaes';

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
toprundir = '/shared/users/prblaes/empmodel/runs/source_parameter_estimation/';

%simulation/grid parameters
inputs.exedir = '/shared/users/prblaes/empmodel/emp2/';
inputs.savefields = [0 0 0 0 0 0];
inputs.range = 700e3;
inputs.maxalt = 110e3;
inputs.dr1 = 100;
inputs.dr2 = 100;
inputs.drange = 100;
inputs.dt = 1e-7;

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
inputs.sourcealt = 10e3;
inputs.decaytype = 2;

%sferic probe points
inputs.proberange = [10:10:(round(inputs.range/1e3)-10)]*1e3;
inputs.probealt = 100*ones(size(inputs.proberange));


% variable for batch of runs. name must match an input!
vars.names = {'rsspeed', 'taur', 'tauf', 'I0', 'mtle_scale_height'};
vars.lower = [-3e8, 1e-6, 20e-6, 25e3, 1/6];
vars.upper = [-0.2*3e8, 10e-6, 200e-6, 300e3, 1/2];


%get a unique ID for the first run
d = dir(toprundir);
d = d(arrayfun(@(x) x.name(1), d) ~= '.'); %filter out names starting with .
start_idx = length(d) + 1;

% submit jobs
while 1

    %choose simulation parameters
    for jj=1:length(vars.names)
        param_value = unifrnd(vars.lower(jj), vars.upper(jj)); %draw from uniform distr.
        evalstr = ['inputs.' vars.names{jj} ' = ' num2str(param_value) ';'];
        eval(evalstr);
    end

    
    inputs.runname = sprintf('run%03d', start_idx);
    start_idx = start_idx + 1;

    inputs.rundir = [toprundir inputs.runname];

    %save the inputs to a JSON file, for easy reference
    save_input_to_json(inputs);
    
    % launch job
    [in,jobid] = emp2Drun(inputs);
    
    drawnow;
    
    MAX_JOBS = load('max_jobs.txt');

    %limit myself to MAX_JOBS jobs in the queue
    numjobs = inf;
    while numjobs >= MAX_JOBS
        [~, result] = system(['qstat -u ' USER ' | grep ' USER ' | wc -l']);
        numjobs = str2double(result);
        pause(10);
    end
end
