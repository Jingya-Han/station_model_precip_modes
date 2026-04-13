%%  Fig. 1: Global precipitation amount distributions for stations and models
% 1 September 2025, Jingya Han, Cornell University, Ithaca, NY. jh2423@cornell.edu
% You might need to change the path of netCDF files for your use
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
period1=1955:1984;
period2=1994:2023; %1995:2024;
missrate=20;
path='/share/cliprelabs/jh2423/P1/dataforplot/';
oldbincrates=ncread([path,'way0_stations_',num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),...
    '_',num2str(period2(1)),num2str(period2(end)),'.nc'],'oldbincrates');
oldpamt1=ncread([path,'way0_stations_',num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),...
    '_',num2str(period2(1)),num2str(period2(end)),'.nc'],'oldpamt1');

bincrates=ncread([path,'way1_stations_',num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),...
    '_',num2str(period2(1)),num2str(period2(end)),'.nc'],'bincrates');
kdepamt1=ncread([path,'way1_stations_',num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),...
    '_',num2str(period2(1)),num2str(period2(end)),'.nc'],'kdepamt1');

oldBINCRATES=ncread([path,'way0_MMM_',num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),...
    '_',num2str(period2(1)),num2str(period2(end)),'.nc'],'oldBINCRATES');
oldMMMpamt1=ncread([path,'way0_MMM_',num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),...
    '_',num2str(period2(1)),num2str(period2(end)),'.nc'],'oldMMMpamt1');

KDEMMMpamt1=ncread([path,'way1_MMM_',num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),...
    '_',num2str(period2(1)),num2str(period2(end)),'.nc'],'KDEMMMpamt1');
BINCRATES=ncread([path,'way1_MMM_',num2str(missrate),'%miss_',num2str(period1(1)),num2str(period1(end)),...
    '_',num2str(period2(1)),num2str(period2(end)),'.nc'],'BINCRATES');

finallat=ncread([path,'stationslatlon.nc'],'finallat');
finallon=ncread([path,'stationslatlon.nc'],'finallon');
ghcnlats=ncread([path,'stationslatlon.nc'],'ghcnlats');
ghcnlons=ncread([path,'stationslatlon.nc'],'ghcnlons');


f=figure; clf
set(gcf,'units','centimeters','paperpositionmode','auto');
set(gcf,'position',[1 1 18 16]); 
set(f,'Color','white');
poss=[0.005 0.6 .8 .4;
    0.1 0.22 0.6 0.35];
% plot station map
s=subplot(2,1,1); s.Position=poss(1,:);

axesm('MapProjection', 'robinson', 'MapLatLimit',[-60 85],'Frame', 'on', 'Grid', 'off', ...
      'MeridianLabel', 'off', 'ParallelLabel', 'off');
setm(gca,'FLineWidth',1);
axis off;
scatterm(ghcnlats, ghcnlons,4, [222 184 135]/255,"filled",'DisplayName', 'Original stations'); % stations-inc
scatterm(finallat, finallon,9, [147 112 219]/255,"filled",'DisplayName', 'Quality-controlled stations'); % stations-inc
load coastlines;
plotm(coastlat, coastlon, 'color',[.7 .7 .7]); % Plot the coastlines
hold on;
annotation('textbox',...
    [0.15 0.95 0.06 0.04],'String',{'a'},'LineStyle','none',...
    'FontName','Arial','FontSize',9,'FontWeight','bold');
% legend
pos=get(gca,'Position');
h_at=axes('Position',[0.04 0.7 0.06 0.03]);
scatter(1.5,1,50,'o','filled','MarkerFaceColor',[222 184 135]/255,'LineWidth',1); hold on;
scatter(1.5,2,100,'o','filled','MarkerFaceColor',[147 112 219]/255,'LineWidth',1); hold on;
text(2,1,'All GHCNd stations','FontName','Arial','fontsize',9');
text(2,2,'Included stations','FontName','Arial','fontsize',9');
axis off;
hold on;

% raw and smoothed distrbutions
s=subplot(2,1,2); s.Position=poss(2,:);
xtickrates=[0 0.1:.1:.9 1:1:9 10:10:90 100:100:1000]; % rain rates in mm/d for x axis
xticks=interp1(bincrates,1:length(bincrates),xtickrates); % bin numbers associated with nice number rain rate
xtickratesp={0 0.1 [] [] [] [] [] [] [] [] 1 [] [] [] [] [] [] [] [] 10 [] [] [] [] [] [] [] [] 100 [] [] [] [] [] [] [] [] 1000}; % rain rates with white space in between
pbinm=(1-10.^(-.1:-.1:-4)); % percentile bins for calculations
xtickpercent=[30:10:90 91:99 99.1:.1:99.9 99.91:.01:99.99]/100; % percentiles for x-axes of percentile plots
xticks99=interp1(pbinm,1:length(pbinm),xtickpercent); % bin numbers of percentiles for plotting
xtickratesp(isnan(xticks))=[];
xticks(isnan(xticks))=[];
db=(bincrates(3)-bincrates(2))./bincrates(2); % bin width

h=scatter(1:length(oldbincrates),oldpamt1,'MarkerEdgeColor',[.5 .5 .5]); hold on; box on;
plot(1:length(bincrates),kdepamt1,'Color',[30 144 255]/255,'lineWidth', 1.5); hold on;
plot(1:length(oldBINCRATES),oldMMMpamt1,'Color',[50 205 50]/255,'lineWidth', 1.5); hold on;
plot(1:length(BINCRATES),KDEMMMpamt1,'Color',[255 144 30]/255,'lineWidth', 1.5); hold on;
legend({'Station-Raw','Station-Smoothed','Model-Raw','Model-Smoothed'},...
    'Position',[0.2 0.42 0.1 0.05],'FontName','Arial','fontsize',9);
legend('boxoff')

set(gca,'xtick',xticks,'xticklabel',xtickratesp,'fontsize',8,'XTickLabelRotation',0,'FontName','Arial');
set(gca,'fontsize',8,'FontName','Arial');
xlim([0 142]);
ylim([0 0.065]);
a=axis;
text(6,a(4)*0.9,'b','FontName','Arial','fontsize',9,'FontWeight','bold');
xlabel('Precipitation rate (mm d ^-^1)','FontName','Arial','fontsize',9);
ylabel('Precipitation amount (mm d ^-^1)','FontName','Arial','fontsize',9);

savefig('/share/cliprelabs/jh2423/P1/figures/Fig1.fig');
exportgraphics(gcf,"/share/cliprelabs/jh2423/P1/figures/Fig1.png",...
    'Resolution', 300);
% % pdf version
% addpath(genpath('C:\Program Files\MATLAB\altmany-export_fig-d5538e9'));
% export_fig(gcf,'-eps', '-r300', '-painters', '\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\figures\Fig1.eps');
% export_fig(gcf,'-pdf', '-r300', '-painters', '\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\figures\Fig1.pdf');

