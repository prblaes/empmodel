close all;
clear all;

vp = 2.998e8;

addpath('../');
addpath('/shared/users/prblaes/vlf_lf/analysis/model_inversion/');

top_rundir = '/shared/users/prblaes/empmodel/runs/rs_comparison/';
runs = {'tdfl_emp', 'mtll_emp', 'mtle_emp'};

probe_dist = 300e3;

colors = [0 0 1; 0 1 0; 1 0 0];

sferic_vec = [];
figure(1);
hold on;
for i=1:3
    rundir = fullfile(top_rundir, runs{i});
    
    conf = get2drunparams(rundir, 'double');
    probes = 50e3:50e3:conf.range;

    probe_ind = find(probes == probe_dist);

    sferics = get_sferics(rundir, conf);
      
    start_ind = floor((probe_dist/vp - 0.01e-3)/conf.dt);
    stop_ind = floor(start_ind + 0.065e-3/conf.dt); %(probe_dist/vp + 0.1e-3)/conf.dt;
    sferic_vec = [sferic_vec; sferics(probe_ind, start_ind:stop_ind)];
    
    sferic = align_sferic(sferic_vec(i, :), [100 300], 200);
    %sferic = align_sferic(sferic);
    plot(sferic, 'Color', colors(i, :), 'LineWidth', 2); 
end
hold off;
grid on;
xlim([0 600]);
legend('TDFL', 'MTLL', 'MTLE');
