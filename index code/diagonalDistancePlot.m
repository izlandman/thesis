% plot the distances on a given diagonal from the confusion matrix
function result = diagonalDistancePlot(data,events,start_point,lag)
[length1,~] = size(data);
spacing = lag*events;
leading = start_point:1:length1-spacing;
trailing = spacing+start_point:1:length1;
result = data(sub2ind(size(data),leading,trailing));
figure('numbertitle','off','name','Diagonal Distance Plot');
title(['Events: ' num2str(events) ' Start Point: ' num2str(start_point) ' Lag: ' num2str(lag)]);
subplot(211);plot(result);
subplot(212);plot(result-mean(result));
xlim([1 length1-events]);
xlabel('Window Index');
ylabel('Distance Measurement');

end