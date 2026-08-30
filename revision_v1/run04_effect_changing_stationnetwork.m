%%% calculate and compare 2 hypothetical distributions of rain, one at a point (~1km square) and one in a gridbox consisting of 100 of these smaller points. 
%%% there are 2 types of precipitation: 
%%%   1. large-scale precipitation covering all points with the same precipitation
%%%   2. convective precipitation covering a single point. 
%%%   The convective precipitation is 10x heavier than the large scale
%%%   precipitation (on average). The frequency and variability are not
%%%   necessarily the same either. Log normal distributions are assumed. 
%%% set the mean and width of the 2 distributions - when
%%% it's raining. also the frequency of large scale and convective precipitation, to determine that (0:1) 
% [LS conv]
% 1 September 2026, Jingya Han, Cornell University, Ithaca, NY. jh2423@cornell.edu


% %%% initial values 
m=[1 10];  % mean precip
s=[.25 5]; % standard deviation of precip
rf=[.5 .1]; % precip frequency 

npts_p1=3; % number of points in the grid cell in epoch 1
npts_p2=5; % number of points in the grid cell in epoch 2
nsamp=10^5; % number of samples 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

v=s.^2; % variance 
mu=log(m./sqrt(1+v./m.^2));
sigma=sqrt(log(1+v./m.^2));

x0=lognrnd(mu(1),sigma(1),1,nsamp);
x1=lognrnd(mu(2),sigma(2),npts_p1,nsamp); % epoch 1
x2=lognrnd(mu(2),sigma(2),npts_p2,nsamp); % epoch 2

r0=(rand([1 nsamp])<rf(1)).*x0; 
r1=(rand([npts_p1 nsamp])<rf(1)).*x1; % large scale and convective (epoch 1)
% completely independent
r1(r0>0)=0; % no convective precip during LS events

r2=(rand([npts_p2 nsamp])<rf(1)).*x2; % large scale and convective (epoch 2)
% completely independent
r2(r0>0)=0; % no convective precip during LS events

[n,bins]=hist([log(r0)' log(r1(1,:))'],100);
h1=n(:,1);
h2=n(:,2);

figure;
set(gcf,'units','centimeters','position',[1 1 18.4 6]);   % width 18.4 cm, height 6 cm
set(gcf,'Color','white');
poss=[0.065 0.18 0.265 0.74;
      0.385 0.18 0.265 0.74;
      0.705 0.18 0.265 0.74];

% Keep the axes handles. Calling subplot(13x) again after moving an axes can
% cause MATLAB to create a fresh axes at the default grid position and
% discard the custom one, so use axes(ax) to switch instead.
ax(1)=subplot(1,3,1); ax(1).Position=poss(1,:);
ax(2)=subplot(1,3,2); ax(2).Position=poss(2,:);
ax(3)=subplot(1,3,3); ax(3).Position=poss(3,:);

axes(ax(1))
p = plot(bins,h1,'-',bins,h2,'--','LineWidth',1.2);
p(1).Color = [0 0.5 0];    % green
p(2).Color = [0.5 0 0.7];  % purple
title('generating dists')
legend('stratiform','convective')
xlabel('log(rain rate)')
ylabel('frequency')
% xlim([-1 4])

axes(ax(2))
pointrain = r0+r1(1,:);
gridrain = r0+mean(r1,1);
[n,bins]=hist([log(gridrain)' log(pointrain)'],100);
h1=n(:,1);
h2=n(:,2);
plot(bins,h1,'k',bins,h2,'r','LineWidth',1.2)
title('Epoch 1')
legend('grid (3 points)','point')
xlabel('log(rain rate)')
ylabel('frequency')
% xlim([-1 4])

axes(ax(3))
pointrain = r0+r2(1,:);
gridrain = r0+mean(r2,1);
[n,bins]=hist([log(gridrain)' log(pointrain)'],100);
h1=n(:,1);
h2=n(:,2);
plot(bins,h1,'k',bins,h2,'r','LineWidth',1.2)
title('Epoch 2')
legend('grid (5 points)','point')
xlabel('log(rain rate)')
ylabel('frequency')
% xlim([-1 4])

%% ------------------------------------------------------- panel labels
% Placed in normalized axes units, so they stay in the upper-left corner
% inside the box regardless of the data limits.
lbl = {'A','B','C'};
for k = 1:3
    text(ax(k), 0.035, 0.955, lbl{k}, 'Units','normalized', ...
        'FontName','Arial','FontSize',10,'FontWeight','bold', ...
        'HorizontalAlignment','left','VerticalAlignment','top');
end

savefig('\\wsl.localhost\ubuntu\home\jingya\station_model_precip_modes\revision_v1\figs\FigR1.fig');
exportgraphics(gcf,"\\wsl.localhost\ubuntu\home\jingya\station_model_precip_modes\revision_v1\figs\FigR1.png",...
    'Resolution', 300);


% % print -depsc -painters benstest.eps 
% 
% 
% nstat=2; 
% 
% prperiod=[gridrain; pointrain];
% 
% 
% pbinm=(1-10.^(-.1:-.1:-5));
% 
% phalf=NaN(nstat,1);
% dayphalf=NaN(nstat,1);
% p95w=NaN(nstat,1);
% pperc=NaN(nstat,length(pbinm));
% pday=NaN(nstat,365);
% fdry=NaN(nstat,1);
% 
% for istat=1:nstat
%     thisp=prperiod(istat,:);
%     psort=sort(thisp);
%     psort(isnan(psort))=[];
%     nd=length(psort);
%     pbinm=(1-10.^(-.1:-.1:-5));
%     cs=cumsum(psort,'reverse')./sum(psort);
%     ptile=(1:nd)/nd;
% 
%     p=interp1(ptile,cs,pbinm);
% 
%     [csu,ia]=unique(cs);
%     thisphalf=interp1(csu,ptile(ia),.5);
%     pfrac=interp1(ptile,cs,(1- (1:365)/365));
% 
%     phalf(istat)=thisphalf;
%     dayphalf(istat)=(1-thisphalf)*365;
% 
%     pperc(istat,:)=p;
%     pday(istat,:)=pfrac;
% 
%     fdry(istat)=sum(psort==0)./nd;
% 
%     psort=psort(psort>0);
%     nd=length(psort);
%     ptile=(1:nd)/nd;
%     cs=cumsum(psort,'reverse')./sum(psort);
%     thisp95w=interp1(ptile,cs,.95);
%     p95w(istat)=thisp95w;
% end
% 
% 
% pfrac1=pday(:,1);
% pfrac2=pday(:,2);
% pfrac5=pday(:,5);
% p95=pperc(:,13);
% p99=pperc(:,20);
% pfrac2w=pday(:,14);
% 
% 
% binlbinrfordist;
% binlbinrforplot;
% 

% % figure(1)
% % 
% figure(2)
% clf
% set(gcf,'units','centimeters','paperpositionmode','auto');
% set(gcf,'position',[10 14 16/2*2 16]);
% 
% 
% subplot(2,2,3)
% % p1=plot(1:length(pbinm),pperc);
% % set(p1,'linewidth',1.5)
% % hold on
% p2=plot(1:length(pbinm),pperc);
% % set(p2,'color',[1 1 1]*.75)
% set(p2,'linewidth',1.5)
% set(p2(1),'color','k')
% set(p2(2),'color','r')
% ylim([0 1])
% makeextrememinorticks(5)
% xlabel('Percentiles')
% ylabel('Cumulative fraction of rain')
% title('Cumulative frac. by percentile')
% set(gca,'ytick',0:.25:1)
% legend('gridarea','point')
% 
% subplot(2,2,4)
% p2=plot(1:365,pday);
% set(p2,'linewidth',1.5)
% set(p2(1),'color','k')
% set(p2(2),'color','r')
% xlim([0 50])
% ylim([0 1])
% grid on
% hold on
% title('Cumulative frac. by # days')
% ylabel('Cumulative frac. by # days')
% xlabel('Days')
% set(gca,'ytick',0:.25:1)
% 
% 
% 
% [n,bins]=hist([log(r1)' log(r2(1,:))'],100);
% h1=n(:,1);
% h2=n(:,2);
% 
% subplot(221)
% p2=plot(bins,h1,'k',bins,h2,'r');
% set(p2,'linewidth',1.5)
% title('Generating dists')
% legend('large scale','convective')
% xlabel('log(rain rate)')
% ylabel('frequency')
% xlim([bins(1) bins(end)])
% a=axis; 
% ylim([0 min(a(4),nsamp*sum(rf))])
% 
% 
% [n,bins]=hist([log(gridrain)' log(pointrain)'],100);
% h1=n(:,1);
% h2=n(:,2);
% 
% subplot(222)
% p2=plot(bins,h1,'k',bins,h2,'r');
% set(p2,'linewidth',1.5)
% title('Resulting dists')
% legend('gridarea','point')
% xlabel('log(rain rate)')
% ylabel('frequency')
% xlim([bins(1) bins(end)])
% a=axis; 
% ylim([0 min(a(4),nsamp*sum(rf))])
% 
% % print -dpdf -painters benstest.pdf 