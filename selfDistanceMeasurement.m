% again, before I realized I should make static models and save them. this
% would build models each time and them work out self (internal) distances
% measurements. nice idea, but poor execution and eventally folding into
% better functions.

function [target_mahal,target_average_mahal,target_stdev] = selfDistanceMeasurement(target_data,butter_order,butter_low,butter_high,...
    analysis_frame,analysis_shift,block_time,epoch_time)

close all;

if nargin == 1
    fltr.butter_order = 5;
    fltr.butter_low = 0.5;
    fltr.butter_high = 50;
    mf.cc_num = 13;
    % in milliseconds
    mf.analysis_frame = 1000;
    mf.analysis_shift = 500;
    mf.pre_emp_coef = 0.97;
    mf.range = [0.5 80];
    mf.banks = 21;
    mf.liftering_param = 22;
    % in seconds
    mf.block_time = 10;
    mf.epoch_time = 1.5;
else
    fltr.butter_order = butter_order;
    fltr.butter_low = butter_low;
    fltr.butter_high = butter_high;
    mf.cc_num = cc_num;
    % in milliseconds
    mf.analysis_frame = analysis_frame;
    mf.analysis_shift = analysis_shift;
    mf.pre_emp_coef = pre_emp_coef;
    mf.range = range;
    mf.banks = banks;
    mf.liftering_param = liftering_param;
    % in seconds
    mf.block_time = block_time;
    mf.epoch_time = epoch_time;
end

% read in the EDF data and setup filter
[target.labels,target.durations,target.data,target.sample_rate,target.duration] =...
    filePrep(target_data,fltr);

% build matrix of frequency spectrums
target.feature_set = featureFinderSlim(target.data,target.sample_rate,mf.block_time,mf.epoch_time);

% find peak frequencies in each band for each channel in each
target.feature_variables = frequencyPeakFinder(target.feature_set);

% turn everything into a matrix for the file data given
[target.variables_split,target.variables_full] = cellSmash(target.feature_variables);

% build GMM if possible!

channels = length(target.variables_split(1,1,:));
target_observations = length( squeeze(target.feature_variables(1,1,1,:))');
target_variable_count = length( target.feature_variables(:,1,1,1));
gm_test = (target_observations > target_variable_count);

if(  (min(gm_test) ~= 0) )
    target_gmm.mu = zeros(target_variable_count,channels);
    target_gmm.sigma = zeros(target_variable_count,target_variable_count,channels);
    for i=1:channels
        gmm_obj = gmdistribution.fit(squeeze(target.feature_variables(:,2,i,:))',1);
        target_gmm.mu(:,i) = gmm_obj.mu;
        target_gmm.sigma(:,:,i) = gmm_obj.Sigma;
    end
end

% models of all pool data is built! compare to individual epochs from the
% target to find match percantages
target_mahal = zeros(target_observations,channels);
target_average_mahal = zeros(target_observations,1);

for m=1:target_observations
    for i=1:channels
        gmm_obj = gmdistribution(target_gmm.mu(:,i)',target_gmm.sigma(:,:,i));
        target_mahal(:,i) = mahal(gmm_obj,squeeze(target.feature_variables(:,2,i,:))');
    end
end

target_average_mahal = mean(target_mahal,2);
target_stdev = std(target_average_mahal);

end