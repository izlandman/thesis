clear;
x = [2 1 1 2 2 1 1 2 1 2 2 1 1 2 1];
z = 0*x;

y = reshape([z;x],1,[]);

figure(1);clf;
imagesc(y);
axis equal
axis tight
% axis off
c1 = [0.9290    0.6940    0.1250];
c2 = [0.8500    0.3250    0.0980];
c3 = [0    0.4470    0.7410];
colormap([c1 ; c2 ; c3]);
colorbar('southoutside','Ticks',[0 1 2],'TickLabels',{'Rest','Task 1','Task 2'});
set(gca, 'YTick',[]);
vals = (0:length(y)+1);
set(gca,'XTick',linspace(0,length(vals),length(vals)+1));
set(gca,'xticklabel',(sprintf('%.f\n',vals)));
xlabel('Tasks (4.1 seconds in duration)');
title('Task Annotation');
set(gca,'fontsize',14);