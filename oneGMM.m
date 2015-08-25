% NOT USEFUL ANYMORE. WHY DID I WRITE THIS IN THE FIRST PLACE?

% assume the six dimension model is being passed, don't use Mu (band 4) and
% build one 'full' model to return
function full_model = oneGMM(gmm_models)
valid_bands = [1,2,3,5,6];
new_mu = zeros( size(gmm_models{1}.mu) );
new_Sigma = zeros( size(gmm_models{1}.Sigma) );

for i=1:length(valid_bands)
    new_mu = gmm_models{valid_bands(i)}.mu + new_mu;
    new_Sigma = gmm_models{valid_bands(i)}.Sigma + new_Sigma;
end

new_mu = new_mu ./ 6;
new_Sigma = new_Sigma ./ 6;

full_model = gmdistribution(new_mu,new_Sigma);

end