% break everything down into chunks

% A separate function to handle segmenting the data into windows and
% frames. More or less a duplicate of what is already present in the
% functions used to build epochs.mat and gmm.mat

function [data_full, data_block, data_epoch] = blockFrameWindowEpoch(input,mf)

channels = length(input.data(:,1));

% MFCC leg work
data_full.CCs = cell(1,channels);
data_full.FBE = cell(1,channels);
data_full.frames = cell(1,channels);
cc_filter = @(N)(0.54-0.46*cos(2*pi*(0:N-1).'/(N-1)));

% full signal MFCC
for k=1:channels
    [data_full.CCs{k},data_full.FBE{k},data_full.frames{k}] = mfcc(...
        input.data(k,:),input.sample_rate, mf.analysis_frame,mf.analysis_shift,...
        mf.pre_emp_coef, cc_filter, mf.range, mf.banks, mf.cc_num,...
        mf.liftering_param);
end

% build blocks
block_bits = mf.block_time*input.sample_rate;
block_count = floor( input.duration / block_bits );
data_block.CCs = cell(block_count,channels);
data_block.FBE = cell(block_count,channels);
data_block.frames = cell(block_count,channels);

for k=1:block_count
    block_range = 1 + (k-1)*block_bits : 1 + (k*block_bits);
    for l=1:channels
        [data_block.CCs{k,l},data_block.FBE{k,l},data_block.frames{k,l}] =...
            mfcc(input.data(l,block_range), input.sample_rate, mf.analysis_frame,...
            mf.analysis_shift, mf.pre_emp_coef, cc_filter, mf.range,...
            mf.banks, mf.cc_num, mf.liftering_param);
    end
end

% build epoch samples
epoch_bits = mf.epoch_time*input.sample_rate;
epoch_count = floor( input.duration / epoch_bits );
data_epoch.CCs = cell(epoch_count,channels);
data_epoch.FBE = cell(epoch_count,channels);
data_epoch.frames = cell(epoch_count,channels);

for k=1:epoch_count
    epoch_range = 1 + (k-1)*epoch_bits : 1 + (k*epoch_bits);
    for l=1:channels
        [data_epoch.CCs{k,l},data_epoch.FBE{k,l},data_epoch.frames{k,l}] =...
            mfcc(input.data(l,epoch_range), input.sample_rate, mf.analysis_frame,...
            mf.analysis_shift, mf.pre_emp_coef, cc_filter, mf.range,...
            mf.banks, mf.cc_num, mf.liftering_param);
    end
end

end