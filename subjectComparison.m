% generate data on distances between one user's trials. intra-trial
% distance and inter-trial distances shown as a histogram and gaussian
% plots from each unique frequency band

% INPUT: SUBJECT_NUMBER is an integer within the pool of subjects and BAND
% is an integer number within the pool of frequency bands. VARARGIN allows
% a more comprehensive output if NARGIN exceeds 2. At the moment these
% plots are not all fully functional as the accuracy and error plot needs
% to be fixed.

% OUTPUT: STRAIGHT_INTERNAL is a listing of all internal distances across
% all bands. STRAIGHT_EXTERNAL is a listing of all external distances
% across all bands. These values are intended to be used to build
% histograms of the resultant external/internal measurements to show
% separability between the trials of a given subject.

% DEPENDENCIES: This file requires _fileFinderFull_ and _folderFinder_
% which are separate functions. There are also a number of internal
% functions unique to this file below the main function.

function [straight_internal,straight_external] = subjectComparison(subject_number,band,varargin)

close all;
% feature is set to 2 for peak amplitude value
feature = 2;

% find folders
epoch_folders = folderFinder(pwd,'epoch');
gmm_folders = folderFinder(pwd,'gmm');

% find files for that subject
subject_epochs = fileFinderFull(epoch_folders,subject_number,feature);
subject_gmms = fileFinderFull(gmm_folders,subject_number);
valid_gmms = fileFinderFull(gmm_folders);
epoch_num_files = length(subject_epochs);
[gmm_num_files,~] = size(subject_gmms);
[~,~,number_of_epochs] = cellfun(@size,subject_epochs);
% search for 1 in valid to make sure gmm was built and data isn't poor
gm_models = cellfun(@(x) x(subject_number),valid_gmms);
working_gmm = (1:1:gmm_num_files);
working_gmm = working_gmm(gm_models);

% find all gmms not of that subject

% inter-trial distances of the subject, set via band and trial
results_internal = cell(epoch_num_files,1);
results_external = cell(epoch_num_files,1);

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
        results_internal{i} = -1*ones(max(number_of_epochs),length(working_gmm)-1);
        results_external{i} = -1*ones(max(number_of_epochs),1);
    else
        %             applicable_trials = ( 1:1:length(working_gmm) );
        %             applicable_trials = applicable_trials( b ~= applicable_trials );
        results_internal{i} = pdist2(epoch_test,subject_gmms{i}{band}.mu);
        results_external{i} = pdist2(epoch_test,other_gmms_mu);
    end
end
% conditon the data for histogram
straight_internal = straightMatrix(results_internal);
straight_external = straightMatrix(results_external);

% if two or more input arguments, show plot
if( nargin > 2 )
    inter_models = cell(length(results_internal),1);
    
    for r=1:length(results_internal)
        [a,b] = size(results_internal{r});
        inter_models{r} = gmdistribution.fit(reshape(results_internal{r},a*b,1),1);
    end
    
    % histogram setup and plot
    top_end_range = max([straight_internal;straight_external]);
    
    x = 0:1:top_end_range;
    y1 = straight_internal;
    [n1,x] = hist(y1,x);
    y2 = straight_external;
    [n2,x] = hist(y2,x);
    n1 = n1./sum(n1);
    n2 = n2./sum(n2);
    
    figure(57);
    subplot(211);bar(x,n1);grid on;
    axis([ 0 top_end_range 0 max(n1)*1.1]);
    title('Internal Trial Distances');
    subplot(212);bar(x,n2);grid on;
    axis([ 0 top_end_range 0 max(n2)*1.1]);
    title('External Trial Distances');
    
    % GMM setup and plot
    bottom = min([straight_internal;straight_external]);
    top = max([straight_internal;straight_external]);
    xx = linspace(0,top)';
    figure(42);hold on; grid on;
    gm1 = gmdistribution.fit(straight_internal,1);
    gm2 = gmdistribution.fit(straight_external,1);
    line(xx,gm1.PComponents*normpdf(xx,gm1.mu,sqrt(gm1.Sigma)),'color','r');
    line(xx,gm2.PComponents*normpdf(xx,gm2.mu,sqrt(gm2.Sigma)),'color','b')
    legend('Internal to Trial','External to Trial');
    
    % plot accuracy and error
    [acc,error,x_vector] = piconeModel(gm1,gm2);
    figure(47); grid on; hold on;
    plot(x_vector,acc,'g--','linewidth',2);
    plot(x_vector,error,'k--','linewidth',2);
    
    figure(56);
    for r=1:length(inter_models)
        subplot(7,2,r);
        line(xx,normpdf(xx,inter_models{r}.mu,sqrt(inter_models{r}.Sigma)));
    end
end

end

% error and accuracy plots
function [accuracy, error, distance_full] = piconeModel(gm1,gm2)
num_vars = 10000;
distance_spacing = 1000;

% random variables for testing
R_1 = mvnrnd( gm1.mu, gm1.Sigma, num_vars);
R_2 = mvnrnd( gm2.mu, gm2.Sigma, num_vars);

% distance between the two points
peak_distance = max( max( [R_1,R_2] ) );
min_distance = min( min( [R_1,R_2] ) );
distance_full = linspace(min_distance,peak_distance,distance_spacing);
R_1_distance = abs(R_1 - gm1.mu) - abs(R_1 - gm2.mu);
R_2_distance = abs(R_2 - gm2.mu) - abs(R_2 - gm1.mu);

% setup likelihood measurements
pdf_1 = pdf(gm1,distance_full');
pdf_2 = pdf(gm2,distance_full');

figure(1010);grid on;hold on;
plot(distance_full,pdf_1,'b');
plot(distance_full,pdf_2,'r');

% setup threshold
thresh_1 = reallog(pdf_1./pdf_2)-reallog(gm1.Sigma/gm2.Sigma)/2;
thresh_2 = reallog(pdf_2./pdf_1)-reallog(gm2.Sigma/gm1.Sigma)/2;

error = zeros(length(distance_full),1);
accuracy = error;
for i=1:length(distance_full)
    true_R_1 = R_1_distance <= thresh_1(i);
    true_R_2 = R_2_distance <= thresh_2(i);
    false_R_1 = R_2_distance > thresh_2(i);
    false_R_2 = R_1_distance > thresh_1(i);
    
    error(i) = 1/2 * sum(false_R_1)/num_vars + 1/2 * sum(false_R_2)/num_vars;
    accuracy(i) = 1/2 * sum(true_R_1)/num_vars + 1/2 * sum(true_R_2)/num_vars;
end
end

% returns column vector of all data, removes -1 values as well
function str_m = straightMatrix(M_in)
M = cell2mat(M_in);
r = size(M);
str_m = reshape(M,r(1)*r(2),1);
str_m = str_m(str_m ~= -1);
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