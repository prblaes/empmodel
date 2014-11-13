
function sferics = get_sferics(data_dir, conf)

    c = 2.998e5;
    fs = 1/conf.dt;
    time_left = 0.2e-3/conf.dt;
    time_right = 1.0e-3/conf.dt;

    dtype = 'double';

    fid = fopen(fullfile(data_dir, 'Probe.dat'), 'r');
    nprobes = fread(fid, 1, 'int');
    prober = fread(fid, conf.nprobes, 'int');
    probet = fread(fid, conf.nprobes, 'int');
    Erprobe = fread(fid, [conf.nprobes conf.tsteps], dtype);
    Etprobe = fread(fid, [conf.nprobes conf.tsteps], dtype);
    Epprobe = fread(fid, [conf.nprobes conf.tsteps], dtype);
    Hrprobe = fread(fid, [conf.nprobes conf.tsteps], dtype);
    Htprobe = fread(fid, [conf.nprobes conf.tsteps], dtype);
    Hpprobe = fread(fid, [conf.nprobes conf.tsteps], dtype);
    fclose(fid);

    sferics = Hpprobe;

