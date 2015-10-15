function warpSort(data)
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
end