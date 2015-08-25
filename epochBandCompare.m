% RELIES ON FULL_GMM WHICH DOES NOT EXIST OR MAKE ANY SENSE. SO THIS
% FUNCTION NO LONGER WORKS/DOES ANYTHING.

% combine epoch models but remove one each time, compare to full GMM model.
% this assumes it is being passed a location of epochs and GMMs to
% compare. it will return euclidean distances and mahalanobis distances

function [overall_acc_euc, overall_acc_mah] = epochBandCompare(epoch_directory,gmm_directory,band_removed)

channel_index = (1:1:64);

[epoch_num_files,number_of_epochs,epoch_models,gmm_num_files,gmm_models,gmm_mus,gm_index] = ...
    epochGmmDataImport(epoch_directory,gmm_directory,channel_index,band_removed);

% output matrix
epoch_confusion_euclidean = zeros(epoch_num_files,epoch_num_files);
epoch_confusion_mahal = zeros(epoch_num_files,epoch_num_files);

for k=1:epoch_num_files;
    
    % mahal holder
    mahal_distance = 1000*ones(epoch_num_files,number_of_epochs(k));
    for r=1:gmm_num_files
        mahal_distance(gm_index(r),:) = log10(mahal( gmdistribution(gmm_models{r,1},gmm_models{r,2}),epoch_models{k}));
    end
    [min_value_mahal,min_index_mahal] = min(mahal_distance(gm_index,:));
    
    for n=1:number_of_epochs(k)
        
        euclidean_distance = pdist( [squeeze(epoch_models{k}(n,:));gmm_mus] );
        [min_value,min_index] = min(euclidean_distance(1:epoch_num_files),[],2);
        epoch_confusion_euclidean(k,min_index) = epoch_confusion_euclidean(k,min_index) + 1;
        epoch_confusion_mahal(k,min_index_mahal(n)) = epoch_confusion_mahal(k,min_index_mahal(n)) + 1;
        
    end
    
end
% accuracy
diag_count_euc = diag(epoch_confusion_euclidean);
diag_count_mah = diag(epoch_confusion_mahal);
% output overall accuracy of euclidean matches
overall_acc_euc = mean(diag_count_euc./number_of_epochs);
overall_acc_mah = mean(diag_count_mah./number_of_epochs);

end

% output should be channels versus epochs of average amplitude of remaining
% bands of frequency
function new_epoch = oneEpochModel(epoch,remove_band)
bands = [1,2,3,4,5,6];

bands = bands(bands~=remove_band);

% prune out band
new_epoch = squeeze(epoch.epochs(:,2,bands,:));
% average signal across all bands
new_epoch = squeeze(mean(new_epoch,2))';

end

function [epoch_num_files,number_of_epochs,epoch_models,gmm_num_files,gmm_models,gmm_mus,gm_index] =...
    epochGmmDataImport(epoch_directory,gmm_directory,channel_index,band_removed)

% important epoch.mat files
epoch_file_list = numericFileList(epoch_directory,'epochs_model_');
epoch_num_files = length(epoch_file_list);

% grab epoch variables
number_of_epochs = zeros(epoch_num_files,1);
epoch_models = cell(epoch_num_files,1);

for i=1:epoch_num_files
    temp_load = load([epoch_directory,'/',epoch_file_list{i}]);
    epoch_models{i} = oneEpochModel(temp_load,band_removed);
    number_of_epochs(i) = length(epoch_models{i}(:,1));
end

% import gmm files
gmm_file_list = numericFileList(gmm_directory,'full_gmm_');
gmm_num_files = length(gmm_file_list);
% get the valid list, incase any subjects have too few observations for the
% gmdist to be built
active_models = load( strcat(gmm_directory,'/valid_gm.mat'),'gm_test' );
valid_models = active_models.gm_test;

% handle if a gmm model isn't build for all subjects
gm_index = (1:length(valid_models));
gm_index = gm_index(valid_models==1);

% grab gmm variables
gmm_models = cell(gmm_num_files,2);

for i=1:gmm_num_files
    
    temp_load = load([gmm_directory, '/', gmm_file_list{i}]);
    % store only the band required
    gmm_model_temp = temp_load.full_gmm;
    gmm_models{i,1} = gmm_model_temp.mu(channel_index);
    gmm_models{i,2} = gmm_model_temp.Sigma(channel_index,channel_index);
end

gmm_mus = zeros(gmm_num_files,length(gmm_models{1}));

% notice it is band specific
for i=1:gmm_num_files
    gmm_mus(i,:) = gmm_models{i,1};
end

end