close all;
verbose = 0;
i = 1;
sample_rate = 200;
% percentage
overlap = 0.5;
feature_width = 2;
growth = 1;
feature_style = 'triangle';
data_columns = [ 1 3 ];
% largest 'feature' could be ten seconds in duration, maybe?
max_feature_size = 200;

signals = length(data_columns);
iterations = ( max_feature_size - feature_width ) / growth;
std_devs = zeros(iterations,signals);
std_devs_filt = std_devs;
means = std_devs;
means_filt = means;
feature_length =zeros(iterations,1);

% fitler to group matches
window_size = 5;
b = (1/window_size)*ones(window_size,1);
a =  1 ;

for g=1:iterations+1
    
    feature_length(g) = feature_width + growth*(g-1);
    
    result = featureMapping(file_list{i},data_columns,sample_rate,overlap,...
        feature_style,feature_length(g));
    
    std_devs(g,:) = std(result(:,1:signals));
    means(g,:) = mean(result(:,1:signals));
    % filter signals
    result_filt = filter(b,a,result(:,1:signals));
    std_devs_filt(g,:) = std(result_filt);
    means_filt(g,:) = mean(result_filt);
    
    if( verbose == 1)
        
        k = floor( (g+1) / 2);
        q = mod( (g+1) , 2);
        figure(k);
        if( q == 0 )
            spot = [ 1 3 5 7 9 11 ];
        else
            spot = [ 2 4 6 8 10 12 ];
        end
        for r=1:signals
            subplot(signals,2,spot(r));plot(result(:,3),result(:,r));
            ylabel( ['signal ',num2str(r)]);
            title(['feature: ',feature_style,' ','width: ',num2str(feature_length)]);
        end
        
    end
    
end

figure('name','Means','numbertitle','off');
subplot(211);plot(feature_length,means);
subplot(212);plot(feature_length,means_filt)
figure('name','standard deivation','numbertitle','off');
subplot(211);plot(feature_length,std_devs);
subplot(212);plot(feature_length,std_devs_filt)

coeff_var = std_devs ./ means;
figure(42);plot(coeff_var)
coeff_var_filt = std_devs_filt ./ means_filt;
figure(43);plot(coeff_var_filt)
