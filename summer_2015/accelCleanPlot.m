function accelCleanPlot(file_name)

data_in = csvread(file_name);
labels_n = {'X Axis','Y Axis','Z Axis'};

figure('name',file_name,'numbertitle','off')
for i=1:3
    subplot(3,1,i);plot(data_in(:,i),'linewidth',2);
    ylim([ min(data_in(:,i))*1.05 max(data_in(:,i))*1.05]);
    ylabel('Acceleration (m/s^2)');
    title(labels_n{i});
    grid on;
    if( i == 3 )
        xlabel('Time (s)');
    end
end
end