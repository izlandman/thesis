% Okay, this is attempting to find accuracy and error but _epochHistograms_
% is only comparing each channel with time as features to each other. That
% file is not too useful so while this file does work, it operates on silly
% data being returned from _epochHistograms_.

model_33 = epochHistograms(trial_11_subject_7,trial_11_subject_7);
model_1010 = epochHistograms(trial_7_subject_30,trial_7_subject_30);

gmm_33 = gmdistribution.fit( reshape(model_33,64*64,1), 1);
gmm_1010 = gmdistribution.fit( reshape(model_1010,64*64,1), 1);

num_vars = 10000;
distance_spacing = 1000;

% random variables for testing
R_1 = mvnrnd( gmm_33.mu, gmm_33.Sigma, num_vars);
R_2 = mvnrnd( gmm_1010.mu, gmm_1010.Sigma, num_vars);

% distance between the two points
peak_distance = max( max( [R_1,R_2] ) );
distance_full = linspace(0,peak_distance,distance_spacing);
distance_full_invert = peak_distance - distance_full;

% distance_btwn = abs( gmm_33.mu - gmm_1010.mu);
% distance_to_33 = linspace(0,distance_btwn,distance_spacing);
% distance_to_1010 = distance_btwn - distance_to_33;

R_1_distance = abs(R_1 - gmm_33.mu) - abs(R_1 - gmm_1010.mu);
R_2_distance = abs(R_2 - gmm_1010.mu) - abs(R_2 - gmm_33.mu);

% setup likelihood measurements
pdf_33 = pdf(gmm_33,distance_full');
pdf_1010 = pdf(gmm_1010,distance_full');

% setup threshold
thresh_33 = reallog(pdf_33./pdf_1010)-reallog(gmm_33.Sigma/gmm_1010.Sigma)/2;
thresh_1010 = reallog(pdf_33./pdf_1010)-reallog(gmm_1010.Sigma/gmm_33.Sigma)/2;

for i=1:length(distance_full)
    true_R_1 = R_1_distance <= thresh_33(i);
    true_R_2 = R_2_distance <= thresh_1010(i);
    false_R_1 = R_2_distance > thresh_1010(i);
    false_R_2 = R_1_distance > thresh_33(i);
    
    error(i) = 1/2 * sum(false_R_1)/num_vars + 1/2 * sum(false_R_2)/num_vars;
    accuracy(i) = 1/2 * sum(true_R_1)/num_vars + 1/2 * sum(true_R_2)/num_vars;
end

figure(11);
X1 = distance_full;
Y1 = [error;accuracy]';
Y2 = [pdf_33';pdf_1010']';
plotyy(X1,Y1,X1,Y2);
legend('error','accuracy','data 1','data 2');
