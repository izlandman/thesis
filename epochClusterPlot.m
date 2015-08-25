% A plot that probably never gets used any more. From the same day when I
% reworked kMeans to brush up on basic clustering techniques.

function epochClusterPlot(data,target)
close all;
bands = {'delta','theta','alpha','mu','beta','gamma'};
num_bands = length(bands);

plot_c = 2;
plot_r = ceil(num_bands/plot_c);

output = squeeze( data(target,:,:,:) );
figure(target);title(' Epoch distance versus frequency and subject ');
for i=1:num_bands
    subplot(plot_r,plot_c,i);plot( log10( squeeze(output(:,i,:)) ) );
    xlim([ 0 110 ]); title(strcat(bands{i},' frequency band'));
    if( i == 3 || i == 4 )
        ylabel(' log_1_0 scaled distance ');
    end
    if( i > 4 )
        xlabel(' subject index');
    end
end
end