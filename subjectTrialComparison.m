% generate data on distances between one user's trials. internal trial
% distances and external trial distances. the hypothesis is that because
% the trials consist of unique activies they should be separable in some
% manner. this algorithm hopes to determine if separability is possible
% from the peak amplitude values of a given frequency band. distances are
% computed in both euclidean and mahalanobis measurements, despite knowing
% that mahalanobis should provide better results.

% INPUT: SUBJECT_NUMBER should be an integer from within the known pool of
% subjects. BAND should be an integer from withing the known pool of
% frequency bands present in the data. The data in question are the
% pre-built .mat files of epochs and gmms for each subject-trial
% combination.

% OUTPUT: distances returned reflect internal or external to the native
% trial of the specific user. they are two dimenional cells [ type of distance X
% number of trials ] where each cell is loaded with all the distances
% found. naturally external cells have more distances than internal
% distances.

function [internal_distances,external_distances] = subjectTrialComparison(subject_number,band,varargin)

close all;
% feature is set to 2 for peak amplitude value
feature = 2;

% find folders
epoch_folders = folderFinder(pwd,'epoch');
gmm_folders = folderFinder(pwd,'gmm');

% find files for that subject
subject_epochs = fileFinder(epoch_folders,subject_number,feature);
valid_gmms = fileFinder(gmm_folders);
subject_gmms = fileFinder(gmm_folders,subject_number);
epoch_num_files = length(subject_epochs);
[gmm_num_files,~] = size(subject_gmms);
[~,~,number_of_epochs] = cellfun(@size,subject_epochs);
% search for 1 in valid to make sure gmm was built and data isn't poor
gm_models = cellfun(@(x) x(subject_number),valid_gmms);
working_gmm = (1:1:gmm_num_files);
working_gmm = working_gmm(gm_models);

% find all gmms not of that subject

% distances of the subject: organized by trial and distance type as raw
% measurements meant to be used in a histogram (model building)
internal_distances = cell(epoch_num_files,2);
external_distances = cell(epoch_num_files,2);

% euclidean distances
for i=1:epoch_num_files
    % pull only the proper data, skip mu band, and average it
    epoch_test = squeeze(subject_epochs{i}(:,band,:))';
    [other_gmms_mu,~] = buildOthers(band,i,subject_gmms);
    % results contains the distance between each GMM.mu average and the
    % current subject's epoch data (so there will be fourteen one for each
    % trial attempted, hopefully)
    
    % remember to remove this epoch from the average_mu as that would be
    % INTRA-subject distance
    % check to see if the intended epoch is in the working gmm set. if it
    % is, it needs to be removed for the INTER calculation
    [~,e] = find( i == working_gmm );
    % if b comes back being empty, in that the working set does not possess
    % the proper model to be removed, handle it!
    if( isempty(e) )
        internal_distances{i,1} = -1*ones(max(number_of_epochs),length(working_gmm)-1);
        external_distances{i,1} = -1*ones(max(number_of_epochs),1);
        internal_distances{i,2} = -1*ones(max(number_of_epochs),length(working_gmm)-1);
        external_distances{i,2} = -1*ones(max(number_of_epochs),1);
    else
        internal_distances{i,1} = pdist2(epoch_test,subject_gmms{i}{band}.mu);
        external_distances{i,1} = pdist2(epoch_test,other_gmms_mu);
        % mahalanobis distances require the use of a GMM so one must be
        % built for each trial
        internal_distances{i,2} = mahalInternalMeasure(epoch_test,subject_gmms{i}{band});
        external_distances{i,2} = mahalExternalMeasure(epoch_test,subject_gmms,i,band,epoch_num_files);
    end
end

end

function internal_distances = mahalInternalMeasure(epochs,gm)

internal_distances = mahal(gm,epochs);

end

function external_distances = mahalExternalMeasure(epochs,gm,i,band,trials)
true_range = 1:trials;
external_distances = zeros(length(epochs(:,1)),trials-1);
new_trials = true_range(true_range ~= i);
for r=1:trials-1
    external_distances(:,r) = mahal(gm{new_trials(r)}{band},epochs);
end
end

% average mu and sigma builder from gmm models, row are number of bands,
% column is number of models
function [average_mu,average_sigma] = buildOthers(band,subject,working_gmms)
row = length(working_gmms);
row_full = 1:1:row;
row_true = row_full( row_full ~= subject );
% work out intersubject distances between each model ----------------------
average_mu = zeros(length(row_true),length(working_gmms{1}{1}.mu));
[a,b] = size(working_gmms{1}{1}.Sigma);
average_sigma = zeros(a,b,length(row_true));

for r=1:length(row_true)
    d = row_true(r);
    average_mu(r,:) = working_gmms{d}{band}.mu;
    average_sigma(:,:,r) = working_gmms{d}{band}.Sigma;
end
end