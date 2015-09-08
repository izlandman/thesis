function result = matchFeatureWeights(data,varargin)

% assume that data could be three dimensions
[rowz,columnz,channels] = size(data);

% now that all the features are generated, time to group them together
result = zeros(rowz,rowz,channels);

% handle passed in weights, if present
if( nargin == 1 )
    match_weights = ones(1,columnz);
else
    match_weights = varargin{1};
end
    
for q=1:channels
    for r=1:rowz
        for i=r:rowz
            result(r,i,q) = sum(( abs(data(r,:,q)-data(i,:,q)) == 0).*match_weights)/columnz;
        end
    end
end

end