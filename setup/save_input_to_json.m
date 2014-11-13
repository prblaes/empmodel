function save_input_to_json(inputs)

    if ~exist(inputs.rundir,'dir'),
        mkdir(inputs.rundir);
    end
    
    savejson('', inputs, fullfile(inputs.rundir, 'inputs.json'));
end
