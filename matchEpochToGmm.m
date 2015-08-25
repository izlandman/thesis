% allow an epoch to be matched to a GMM based upon band comparison


% INPUT: the EPOCH is an individual epoch model, not an individual epoch,
% BANDS is a vector of the chosen frequency bands to compare in the search.

% OUTPUT: EUC_DETAILS provide the assumed match and accuracy for the
% euclidean calculation. MAH_DETAILS provide the assumed match and accuracy
% for the mahalanobis distance calculation.

% DEPENDENCIES: _fileFinderFull_ and _folderFinder_ are called so they need
% to be in the Matlab path. _findSingleFile_ is a local function native to
% only this file.

function [euc_details,mah_details] = matchEpochToGmm(epoch,bands)

close all;
% feature is set to 2 for peak amplitude value
feature = 2;
epoch_data = squeeze(epoch(:,feature,:,:));

% gather gmm folders
gmm_folders = folderFinder(pwd,'gmm');
valid_gmms = fileFinderFull(gmm_folders);

% for each gmm folder compare this single epoch sample to all valid gmm
for i=1:length(gmm_folders)
    num_models = length(valid_gmms{i});
    working_models = (1:1:num_models);
    working_models = working_models( valid_gmms{i} == 1 );
    for r=1:length(working_models)
        gmm_data = findSingleFile(gmm_folders{i},working_models(r));
        distances(i,working_models(r),:) = epochDistanceMeasure(epoch_data,gmm_data,bands);
    end
    distances(i,( valid_gmms{i} == 0 ),:) = NaN;
end

% figure('name','Euclidean Distance','NumberTitle','off');
% plotResults(distances(:,:,1),gmm_folders);
% figure('name','Mahalanobis Distance','NumberTitle','off');
% plotResults(distances(:,:,2),gmm_folders);

[~,e_ind] = min(distances(:,:,1),[],2);
[~,m_ind] = min(distances(:,:,2),[],2);

euclidean_match = mode(e_ind);
euclidean_acc = sum(euclidean_match==e_ind)/length(gmm_folders);

euc_details = [euclidean_match,euclidean_acc]'; 

mahalanobis_match = mode(m_ind);
mahalanobis_acc = sum(mahalanobis_match==m_ind)/length(gmm_folders);

mah_details = [mahalanobis_match,mahalanobis_acc]';

end

% find and return single file, gmm
function data_file = findSingleFile(folder_name,number)
target_name_search = [folder_name,'\*el_',num2str(number),'.*'];
target_file = dir(target_name_search);
data_file = load( ['.\',folder_name,'\',target_file.name] );
data_file = data_file.gmm_obj;
end