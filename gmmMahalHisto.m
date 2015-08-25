% THIS IS AN OLDER VERSION OF A CURRENTLY WORKING FUNCTION. THIS FUNCTION
% NO LONGER FULLY WORKS. _modelHistograms_ IS THE NEW WORKING FUNCTION.

% point this to a folder with the gmm distributions saved as mat files

% updated 10april2015 for the latest data sets.

% INPUTS: GMM_DIRECTORY and EPOCH_DIRECTORY should containg matching
% subject/trial data and be strings. BAND is a single integer value for the
% desired frequency band.

% OUTPUTS: 

function [cluster_mahal_epoch_distance,intersubject_distance_m,full_pdist_epoch_distance]...
    = gmmMahalHisto(gmm_directory,epoch_directory,band)

close all;

% build gmm file list, cells/strings
gmm_file_list = numericFileList(gmm_directory,'gmm_model_');
gmm_num_files = length(gmm_file_list);
epoch_file_list = numericFileList(epoch_directory,'epochs_model_');
epoch_num_files = length(epoch_file_list);

% pull everything into the workspace --------------------------------------

% grab gmm variables
for i=1:gmm_num_files
    gmm_temp = load(gmm_file_list{i});
    gmm_models(i) = gmm_temp.gmm_obj(band);
end

% grab epoch variables
number_of_epochs = zeros(epoch_num_files,1);
for i=1:epoch_num_files
    epoch_models(i) = load(epoch_file_list{i});
    number_of_epochs(i) = length(epoch_models(i).epochs(1,1,1,:));
end

% work out intersubject distances between each model ----------------------
mC = size(gmm_models{1,1}.mu);
average_mu = zeros(gmm_num_files,mC(2));
[sR,sC] = size(gmm_models{1,1}.Sigma);
average_sigma = zeros(sR,sC,gmm_num_files);

for r=1:gmm_num_files
    average_mu(r,:) = average_mu(r,:) + gmm_models{r}.mu;
    average_sigma(:,:,r) = squeeze(average_sigma(:,:,r)) + gmm_models{r}.Sigma;
end

average_mu = average_mu ./ column;
average_sigma = average_sigma ./ column;
intersubject_distance = zeros(gmm_num_files,gmm_num_files);
intersubject_distance_m = zeros(gmm_num_files,gmm_num_files);
intersubject_epoch_distance = zeros(gmm_num_files,gmm_num_files,max(number_of_epochs));

for c=1:gmm_num_files
    for r=(c+1):gmm_num_files
        % distance from all means to all other means
        intersubject_distance(r,c) = pdist( [average_mu(r,:);average_mu(c,:)] );
        intersubject_distance_m(r,c) = mahal( gmdistribution(average_mu(r,:),...
            squeeze(average_sigma(r,:,:))),average_mu(c,:) );
        % compare epochs of c to all other clusters
        band_average_epoch = squeeze(mean(epoch_models(r).epochs,3));
        pdist_result = pdist( [average_mu(c,:);...
            squeeze(band_average_epoch(:,2,:))' ]);
        intersubject_epoch_distance(r,c,1:number_of_epochs(r)) = pdist_result(1:number_of_epochs(r));
    end
end

% develop model of epoch distance to native cluster -----------------------
intrasubject_distance = zeros(gmm_num_files,gmm_num_files,max(number_of_epochs));
intrasubject_distance_m = zeros(gmm_num_files,gmm_num_files,max(number_of_epochs));


for r=1:row
    % average the bands together
    band_average_epoch = squeeze(mean(epoch_models(r).epochs,3));
    distance = pdist( [average_mu(r,:); squeeze(band_average_epoch(:,2,:))' ] );
    intrasubject_distance(r,1:number_of_epochs(r)) = distance(1:number_of_epochs(r));
    intrasubject_distance_m(r,1:number_of_epochs(r)) = mahal(...
        gmdistribution(average_mu(r,:),squeeze(average_sigma(r,:,:))),...
        squeeze(band_average_epoch(:,2,:))');
end

% histogram of intersubject epoch distances, euclidean
intersubject_epoch_hist_data = intersubject_epoch_distance( intersubject_epoch_distance ~= 0 );
figure(42); subplot(3,1,3);grid on;
hist(intersubject_epoch_hist_data,0:1:125);xlim([0 125]);
ylabel('number of links');
thisLabel = strcat('Distance between groups [mean: ', num2str(mean(intersubject_epoch_hist_data)),' ]');
xlabel(thisLabel);
title('Distance Between Epoch and Non-Familial GMM Clusters');

% histogram of intrasubject model distance, euclidean
intrasubject_hist_data = intrasubject_distance( intrasubject_distance ~= 0 );
figure(42); subplot(3,1,1);grid on;
hist(intrasubject_hist_data,0:1:125);xlim([0 125]);
ylabel('number of links');
thisLabel = strcat('Distance between groups [mean: ', num2str(mean(intrasubject_hist_data)),' ]');
xlabel(thisLabel);
title('Distance Between Epoch and Familial GMM Cluster');

% histogram of intersubject model distance, euclidean
intersubject_hist_data = intersubject_distance( intersubject_distance ~= 0 );
figure(42);subplot(3,1,2);grid on;
hist(intersubject_hist_data,0:1:125);xlim([0 125]);
ylabel('number of links');
thatLabel = strcat('Distance between groups [mean: ', num2str(mean(intersubject_hist_data)),' ]');
xlabel(thatLabel);
title('Distance Between GMM Cluster Centers');

% histogram of intrasubject and intersubject, mahal
intrasubject_hist_data_m = intrasubject_distance_m( intrasubject_distance_m ~= 0 );
intersubject_hist_data_m = intersubject_distance_m( intersubject_distance_m ~= 0 );
x = 0:1:125;
y1 = intrasubject_hist_data_m;
[n1,x] = hist(y1,x);
y2 = intersubject_hist_data_m;
[n2,x] = hist(y2,x);


n1 = n1./sum(n1);
n2 = n2./sum(n2);

figure(57);
bar(x,[n1;n2]','grouped');grid on;
axis([ 0 126 0 max(max([n1;n2]))*1.1]);
title('Histogram of Separable Distance Measurements');
xlabel(' Distance between groups ');
ylabel(' Percentage of samples ');
legend('Intra Cluster Epoch Distance','Inter Cluster Distance','Location','NorthWest')

% on the same figure?
x = 0:1:125;
y1 = intrasubject_hist_data;
[n1,x] = hist(y1,x);
y2 = intersubject_hist_data;
[n2,x] = hist(y2,x);
y3 = intersubject_epoch_hist_data;
[n3,x] = hist(y3,x);

n1 = n1./sum(n1);
n2 = n2./sum(n2);
n3 = n3./sum(n3);

figure(49);
bar(x,[n1;n2]','grouped');grid on;
axis([ 0 126 0 max(max([n1;n2;n3]))*1.1]);
title('Histogram of Separable Distance Measurements');
xlabel(' Distance between groups ');
ylabel(' Percentage of samples ');
legend('Intra Cluster Epoch Distance','Inter Cluster Distance','Location','NorthEast')

% run each epoch in each band against everything of a similar type to
% account for accuracy
hist_range = (0:1:50);
% full_mahal_epoch_distance = zeros(row,row,column,max(number_of_epochs),max(number_of_epochs));
full_pdist_epoch_distance = zeros(row,row,column,2,length(hist_range));
cluster_mahal_epoch_distance = zeros(row,row,column,max(number_of_epochs));


for rR=1:row
    for r=1:row
        for b=1:column
            %                 full_mahal_epoch_distance(rR,r,b,1:number_of_epochs(rR)) =...
            %                     mahal(squeeze(epoch_models(rR).epochs(:,2,b,:))',...
            %                     squeeze(epoch_models(r).epochs(:,2,b,:))');
            cluster_mahal_epoch_distance(rR,r,b,1:number_of_epochs(r)) =...
                mahal(gmm_models(rR,b).gmm_obj,...
                squeeze(epoch_models(r).epochs(:,2,b,1:number_of_epochs(r)))');
        end
        %     e2e_d = squeeze(full_pdist_epoch_distance(rR,:,:,:,:));
        %     e2e_d_o = strcat('e2ed_',num2str(rR),'.mat');
        %     save(e2e_d_o,'e3e_d');
    end
end

for rR=1:row
    for r=rR+1:row
        for b=1:column
            pdist_inter = pdist( [squeeze(epoch_models(rR).epochs(:,2,b,:))';...
                squeeze(epoch_models(r).epochs(:,2,b,:))']);
            [twist_data1,twist_data2] = hist(pdist_inter,hist_range);
            full_pdist_epoch_distance(rR,r,b,:,:) = [twist_data1;twist_data2];
        end
    end
end

% generate plot of clusters versus epochs
test_plot = squeeze( mean(cluster_mahal_epoch_distance,3) );

figure(567);mesh( log10( squeeze(test_plot(:,50,:) ) ) );
xlabel('Epochs');
ylabel('Subjects');
zlabel('log_1_0 scaled distance');
title(' Subject 50 Epoch Distance Versus Subjet GMM Clusters ');
ylim([0 round(row/10)*10]);
xlim([0 ceil(max(number_of_epochs))]);

end