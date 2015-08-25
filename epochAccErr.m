% apply EM to find accuracy and error from the two given epochs models.
% this does not take into account channel matching as it deals only with
% the distances between each epoch for all channels

% INPUT: SUBJECT_1 and SUBJECT_2 need to be individual epoch files

% OUTPUT: three vectors of length NUM_VARS that provide the distance
% measurement, DISTANCE_FULL, along with the ACCURACY and ERROR of the
% resultant EM calculation

% DEPENDENCIES: _epochHistorgrams_ is called 

function [accuracy,error,distance_full] = epochAccErr(subject_1,subject_2)

close all;

model_33 = epochHistograms(subject_1,subject_1);
model_1010 = epochHistograms(subject_2,subject_2);

gmm_33 = gmdistribution.fit( reshape(model_33,64*64,1), 1);
gmm_1010 = gmdistribution.fit( reshape(model_1010,64*64,1), 1);

num_vars = 10000;
distance_spacing = 1000;

% random variables for testing
R_1 = mvnrnd( gmm_33.mu, gmm_33.Sigma, num_vars);
R_2 = mvnrnd( gmm_1010.mu, gmm_1010.Sigma, num_vars);
R_1 = R_1(R_1>=0);
R_2 = R_2(R_2>=0);


% distance between the two points
peak_distance = max( [R_1;R_2] );
distance_full = linspace(0,peak_distance,distance_spacing);
R_1_distance = abs(R_1 - gmm_33.mu) - abs(R_1 - gmm_1010.mu);
R_2_distance = abs(R_2 - gmm_1010.mu) - abs(R_2 - gmm_33.mu);

% setup likelihood measurements
pdf_33 = pdf(gmm_33,distance_full');
pdf_1010 = pdf(gmm_1010,distance_full');

% setup threshold
thresh_33 = reallog(pdf_33./pdf_1010)-reallog(gmm_33.Sigma/gmm_1010.Sigma)/2;
thresh_1010 = reallog(pdf_1010./pdf_33)-reallog(gmm_1010.Sigma/gmm_33.Sigma)/2;

error = zeros(length(distance_full),1);
accuracy = error;
for i=1:length(distance_full)
    true_R_1 = R_1_distance <= thresh_33(i);
    true_R_2 = R_2_distance <= thresh_1010(i);
    false_R_1 = R_2_distance > thresh_1010(i);
    false_R_2 = R_1_distance > thresh_33(i);
    
    error(i) = 1/2 * sum(false_R_1)/length(false_R_1) + 1/2 * sum(false_R_2)/length(false_R_2);
    accuracy(i) = 1/2 * sum(true_R_1)/length(true_R_1) + 1/2 * sum(true_R_2)/length(true_R_2);
end
end