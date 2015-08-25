close all;

sampling_rate = 200;
max_window = 20;
data = data_prime{1}(:,1);
b_width = 1;
b_growth = 4;

iterations = floor( ( 100 - b_width ) / b_growth );

[data_length,data_sensors] = size(data);
result = zeros(iterations,data_length,data_sensors);


for i =1:iterations
    
    window_b_size = b_width + b_growth*(i-1);
    
    feature_window = zeros(sampling_rate,1);
    feature_window_mid = round(length(feature_window)/2 - ...
        window_b_size/2);
    feature_window(feature_window_mid:feature_window_mid + ...
        window_b_size - 1) = 1;
    
    
    for r=1:data_length
        
        data_window = zeros(sampling_rate,1);
        
        if( r - sampling_rate < 0 )
            true_signal = data(1:r,:);
            padded_signal = zeros(200-r,1);
            padded_window = [padded_signal;true_signal];
        elseif( r + sample_rate > data_length)
            true_signal = data(r:end,:);
            padded_signal = zeros(200 - (data_length-r),1);
            padded_window = [true_signal;padded_signal];
        else
            padded_window = data(r:r+sample_rate-1,:);
        end
        
        result(i,r,:) = computeResiduals(feature_window,padded_window);
        
    end
    
end