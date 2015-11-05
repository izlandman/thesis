% this function takes in a half complete or fully complete distance matrix
% built via dynamic time warping. it also requires a targeted sample to
% build its discriminator from along with the file name to find/build the
% matching annotation vector

function warpSort2(data,file_name,sample_rate,window_overlap)
close all;
[leg1,leg2] = size(data);

% take the annotation file and determine where each leading sample falls
% within the annotations. add this value to the trackin_matrix
anno_name = ['./_thesis/_Data/physio/eegmmidb/Annotations/' file_name(1:7) '_ANN.ann'];
[events, anno_listing, event_length] = annotationEventTags(anno_name,leg1,sample_rate,window_overlap);

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
binary_points = sum(binary_data);

figure('name','binary distance','numbertitle','off');
plot( binary_points );
y_title = ['Associated Window Count, Distance Below:' num2str(thresh)];
xlim([1 leg1]); xlabel('Window Index');
ylabel(y_title);
grouped_windows = binary_data.*sorted_index;

% find and order peaks of binary_data. use this to iterate through the data
% by removing already matched windows until all are removed (or perhaps
% juse the n-most largest groupings are taken and mapped)
counter = 1;
[pks,locs,~,~] = findpeaks(binary_points);
ordered_peaks = sortrows( [pks;locs]',-1);
links = {};
while( counter > 0 )
    
    % highest peak count window
    target_window = ordered_peaks(1,2);
    % filter out linked windows
    links{end+1} = sorted_index(binary_data(:,target_window),target_window);
    % find intersection and remove those choices from ordered_peaks
    [~,~,ib] = intersect(links{end},ordered_peaks(:,2));
    ordered_peaks(ib,:) = [];
    if( length( ordered_peaks(:,1) ) < leg1*.1 )
        counter = -1;
    end
    % compare annotations to voted sequences!
    % besure to filter as well! 8 samples is 2 seconds or half an event!
    target_set = grouped_windows(:,target_window);
    target_set = target_set(target_set~=0);
    plot_set = zeros(1,leg1);
    plot_set(target_set) = 1;
    window_size = round( 1 / (1 - window_overlap/100) );
    gain = 1;
    thresh = 0.7;
    filtered_set = firstDigiFilt(plot_set,window_size,gain);
    target_win_label = ['filtered window sequence of: ' num2str(target_window)];
    
    %find true positives and true negatives
    binary_set = filtered_set;
    binary_set(binary_set>=thresh)=1;
    binary_set(binary_set<thresh)=0;
    grouped_match = binary_set'.*anno_listing;
    
    % plot results of thresholding
    figure('name',target_win_label,'numbertitle','off');
    window_index = 1:1:leg1;
    subplot(211);plot(window_index,filtered_set);
    ylim([-0.1 1.1]);xlabel('window index');
    xlim([1 leg1]);
    ylabel('Filtered window votes');
    subplot(212);plot(window_index,grouped_match,'k',window_index,anno_listing,'r');
    ylim([-0.1 7.1]);xlabel('window index');
    xlim([1 leg1]);
    y_title = ['Binary Threshold (' num2str(thresh) ') to Annotation Match'];
    ylabel(y_title);
    
    
    % loop through each annotated event
    index_start = 1;
    event_tags = unique(events);
    hits = zeros(length(events),length(event_tags));
    true_events = zeros(1,length(event_tags));
    for i=1:length(event_length)
        index_end = event_length(i) + index_start - 1;
        for r=1:length(event_tags)
            target_window = grouped_match(index_start:index_end);
            % find first non-zero entry and set all other non-zero entries
            % to that value because thsee events cannot overlap in the
            % annotations
            [~,~,val] = find(target_window,1,'first');
            target_window(target_window>0) = val;
            match_count = sum( target_window == event_tags(r));
            if( match_count > 0 )
                hits(i,r) = 1;
            end
            if( i == 1 )
                true_events(r) = sum(event_tags(r)==events);
            end
        end
        index_start = 1 + index_end;
    end
    
    sensitivity = sum(hits)./true_events    
    
end
end