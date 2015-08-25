% max six clusters!

% mostly builit from a day trying to remember things about clustering and
% machine learning mechanics. it did work, but it serves no purpose aside
% from refreshing my memory

function kMeansEEGcluster(variables_full,clusters,variables_true)

if( ishandle(56) )
    close (56);
end

real_points = length(variables_true(1,1,:));

[idx,C] = kmeans(variables_full,clusters);
colors_full = { 'ro';'bo';'mo';'ko';'go';'co'};
colors_true = { 'r.';'b.';'m.';'k.';'g.';'c.'};
figure(56);hold on;grid on;

switch length(C(1,:))
    
    case 1
        
    case 2
        for i=1:clusters
            plot(variables_full(idx==i,1),variables_full(idx==i,2),colors_full{i},'MarkerSize',14);
        end
        for k=1:real_points
            plot(variables_true(:,1,k),variables_true(:,2,k),colors_true{k},'MarkerSize',14);
        end
        plot3(C(:,1),C(:,2),'ko','MarkerSize',30);
        plot3(C(:,1),C(:,2),'c*','MarkerSize',15);
    case 3
        for i=1:clusters
            plot3(variables_full(idx==i,1),variables_full(idx==i,2),variables_full(idx==i,3),colors_full{i},'MarkerSize',14);
        end
        for k=1:real_points
            plot3(variables_true(:,1,k),variables_true(:,2,k),variables_true(:,3,k),colors_true{k},'MarkerSize',14);
        end
        
        plot3(C(:,1),C(:,2),C(:,3),'ko','MarkerSize',30);
        plot3(C(:,1),C(:,2),C(:,3),'c*','MarkerSize',15);
        xlabel('max frequency');ylabel('average frequency');zlabel('minimum frequency');
    case 4
        disp('Four dimensional data, plotting first three dimensions only.');
        for i=1:clusters
            plot3(variables_full(idx==i,1),variables_full(idx==i,2),variables_full(idx==i,3),colors_full{i},'MarkerSize',14);
        end
        for k=1:real_points
            plot3(variables_true(:,1,k),variables_true(:,2,k),variables_true(:,3,k),colors_true{k},'MarkerSize',14);
        end
        
        plot3(C(:,1),C(:,2),C(:,3),'ko','MarkerSize',30);
        plot3(C(:,1),C(:,2),C(:,3),'c*','MarkerSize',15);
        xlabel('max frequency');ylabel('average frequency');zlabel('minimum frequency');
        
end

end