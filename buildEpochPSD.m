% a variation on the built in PSD tool. this does work, but takes a long
% time and produces a gigantic data set in terms of memory. no reason to
% analyze this data at the moment.

function buildEpochPSD(pool_directory)

fltr.butter_order = 5;
fltr.butter_low = 0.5;
fltr.butter_high = 50;
mf.block_time = 10;
mf.epoch_time = 1.5;
target_data = '';

% generate folder to write data into

new_directory = strcat(datestr(date),'_',pool_directory,'_psd');

% verify the directory doesn't exist already
if( exist(new_directory,'dir') == 7 )
    prompt = 'Directoy already exists. Delete and replace?[y/n]';
    response = input(prompt,'s');
    if( response == 'y' || response == 'Y' )
        rmdir(new_directory,'s');
        mkdir(new_directory);
    else
        error('Cannot make new directory. User aborted.');
    end
else
    mkdir(new_directory);
end

% build dataset from subjects in the pool ---------------------------------

% read in the EDF data and setup filter
% sort through pool to setup for file comparison
[pool.data, pool.annotations, pool.durations, pool.duration, pool.sample_rate] =...
    poolSkimmer(pool_directory,target_data,fltr);

for k=1:length(pool.data)
    [pool.split_psd{k},pool.full_psd{k},pool.band_psd{k},pool.frequency{k}] = featureFinderPSD(...
        pool.data{k},pool.sample_rate(k),mf.block_time,mf.epoch_time);
    
    PSD.split = pool.split_psd{k};
    PSD.full = pool.full_psd{k};
    PSD.band = pool.band_psd{k};
    PSD.Freq = pool.frequency{k};
    
    pool_save = strcat(new_directory,'\','PSD_model_',num2str(k),'.mat');
    save(pool_save,'PSD');
end

end