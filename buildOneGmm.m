% given the individual parameters of each subject's trials combine them
% into one GMM so matlab can use that model to cluster data for us!

% since the function to build/save each GMM for each subject in each trial
% does so by saving the gmm in separate bands per trial per subject, these
% need to be rebuilt to allow for each subject to have all trial variations
% for a given band in one model. this allows the full model, of one user
% covering all trials in a given band (so 14 components in the model) to be
% used to find the accuracy in matching to all of the epochs of that
% subject or against other subjects.

% INPUT: this must be run from main data folder as the program searches for
% the correct subfolders to extract the specified SUBJECT_NUMBER user's
% data files for a give BAND. to build a model for a full subject this must
% be run once for each BAND of interest.

% OUTPUT: the returned data is present as a matlab gm object

% DEPENDENCIES: again, this requires access to the main data folder but
% also to the function _fileFinderFull_ and _folderFinder_ which are
% separate functions. these other functions are often called by other
% programs.

function full = buildOneGmm(subject_number,band)

gmm_folders = folderFinder(pwd,'gmm');
valid_gmms = fileFinderFull(gmm_folders);
gm_models = cellfun(@(x) x(subject_number),valid_gmms);

% this attempts to address issues when not enough data points are present
% so a GM model cannot be made and this could not be added to the full
% model attempting to be built at this time.

indexed = 1:length(gm_models);
indexed = indexed(gm_models);

subject_gmms = fileFinderFull(gmm_folders(1,indexed),subject_number);
[~,num_features] = size(subject_gmms{1,1}{1}.mu);

% search for 1 in valid to make sure gmm was built and data isn't poor

trial_mu = zeros(num_features,length(indexed));
trial_sigma = zeros(num_features,num_features,length(indexed));

for i=1:length(indexed)
    trial_mu(:,i) = subject_gmms{i}{band}.mu;
    trial_sigma(:,:,i) = subject_gmms{i}{band}.Sigma;
end

p = ones(1,length(indexed))/length(indexed);

full = gmdistribution(trial_mu',trial_sigma,p);

end
