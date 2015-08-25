% NOT A GOOD FILE, AGAIN. WHAT WERE YOU THINKING ABOUT HERE?

% take two epochs, find euclidean distance between each of the channels
% based upon their time as a vector?

function euc_dist = epochHistograms(data1,data2)

% data1 = rec_model_6;
% data2 = trial_10_model_15;

[a1,b1,c1,d1] = size(data1);
[a2,b2,c2,d2] = size(data2);

feature = 2;
band = 2;

amplitudes = squeeze( data2(:,feature,band,:) );

% handle variable time lengths
if( d1 > d2 )
    real_d = d2;
elseif( d2 > d1 )
    real_d = d1;
else
    real_d = d1;
end
% euclidean distance measurements
euc_dist = zeros(a1,a2);

for i=1:a1
    operate_on_this = squeeze(data1(i,feature,band,:));
    euc_dist(i,:) = pdist2( operate_on_this(1:real_d)',amplitudes(:,1:real_d));
end

end
