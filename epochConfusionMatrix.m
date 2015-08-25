% generate confusion matrix plots, allow quadrants to be removed from the
% analysis

% INPUTS: up to five terms can be passed into the function. term one will
% be a string pointing to the epoch director. term two will be a string
% point to the gmm directory. term three will be the chosen frequency band.
% Only the first THREE are required when the function is called. the fourth
% term specifies the quadrant selection and defaults to zero channels
% removed. term five allows all of the generated data to be saved in the
% present directory. enabling this greatly increases the opperating time of
% the function.

% OUTPUTS: OVERALL_ACC_EUC and OVERALL_ACC_MAH return doubles indicating
% the accurcay of the band/channel specific matching. If VERBOSE is enabled
% five plots will be generated related to the calculations performed. three
% will be confusion matrices and two will show overall match results for
% each distance measurement.

% DEPENDENCIES: there are two local functions after the main function and
% one called function _numericFileList_. _numericFileList_ is important
% because it returns a properly indexed list of files matching the
% sequential nature of the programming not associated with the native
% OS/Matlab's ordering system of files. This caused a lot of headaches
% until it was sorted out.

function [overall_acc_euc, overall_acc_mah] = epochConfusionMatrix(varargin)

epoch_directory = varargin{1};
gmm_directory = varargin{2};
band = varargin{3};

if( nargin == 5)
    verbose_save = 1;
    close all;
else
    verbose_save = 0;
end
if (nargin == 3)
    quadrant = 1;
else
    quadrant = varargin{4};
end

channel_index = channelPruning(quadrant);


% important epoch.mat files
epoch_file_list = numericFileList(epoch_directory,'epochs_model_');
epoch_num_files = length(epoch_file_list);

% output matrix
epoch_confusion_euclidean = zeros(epoch_num_files,epoch_num_files);
epoch_confusion_mahal = zeros(epoch_num_files,epoch_num_files);
epoch_confusion_mahal_2 = epoch_confusion_mahal;

band_names = {'delta','theta','alpha','mu','beta','gamma'};

% grab epoch variables
number_of_epochs = zeros(epoch_num_files,1);
epoch_models = cell(epoch_num_files,1);

for i=1:epoch_num_files
    temp_load = load([epoch_directory,'/',epoch_file_list{i}]);
    epoch_models{i} = squeeze(temp_load.epochs(channel_index,:,band,:));
    number_of_epochs(i) = length(epoch_models{i}(1,1,:));
end


% import gmm files
gmm_file_list = numericFileList(gmm_directory,'gmm_model_');
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
    gmm_model_temp = temp_load.gmm_obj(band);
    gmm_models{i,1} = gmm_model_temp{1,1}.mu(channel_index);
    gmm_models{i,2} = gmm_model_temp{1,1}.Sigma(channel_index,channel_index);
end

gmm_mus = zeros(gmm_num_files,length(gmm_models{1,1}));

% notice it is band specific
for i=1:gmm_num_files
    gmm_mus(i,:) = gmm_models{i,1};
end

% k=1;
% n=1;

for k=1:epoch_num_files;
    
    % mahal holder
    mahal_distance = 1000*ones(epoch_num_files,number_of_epochs(k));
    for r=1:gmm_num_files
        mahal_distance(gm_index(r),:) = log10(mahal( gmdistribution(gmm_models{r,1},gmm_models{r,2}),squeeze(epoch_models{k}(:,2,:))'));
    end
    [min_value_mahal,min_index_mahal] = min(mahal_distance(gm_index,:));
    comp_matrix = repmat(min_value_mahal,epoch_num_files,1);
    [min_value_mahal_2,min_index_mahal_2] = min(...
        reshape(mahal_distance(mahal_distance>comp_matrix),epoch_num_files-1,number_of_epochs(k)) );
    
    for n=1:number_of_epochs(k)
        
        euclidean_distance = pdist( [squeeze(epoch_models{k}(:,2,n))';gmm_mus] );
        [min_value,min_index] = min(euclidean_distance(1:epoch_num_files),[],2);
        epoch_confusion_euclidean(k,min_index) = epoch_confusion_euclidean(k,min_index) + 1;
        epoch_confusion_mahal(k,min_index_mahal(n)) = epoch_confusion_mahal(k,min_index_mahal(n)) + 1;
        epoch_confusion_mahal_2(k,min_index_mahal_2(n)) = epoch_confusion_mahal_2(k,min_index_mahal_2(n)) + 1;
        
        % call mahal one distribution at a time, storing results in an
        % array
%         for r=1:epoch_num_files
%             mahal_distance(r) = log10(mahal(gmm_models{r},squeeze(epoch_models{k}(:,2,band,n))'));
%         end
%         [min_value,min_index] = min(mahal_distance);
%         epoch_confusion_mahal(k,min_index) = epoch_confusion_mahal(k,min_index) + 1;
%         [min_value,min_index] = min( mahal_distance(mahal_distance>min_value) );
%         epoch_confusion_mahal_2(k,min_index) = epoch_confusion_mahal_2(k,min_index) + 1;
        
    end
    
end
% accuracy
diag_count_euc = diag(epoch_confusion_euclidean);
diag_count_mah = diag(epoch_confusion_mahal);
% output overall accuracy of euclidean matches
overall_acc_euc = mean(diag_count_euc./number_of_epochs);
overall_acc_mah = mean(diag_count_mah./number_of_epochs);

% optional ---------------------------------------------------------------

if( verbose_save == 1 )
    axis_max = max(number_of_epochs)/3;
    % k is for figure saving index
    k = 0;
    
    % y axis comes from k, which is the KNOWN epoch
    % x axis comes from min_index, which is the FOUND epoch
    figure('Name','Euclidean Confusion Matrix','NumberTitle','off');
    surface(epoch_confusion_euclidean);
    title(strcat( band_names{band}, ' wavelengths') );
    ylabel(' True Subject '); xlim([0 epoch_num_files]);
    xlabel(' Matched Subject '); ylim([0 epoch_num_files]);
    caxis([ 0 axis_max ]);
    colorbar
    h = gcf;
    k = figureSaver(band_names{band},quadrant,h,k);
    
    % repeat for mahal
    figure('Name','Mahalanobis Confusion Matrix','NumberTitle','off');
    surface(epoch_confusion_mahal);
    title(strcat( band_names{band}, ' wavelengths') );
    ylabel(' True Subject '); xlim([0 epoch_num_files]);
    xlabel(' Matched Subject '); ylim([0 epoch_num_files]);
    caxis([ 0 axis_max ]);
    colorbar
    h = gcf;
    k = figureSaver(band_names{band},quadrant,h,k);
    
    figure('Name','Mahalanosbis Confusion Matrix (second lowest distance)','NumberTitle','off');
    surface(epoch_confusion_mahal_2);
    title(strcat( band_names{band}, ' wavelengths') );
    ylabel(' True Subject '); xlim([0 epoch_num_files]);
    xlabel(' Matched Subject '); ylim([0 epoch_num_files]);
    caxis([ 0 axis_max ]);
    colorbar
    h = gcf;
    k = figureSaver(band_names{band},quadrant,h,k);
    
    % what sort of error?
    
    figure('Name','Euclidean Error','NumberTitle','off');
    subplot(211);bar(diag_count_euc);grid on;
    title('total matches per subject');
    xlim([0 epoch_num_files]);
    subplot(212);bar(diag_count_euc./number_of_epochs);grid on;
    title('percentage of matches to true epochs');
    xlim([0 epoch_num_files]);
    h = gcf;
    k = figureSaver(band_names{band},quadrant,h,k);
    
    % mahal error
    figure('Name','Mahal Error','NumberTitle','off');
    subplot(211);bar(diag_count_mah);grid on;
    title('total matches per subject');
    xlim([0 epoch_num_files]);
    subplot(212);bar(diag_count_mah./number_of_epochs);grid on;
    title('percentage of matches to true epochs');
    xlim([0 epoch_num_files]);
    h = gcf;
    k = figureSaver(band_names{band},quadrant,h,k);
    
end

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

function k = figureSaver(name,quadrant,h,k)

file_name = strcat( name,'_q',num2str(quadrant),'_', num2str(k) );
% saveas for 2012a savefig for 2014a?
saveas(h,file_name);
k = k +1;
end