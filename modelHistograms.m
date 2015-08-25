% This takes a while to run if VERBOSE is enabled by calling it with three
% arguements. Plots are generated in VERBOSE to show the minimum distance
% of both eudlidean and mahalanobis distance.

% Called with only two inputs GMM_DIRECTORY and EPOCH_DIRECTORY internal
% and external subject distances are computed using both Mahalanobis
% distancs and euclidean distances. These constitute the three values
% returned by the function.

% INPUT: GMM_DIRECTORY is a string input '' of the location of the
% subject's gmm files. EPOCH_DIRECTORY is a string input '' of the location
% of the subject's epoch files

% OUTPUT: CLUTSER_MAHAL_EPOCH_DISTANCE and FULL_PDIST_EPOCH_DISTANCE are
% returned as an array of doubles [subject# x subject# x band# x epoch#].
% INTERSUBJECT_DISTANCE is also an array of doubles sizes [subject# x
% band# x subject#].

% NOTE: This should probably be reworked to save the histogram data so
% plots can be recreated as needed moving forward. Something for the future
% for sure.

% point this to a folder with the gmm distributions saved as mat files

function [cluster_mahal_epoch_distance,intersubject_distance_m,full_pdist_epoch_distance]...
    = modelHistograms(gmm_directory,epoch_directory,verbose)

close all;

feature = 2;
hist_distance = 250;

% build gmm file list, cells/strings
gmm_file_list = numericFileList(gmm_directory,'gmm_model_');
gmm_num_files = length(gmm_file_list);
epoch_file_list = numericFileList(epoch_directory,'epochs_model_');
epoch_num_files = length(epoch_file_list);

% pull everything into the workspace --------------------------------------

% grab gmm variables
gmm_models = cell(gmm_num_files,1);
for i=1:gmm_num_files
    gmm_temp = load(gmm_file_list{i});
    gmm_models{i} = gmm_temp.gmm_obj;
end

% grab epoch variables
number_of_epochs = zeros(epoch_num_files,1);
epoch_models = cell(epoch_num_files,1);
for i=1:epoch_num_files
    epoch_models{i} = load(epoch_file_list{i});
    number_of_epochs(i) = length(epoch_models{i}.epochs(1,1,1,:));
end

% work out intersubject distances between each model ----------------------
[bands,~] = size(gmm_models{1});
[~, mC] = size(gmm_models{1}{1}.mu);
average_mu = zeros(mC,bands,gmm_num_files);
[sR,sC] = size(gmm_models{1}{1}.Sigma);
average_sigma = zeros(sR,sC,bands,gmm_num_files);

for r=1:gmm_num_files
    for b=1:bands
        average_mu(:,b,r) = gmm_models{r}{b}.mu;
        average_sigma(:,:,b,r) = gmm_models{r}{b}.Sigma;
    end
end

intersubject_distance = zeros(gmm_num_files,bands,gmm_num_files);
intersubject_distance_m = zeros(gmm_num_files,bands,gmm_num_files);
intersubject_epoch_distance = zeros(gmm_num_files,gmm_num_files,bands,max(number_of_epochs));

for b=1:bands
    for c=1:gmm_num_files
        for r=(c+1):gmm_num_files
            % distance from all means to all other means
            intersubject_distance(r,b,c) = pdist( [average_mu(:,b,r)';average_mu(:,b,c)'] );
            intersubject_distance_m(r,b,c) = mahal( gmdistribution(average_mu(:,b,r)',...
                squeeze(average_sigma(:,:,b,r))),squeeze(average_mu(:,b,c))' );
            % compare epochs of c to all other clusters
            band_epoch = squeeze(epoch_models{r}.epochs(:,feature,b,:));
            pdist_result = pdist( [average_mu(:,b,c)';band_epoch' ]);
            intersubject_epoch_distance(r,c,1:number_of_epochs(r)) = pdist_result(1:number_of_epochs(r));
        end
    end
end

% develop model of epoch distance to native cluster -----------------------
intrasubject_distance = zeros(max(number_of_epochs),b,gmm_num_files);
intrasubject_distance_m = zeros(max(number_of_epochs),b,gmm_num_files);

for b=1:bands
    for r=1:gmm_num_files
        band_epoch = squeeze(epoch_models{r}.epochs(:,feature,b,:));
        distance = pdist( [average_mu(:,b,r)';band_epoch' ] );
        intrasubject_distance(1:number_of_epochs(r),b,r) = distance(1:number_of_epochs(r));
        intrasubject_distance_m(1:number_of_epochs(r),b,r) = mahal(...
            gmdistribution(average_mu(:,b,r)',squeeze(average_sigma(:,:,b,r))),...
            band_epoch');
    end
end

% histogram of intersubject epoch distances, euclidean
intersubject_epoch_hist_data = intersubject_epoch_distance( intersubject_epoch_distance ~= 0 );
figure('name','Euclidean Distance Histograms','numbertitle','off');
subplot(3,1,3);grid on;
hist_distance = max(intersubject_epoch_hist_data);
[hist_y,hist_x]=hist(intersubject_epoch_hist_data,0:1:hist_distance);
bar(hist_x,hist_y);xlim([0 hist_distance*1.1]);
ylabel('number of links');
thisLabel = strcat('Distance between groups, Euclidean [mean: ', num2str(mean(intersubject_epoch_hist_data)),' ]');
xlabel(thisLabel);
title('Distance Between Epoch and Non-Familial GMM Clusters');

% histogram of intrasubject model distance, euclidean
intrasubject_hist_data = intrasubject_distance( intrasubject_distance ~= 0 );
subplot(3,1,1);grid on;
hist_distance = max(intrasubject_hist_data);
hist(intrasubject_hist_data,0:1:hist_distance);xlim([0 hist_distance*1.1]);
ylabel('number of links');
thisLabel = strcat('Distance between groups, Euclidean [mean: ', num2str(mean(intrasubject_hist_data)),' ]');
xlabel(thisLabel);
title('Distance Between Epoch and Familial GMM Cluster');

% histogram of intersubject model distance, euclidean
intersubject_hist_data = intersubject_distance( intersubject_distance ~= 0 );
subplot(3,1,2);grid on;
hist_distance = max(intersubject_hist_data);
[hist_y,hist_x] = hist(intersubject_hist_data,0:1:hist_distance);
bar(hist_x,hist_y);xlim([0 hist_distance*1.1]);
ylabel('number of links');
thatLabel = strcat('Distance between groups, Euclidean [mean: ', num2str(mean(intersubject_hist_data)),' ]');
xlabel(thatLabel);
title('Distance Between GMM Cluster Centers');

% histogram of intrasubject and intersubject, mahal
intrasubject_hist_data_m = intrasubject_distance_m( intrasubject_distance_m ~= 0 );
intersubject_hist_data_m = intersubject_distance_m( intersubject_distance_m ~= 0 );
psuedo_inter_mahal = intersubject_hist_data_m;
psuedo_inter_mahal(psuedo_inter_mahal>2500) = 2500;
hist_distance = max(max([intrasubject_hist_data_m;psuedo_inter_mahal]));
x = 0:1:hist_distance;
y1 = intrasubject_hist_data_m;
[n1,x] = hist(y1,x);
y2 = intersubject_hist_data_m;
[n2,x] = hist(y2,x);

n1 = n1./sum(n1);
n2 = n2./sum(n2);

figure('name','Mahalanobis Distance Histogram','numbertitle','off');
bar(x,[n1;n2]','grouped');grid on;
axis([ 0 hist_distance*1.1 0 max(max([n1;n2]))*1.1]);
title('Histogram of Separable Mahalanobis Distances');
xlabel(' Distance between groups, Mahalanobis ');
ylabel(' Percentage of samples ');
legend('Intra Cluster Epoch Distance','Inter Cluster Distance','Location','NorthWest')

% on the same figure?
hist_distance = max(max([intrasubject_hist_data;intersubject_hist_data]));
x = 0:1:hist_distance;
y1 = intrasubject_hist_data;
[n1,x] = hist(y1,x);
y2 = intersubject_hist_data;
[n2,x] = hist(y2,x);
y3 = intersubject_epoch_hist_data;
[n3,x] = hist(y3,x);

n1 = n1./sum(n1);
n2 = n2./sum(n2);
n3 = n3./sum(n3);

figure('name','Euclidean Distance Histogram','numbertitle','off');
bar(x,[n1;n2]','grouped');grid on;
axis([ 0 hist_distance*1.1 0 max(max([n1;n2;n3]))*1.1]);
title('Histogram of Separable Euclidean Distances');
xlabel(' Distance between groups, Euclidean ');
ylabel(' Percentage of samples ');
legend('Within Cluster Epoch Distance','External Cluster Distance','Location','NorthEast')

% run each epoch in each band against everything of a similar type to
% account for accuracy


% full_mahal_epoch_distance = zeros(row,row,column,max(number_of_epochs),max(number_of_epochs));
full_pdist_epoch_distance = zeros(gmm_num_files,gmm_num_files,bands,max(number_of_epochs));
cluster_mahal_epoch_distance = zeros(gmm_num_files,gmm_num_files,bands,max(number_of_epochs));

if( nargin == 3)

    for rR=1:gmm_num_files
        for r=1:gmm_num_files
            for b=1:bands
                cluster_mahal_epoch_distance(rR,r,b,1:number_of_epochs(r)) =...
                    mahal(gmdistribution(gmm_models{rR}{b}.mu,gmm_models{rR}{b}.Sigma),...
                    squeeze(epoch_models{r}.epochs(:,2,b,1:number_of_epochs(r)))');
            end
        end
    end
    
    for b=1:bands
        for rR=1:gmm_num_files
            for r=1:gmm_num_files
                pdist_inter = pdist( [squeeze(epoch_models{rR}.epochs(:,2,b,:))';...
                    squeeze(epoch_models{r}.epochs(:,2,b,:))']);
                aAa = squareform(pdist_inter);
                %             r
                %             rR
                %             number_of_epochs(r)
                %             number_of_epochs(rR)
                full_pdist_epoch_distance(rR,r,b,1:number_of_epochs(r)) = mean(aAa(number_of_epochs(rR)+1:end,1:number_of_epochs(r)));
            end
        end
    end
    
    % generate plot of clusters versus epochs
    test_plot = squeeze( mean(cluster_mahal_epoch_distance,3) );
    euc_test_plot = squeeze( mean(full_pdist_epoch_distance,3) );
    
    % figure(567);mesh( log10( squeeze(test_plot(:,50,:) ) ) );
    figure(567);surf( log10( min(min(squeeze(test_plot(:,50,:))))./squeeze(test_plot(:,50,:))) );
    xlabel('Epochs');
    ylabel('Subjects');
    zlabel('log_1_0 Scaled Distance');
    title(' Subject 50 Minimum Epoch Mahalanobis Distance Versus Cluster Models');
    ylim([0 round(gmm_num_files/10)*10]);
    xlim([0 ceil(max(number_of_epochs))]);
    
    % euclidean plot
    figure(569);surf( log10( min(min(squeeze(euc_test_plot(:,50,:))))./squeeze(euc_test_plot(:,50,:))) );
    xlabel('Epochs');
    ylabel('Subjects');
    zlabel('log_1_0 Scaled Distance');
    title(' Subject 50 Minimum Epoch Euclidean Distance Versus All Subjects'' Epochs ');
    ylim([0 round(gmm_num_files/10)*10]);
    xlim([0 ceil(max(number_of_epochs))]);
    
end
end