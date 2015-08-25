classdef FeatureCrate
    properties
        source
        features
        start
        stop
        duration
        type
        frequency
        weight
    end
    methods
        function obj = FeatureCrate()
            obj.type='';
        end
        
        function fourierTrans = fourTransform(time_series)
            L = length(time_series(:,1));
            NFFT = 2^nextpow2(L);
            fourierTrans = fft(plot_data,NFFT)/L;
        end
        
        function psdTrans = psdTransform(time_series)
        end
    end
end