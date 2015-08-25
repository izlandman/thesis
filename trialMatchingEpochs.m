% use the various full models of each trial for a given subject in a given
% band to match back to all of the epochs. in theory each epoch should be
% sorted into the correct trial number (or at least a trial number
% involving the same task).

% looks to be passed in (the target subject for epochs, the desired band
% for analysis, and optionally the gmm subject number to compare the epochs
% against. by default only two inputs are required which allows the gmm to
% be compared against itself to cluster the model and sort matches to
% individual trials.

% returns a double vector 14x1 of accuracy for each trial

function indxx = trialMatchingEpochs(varargin)
subject_number = varargin{1};
band = varargin{2};

if( nargin > 2 )
    model_number = varargin{3};
else
    model_number = subject_number;
end

feature = 2;

gmm_folder = folderFinder(pwd,'GMM');
gmm_folders = folderFinder(pwd,'gmm');
valid_gmms = fileFinderFull(gmm_folders);
gm_models = cellfun(@(x) x(model_number),valid_gmms);

subject_gmms = fileFinder(gmm_folder,model_number,band);

epoch_folders = folderFinder(pwd,'epoch');
subject_epochs = fileFinderFull(epoch_folders,subject_number,feature,band);

% check for bad models
true_index = 1:length(gm_models);
true_index = true_index( gm_models ~= 0 );

% determine trial matching accuracy
indxx = zeros(length(subject_epochs),1);

for t=1:length(true_index)
    indxx(true_index(t)) = sum( (true_index(t) ==...
        true_index(cluster(subject_gmms,subject_epochs{true_index(t),1}'))) ) /...
        length(subject_epochs{true_index(t),1}(1,:));
end

end

function data_files = fileFinder(folder_name,subject_number,band)
        target_name_search = [folder_name{1},'\*t',num2str(subject_number),'b*.*'];
        target_file = dir(target_name_search);
        data_files = importdata( ['.\',folder_name{1},'\',target_file(band).name] );
end