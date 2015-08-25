function result = distillFeature(new_features,true_features)
% Take the new features and compare them against existing features (if
% any). There is a strong chance this may be called with all three inputs
% empty or at least one input empty. If a new feature is found (HOW DOES
% ONE TELL IF IT IS NEW?) add it to RESULT.

result = true_features;

if( isempty(new_features) )
    % no new features, nothing to compute
elseif( ~isempty(new_features) )
    % new features
    if( isempty(true_features) )
        % no features present yet, add them all

        if( ~isempty(new_features) )
            for i=1:length(new_features)
                if( iscell(new_features) )
                    result{i} = new_features{i};
                else
                    result{i} = new_features(i);
                end

            end
        end
    elseif( ~isempty(true_features) )
        % there are already features, add to them

        if( ~isempty(new_features) )
            for k=1:length(new_features)
                if( iscell(new_features) )
                    result{end+1} = new_features{k};
                else
                    result{end+1} = new_features(k);
                end

            end
        end
    else
        % perhaps do a compare, but for now just add all features
    end
end

result = result';

end