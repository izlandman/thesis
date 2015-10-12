% plot the distances on a given diagonal from the confusion matrix
function result = diagonalDistancePlot(data,events,start_point,lag,header)
[length1,~] = size(data);
spacing = lag*events;
leading = start_point:1:length1-spacing;
trailing = spacing+start_point:1:length1;
result = data(sub2ind(size(data),leading,trailing));
result_mean = mean(result);
figure_name = ['Diagonal Distance Plot: ' header ];
figure('numbertitle','off','name',figure_name);
title(['Events: ' num2str(events) ' Start Point: ' num2str(start_point) ' Lag: ' num2str(lag)]);
subplot(211);plot(result);
line([1 length1-events],[result_mean result_mean],'linewidth',1,'color','r');
xlim([1 length1-events]);
ylabel('Distance Measurement');
xlabel(['Mean Distance: ' num2str(result_mean)]);
subplot(212);plot( (result-mean(result)).^2 );
xlim([1 length1-events]);
xlabel('Window Index');
ylabel('Distance Measurement Error From Mean');

end