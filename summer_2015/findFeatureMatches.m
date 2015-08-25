% should return location in x-axis of matched items to highlight those for
% either inclusion as new annotations OR to be verified by user. this
% will need to be far more complex as we move forward.
function result = findFeatureMatches( feature_comparison )

[~,num_annotations,~,num_signals] = size(feature_comparison);

annotation_matches = zeros(num_annotations,num_signals);
annotation_index = annotation_matches;

% for now, go with PSD values [column=2]
for i=1:num_annotations
    for r=1:num_signals
        [annotation_matches(i,r),annotation_index(i,r)] = min( feature_comparison(:,i,2,r) );
    end
end

result.matches = annotation_matches;
result.index = annotation_index;
end