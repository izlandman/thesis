function result = buildLdaModel(true_features,bland_features)
% use Matlab's fitcdiscr to generate a LDA model for finding features based
% upon the power band data provided in the selected annotation

feature_type = 3;

[feature_length, signals] = size(true_features{1}.features{feature_type});
real_data_length = length(true_features);
bland_data_length = length(bland_features);
total_observations = real_data_length + bland_data_length;

training_data = zeros(signals,feature_length,total_observations);
training_labels = zeros(total_observations,1);
result = cell(signals,1);

for i=1:total_observations
    if( i <= real_data_length )
        training_data(:,:,i) = [true_features{i}.features{feature_type}]';
        training_labels(i) = 1;
    else
        training_data(:,:,i) = [bland_features{i-real_data_length}.features{feature_type}]';
        training_labels(i) = 3;
    end
end

% cost_matrix can be used to set weights for TYPE I and TYPE II errors
% prior to calculation. rows are true class, columns are predicted. this
% makes the upper right (1,2) the error we need to minimize to assure as
% few true cases are missed as possible. the software defaults to [0 1;1 0]
% but adjustments will probably need to be made at some point.
cost_matrix = [0 1 ; 1 0];

for i=1:signals
    result{i} = fitcdiscr( squeeze(training_data(i,:,:))',training_labels,...
        'Cost',cost_matrix);
end
    
end