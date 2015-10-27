% this function takes in a half complete or fully complete distance matrix
% built via dynamic time warping. it also requires a targeted sample to
% build its discriminator from along with the file name to find/build the
% matching annotation vector

function warpSort(data,target_window,file_name,sample_rate,window_overlap)

[leg1,leg2] = size(data);

% take the annotation file and determine where each leading sample falls
% within the annotations. add this value to the trackin_matrix
anno_name = ['./_thesis/_Data/physio/eegmmidb/Annotations/' file_name(1:7) '_ANN.ann'];
[~, anno_listing, ~] = annotationEventTags(anno_name,leg1,sample_rate,window_overlap);

% check the incoming data and make it square if it isn't
if( data(1,end-5) ~= data(end-5,1) && data(5,end-1) ~= data(end-1,5) )
    data = data + data';
end

R = load('myColorMap1');
% the sorted data shows the distance spread for each window sample
[sorted_data, sorted_index] = sort(data,1);

figure('name','sorted distances','numbertitle','off');
subplot(211);mesh(sorted_data);view(0,90);
xlabel('Window Index');ylabel('Number of windows');
axis([1 leg1 1 leg2]);
colormap(R.myColorMapBluePink); colorbar;
subplot(212);mesh(log10(sorted_data));view(0,90);
xlabel('Window Index');ylabel('Number of windows');
axis([1 leg1 1 leg2]);
colormap(R.myColorMapBluePink); colorbar;

thresh = 0.8;
binary_data = log10(sorted_data)<thresh;
figure('name','binary distance','numbertitle','off');
plot( sum(binary_data) );
y_title = ['Associated Window Count, Distance Below:' num2str(thresh)];
xlim([1 leg1]); xlabel('Window Index');
ylabel(y_title);
grouped_windows = binary_data.*sorted_index;

% compare annotations to voted sequences!
% besure to filter as well! 8 samples is 2 seconds or half an event!
target_set = grouped_windows(:,target_window);
target_set = target_set(target_set~=0);
plot_set = zeros(1,leg1);
plot_set(target_set) = 1;
window_size = 4;
gain = 1;
thresh = 0.8;
filtered_set = firstDigiFilt(plot_set,window_size,gain);
target_win_label = ['filtered window sequence of: ' num2str(target_window)];
figure('name',target_win_label,'numbertitle','off');
window_index = 1:1:leg1;
subplot(211);plot(window_index,filtered_set);
ylim([-0.1 1.1]);xlabel('window index');
xlim([1 leg1]);
ylabel('Filtered window votes');
binary_set = filtered_set;
binary_set(binary_set>=thresh)=1;
binary_set(binary_set<thresh)=0;
subplot(212);plot(window_index,binary_set'.*anno_listing,'k',window_index,anno_listing,'r');
ylim([-0.1 7.1]);xlabel('window index');
xlim([1 leg1]);
y_title = ['Binary Threshold (' num2str(thresh) ') to Annotation Match'];
ylabel(y_title);
end