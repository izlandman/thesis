% A function called by _eegStatistics_ that is working to do the work that
% should have been done by building GMMs

% INPUTS: COEFFICIENTS should be the peak values from each channel over
% time

% OUTPUTS: DATASET are the mean and standard deviation of each channels
% coefficients

function [dataSet] = meanAndStandardDev(coefficients)

[rows,columns] = size(coefficients);

variables = length(coefficients{1}(:,1));

means_minor = zeros(variables,columns);
stddevs_minor = zeros(variables,columns);

for n=1:columns
    means_minor(:,n) = mean(coefficients{n},2);
    stddevs_minor(:,n) = std(coefficients{n},[],2);
end

means = mean(means_minor,2);
stddevs = mean(stddevs_minor,2);
% coefficient of variation (CV)
ratio = stddevs./means;

dataSet = [means,stddevs,ratio];
end