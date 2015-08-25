% something written on a friday to test out other code. most likely pusehd
% into some other file or simply saved because I kept updating it on that
% particular Friday

data1 = trial_3_model_1;
data2 = trial_10_model_62;

[a1,b1,c1,d1] = size(data1);
[a2,b2,c2,d2] = size(data2);

feature = 2;
bands = (1:1:c1);
band = 2;

amplitudes_1 = squeeze( data1(:,feature,band,:) );
amplitudes_2 = squeeze( data2(:,feature,band,:) );

% euclidean distance measurements
euc_dist_1 = zeros(d1,d1*a1,a1);
euc_dist_2 = zeros(d1,d2*a2,a1);
for i=1:a1
    operate_on_this = squeeze(data1(i,feature,band,:));
    euc_dist_1(:,:,i) = pdist2( operate_on_this, reshape(amplitudes_1,a1*d1,1));
    euc_dist_2(:,:,i) = pdist2( operate_on_this, reshape(amplitudes_2,a2*d2,1));
end

clear amplitudes_1 amplitudes_2

% histogram of intra and inter
max_X = 450;
x = 0:1:max_X;

[n1,x] = hist(euc_dist_1,x);
clear euc_dist_1
[n2,x] = hist(euc_dist_2,x);
clear euc_dist_2

n1 = n1./sum(n1);
n2 = n2./sum(n2);

figure(57);
bar(x,[n1;n2]','grouped');grid on;
axis([ 0 max_X 0 max(max([n1;n2]))*1.1]);