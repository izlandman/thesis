function result = annotationWindowCenter(varargin)

% check if annotation is longer than sample rate, determine which need to
% be reshape to meet sample rate. this ensures that any analysis done in
% the frequency domain will present with the same frequencies

if( nargin == 4 )
    
    sample_rate = varargin{3};
    data_length = varargin{4};
    annotation_start = varargin{1};
    annotation_end = varargin{2};
    
    feature_start = annotation_start;
    feature_stop = annotation_end;
    
    % length check flags index with samples below native sample rate
    length_check = (annotation_end - annotation_start) < sample_rate;
    annotation_means = round( mean( [annotation_start,annotation_end],2 ));
    annotation_start = annotation_means - ceil(sample_rate/2);
    annotation_end = annotation_start + sample_rate - 1;
    
    feature_start(length_check) = annotation_start(length_check);
    feature_stop(length_check) = annotation_end(length_check);
    
    overrun_check = feature_stop > data_length;
    underrun_check = feature_start < 1;
    
    feature_start(underrun_check) = 1;
    feature_stop(underrun_check) = sample_rate;
    feature_stop(overrun_check) = data_length;
    feature_start(overrun_check) = data_length - sample_rate + 1;
    
    result.start = feature_start;
    result.stop = feature_stop;
    
elseif( nargin == 3 )
    
    annotation_center = varargin{1};
    sample_rate = varargin{2};
    data_length = varargin{3};
    
    annotation_start = annotation_center - round( sample_rate/2 );
    annotation_end = annotation_center + sample_rate - 1;
    
    feature_start = annotation_start;
    feature_stop = annotation_end;
    
    length_check = (annotation_end - annotation_start) < sample_rate;
    annotation_means = round( mean( [annotation_start,annotation_end],2 ));
    annotation_start = annotation_means - ceil(sample_rate/2);
    annotation_end = annotation_start + sample_rate - 1;
    
    feature_start(length_check) = annotation_start(length_check);
    feature_stop(length_check) = annotation_end(length_check);
    
    overrun_check = feature_stop > data_length;
    underrun_check = feature_start < 1;
    
    feature_start(underrun_check) = 1;
    feature_stop(underrun_check) = sample_rate;
    feature_stop(overrun_check) = data_length;
    feature_start(overrun_check) = data_length - sample_rate + 1;
    
    result.start = feature_start;
    result.stop = feature_stop;
else
    disp('annotationWindowCenter called incorrectly');
end

end