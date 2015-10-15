function warpSort(data,target_window,annos)
    R = load('myColorMap1');
    [leg1,leg2] = size(data);
    [sorted_data, sorted_index] = sort(data,1);
    figure('name','sorted distances','numbertitle','off');
    subplot(121);mesh(sorted_data);view(0,90);
    axis([1 leg1 1 leg2]);
    colormap(R.myColorMapBluePink); colorbar;
    subplot(122);mesh(log10(sorted_data));view(0,90);
    axis([1 leg1 1 leg2]);
    colormap(R.myColorMapBluePink); colorbar;
    
    binary_data = log10(sorted_data)<0.8;
    figure('name','binary distance','numbertitle','off');
    subplot(211);plot( sum(binary_data) );
    xlim([1 leg1]);
    grouped_windows = binary_data.*sorted_index;
    plot_this = grouped_windows(grouped_windows(:,42)~=0,42);
    subplot(212);plot( plot_this, ones(1,length(plot_this)) );
    
    % compare annotations to voted sequences!
    % besure to filter as well! 8 samples is 2 seconds or half an event!
    target_set = grouped_windows(:,target_window);
    target_set = target_set(target_set~=0);
    plot_set = zeros(1,leg1);
    plot_set(target_set) = 1;
    window_size = 4;
    gain = 1;
    thresh = 0.6;
    filtered_set = firstDigiFilt(plot_set,window_size,gain);
    figure('name','filtered window sequence','numbertitle','off');
    window_index = 1:1:leg1;
    subplot(211);plot(window_index,filtered_set);
    ylim([-0.1 1.1]);xlabel('window index');
    ylabel('Filtered window votes');
    binary_set = filtered_set;
    binary_set(binary_set>thresh)=1;
    subplot(212);plot(window_index,binary_set'.*annos,'k',window_index,annos,'r');
    ylim([-0.1 7.1]);xlabel('window index');
    y_title = ['Binary Threshold (' num2str(thresh) ') to Annotation Match'];
    ylabel(y_title);
end