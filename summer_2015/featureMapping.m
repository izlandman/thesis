function result = featureMapping(file_name,channels,sample_rate,overlap,feature_type)

input_data = readHueText(file_name,channels);

feature = fakeFeatureCreator(feature_type,sample_rate);

result = featureResiduals(input_data,feature,overlap,sample_rate);

[~,best_match_ind] = min(result(:,1:end-1));
[samples,signals] = size(input_data);

for r=1:length(best_match_ind)
    left_pointer = best_match_ind(r)-sample_rate/2+1;
    right_pointer = left_pointer + sample_rate - 1;
    
    if( left_pointer < 0 )
        true_signal = input_data(1:right_pointer,:);
        padded_signal = zeros(200-right_pointer,signals);
        padded_window = [padded_signal;true_signal];
    elseif( right_pointer > samples )
        true_signal = input_data(left_pointer:end,:);
        padded_signal = zeros(200 - (samples-left_pointer),signals);
        padded_window = [true_signal;padded_signal];
    else
        padded_window = input_data(left_pointer:right_pointer,:);
    end
    
    figure(r);
    time = (left_pointer:right_pointer)/sample_rate;
    plot(time,padded_window(:,r));
    xlim([min(time) max(time)]);
end

end

function result = featureResiduals(input_data,feature,overlap,sample_rate)

[samples,signals] = size(input_data);
duration = samples/sample_rate;
sample_rate = length(feature);
feature = repmat(feature,1,signals);

if( overlap ~= 0 )
    iterations = floor((samples-sample_rate)/(sample_rate-overlap)) + 1;
else
    iterations = floor(samples/sample_rate);
end

% third colum should be index, either real or time
result = zeros(iterations,signals+1);
result(:,end) = linspace(0,duration,iterations);

for i=0:iterations-1
    left_pointer = i * (sample_rate-overlap) + 1 - sample_rate/2;
    right_pointer = left_pointer + sample_rate - 1;
    
    if( left_pointer < 0 )
        true_signal = input_data(1:right_pointer,:);
        padded_signal = zeros(200-right_pointer,signals);
        padded_window = [padded_signal;true_signal];
    elseif( right_pointer > samples )
        true_signal = input_data(left_pointer:end,:);
        padded_signal = zeros(200 - (samples-left_pointer),signals);
        padded_window = [true_signal;padded_signal];
    else
        padded_window = input_data(left_pointer:right_pointer,:);
    end
    
    result(i+1,1:signals) = computeResiduals(padded_window,feature);
    
end

end