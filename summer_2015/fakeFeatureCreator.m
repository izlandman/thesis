function result = fakeFeatureCreator(feature_type,feature_size,varargin)
% varargin in should cover feature_lead, feature_lag, feature_height,
% feature_width. defaults will be centered in the middle of the 'frame'
% (size) lasting for half the 'frame'(size)

switch nargin
    case 2
        feature_width = feature_size/2/2;
        feature_left = round( feature_size/2 - feature_width/2 );
        feature_index = feature_left:feature_left + feature_width - 1;
        feature_height = 1;
    case 3
        feature_width = varargin{1};
        feature_left = round( feature_size/2 - feature_width/2 );
        feature_index = feature_left:feature_left + feature_width - 1;
        feature_height = 1;
    case 4
        feature_width = varargin{1};
        feature_left = varargin{2};
        feature_index = feature_left:feature_left + feature_width - 1;
        feature_height = 1;
    case 5
        feature_width = varargin{1};
        feature_left = varargin{2};
        feature_index = feature_left:feature_left + feature_width - 1;
        feature_height = varargin{3};
    otherwise
        disp('Input error to fakeFeatureCreator. Too many inputs.');
        return
end

result = zeros(feature_size,1);

switch feature_type
    case 'square'
        result(feature_index) = 1 * feature_height;
    case 'triangle'
        step_triangle = triang( feature_width ) * feature_height;
        result(feature_index) = step_triangle;
    otherwise
        disp('Input error to fakeFeatureCreator. Type not recognized.');
        return
end

end