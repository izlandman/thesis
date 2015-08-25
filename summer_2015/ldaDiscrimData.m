function result = ldaDiscrimData(LDA_models,features_found)

[bands,signal_count] = size( features_found{1}.features{4} );
feature_iterations = length(features_found);
result = zeros(signal_count,feature_iterations);

% careful with this! you hardcoded in the feature ( features{3} ) but this
% really needs to adapt as you vary the feature under test

for i=1:signal_count
    step_one = cellfun(@(x) x.features{3}(:,1)',features_found,...
        'UniformOutput',0);
    step_two = cell2mat(step_one);
    result(i,:) = predict(LDA_models{i},step_two);
end

end