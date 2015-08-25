% yah, okay. this doesn't work anymore because the full gmm idea was poorly
% thought out. as such there is no data returned in line || gmm_file_list =
% numericFileList(gmm_directory,'full_gmm_'); || so the function cannot
% work anymore.

function [overall_acc_euc, overall_acc_mah] = fullGmmConfusion(epoch_directory,gmm_directory,band,quadrant)

channel_index = channelPruning(quadrant);

% important epoch.mat files
epoch_file_list = numericFileList(epoch_directory,'epochs_model_');
epoch_num_files = length(epoch_file_list);

% grab epoch variables
number_of_epochs = zeros(epoch_num_files,1);
epoch_models = cell(epoch_num_files,1);

for i=1:epoch_num_files
    temp_load = load([epoch_directory,'/',epoch_file_list{i}]);
    epoch_models{i} = squeeze(temp_load.epochs(channel_index,:,band,:));
    number_of_epochs(i) = length(epoch_models{i}(1,1,:));
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

% call function to build confusion matrix
[euclidean_confusion,mahalanobis_confusion] = ...
    singleModelConfusion(epoch_models,gmm_models,gmm_mus,gm_index,number_of_epochs);

% accuracy
diag_count_euc = diag(euclidean_confusion);
diag_count_mah = diag(mahalanobis_confusion);
% output overall accuracy of euclidean matches
overall_acc_euc = mean(diag_count_euc./number_of_epochs);
overall_acc_mah = mean(diag_count_mah./number_of_epochs);

end

% case zero is default. case 1 is forward right. case 2 is forward left.
% case 3 is rear left. case 4 is rear right. case 5 is medial line. case 6
% is coronal line.
function channel_index = channelPruning(quadrant)

channel_index = (1:1:64)';

switch quadrant
    case 1
        remove_index = [];
    case 2
        remove_index = [24,28,29,35,36,37,38,5,6,7,40]';
    case 3
        remove_index = [22,25,26,30,31,32,33,39,1,2,3]';
    case 4
        remove_index = [45,15,16,17,47,48,49,50,56,57,61]';
    case 5
        remove_index = [19,20,21,46,52,53,54,55,59,60,63]';
    case 6
        remove_index = [23,27,34,4,11,18,51,58,62];
    case 7
        remove_index = [41,8,9,10,11,12,13,14,42];
end

channel_index(remove_index) = [];

end