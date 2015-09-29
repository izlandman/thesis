function timeWarpExample(data,sample1,sample2)
close all;
% grab and normalize data
raw1 = data(sample1,:)./norm(data(sample1,:));
raw2 = data(sample2,:)./norm(data(sample2,:));
[~,~,~,~,r1,r2] = cdtw(raw1,raw2,0);

raw_length = length(raw1);
warp_length = length(r1);

figure('numbertitle','off','name','Dynamic Time Warping Example');

subplot(211);
% high plot is raw data
plot([1:raw_length],raw1,'b-',[1:raw_length],raw2,'r--','LineWidth',2);
xlim([0 raw_length]);
ylabel('Normalized Magnitude');xlabel('Original Signal Index');
title('Time Warping');

set(gca,'FontSize',13);

subplot(212);
% low plot is warped data
plot([1:warp_length],r1,'b-',[1:warp_length],r2,'r--','LineWidth',2);
xlim([0 warp_length ]);
ylabel('Normalize Magnitude');xlabel('Warped Signal Index');

set(gca,'FontSize',13);
end