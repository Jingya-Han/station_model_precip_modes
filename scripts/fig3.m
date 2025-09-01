%% Fig. 3: Local magnitudes of the modes of change at stations and in models.
% 1 September 2025, Jingya Han, Cornell University, Ithaca, NY. jh2423@cornell.edu
% You might need to change the path of netCDF files for your use
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
f=figure;
clf;
set(gcf,'units','centimeters','paperpositionmode','auto');
set(gcf,'position',[1 1 32 18]); 
set(f,'Color','white');
left=0.04; down= .74;width= .35;he= .2;
poss=[left down width he;
left+0.27 down width he;
left down-he-0.015 width he;
left+0.27 down-he-0.015 width he;
0.13 down-2.5*(he) .19 .23;
0.13+0.27 down-2.5*(he) .19 .23];
%% station

shiftincerr_way1=ncread('dataforplot/stations_modes_spatial_dist_19%miss_19551984_19942023.nc',...
    'shiftincerr_way1');
finallat=ncread('dataforplot/stationslatlon.nc','finallat');
finallon=ncread('dataforplot/stationslatlon.nc','finallon');

% increase
cdata=othercolor('RdBu10',8);
s=subplot(3,2,1); s.Position=poss(1,:);
axesm('MapProjection', 'robinson', 'MapLatLimit',[-60 85],'Frame', 'on', 'Grid', 'off', ...
      'MeridianLabel', 'off', 'ParallelLabel', 'off');
setm(gca,'FLineWidth',1);
axis off;
scatterm(finallat, finallon, 12, shiftincerr_way1(:,2), 'filled'); % stations-inc
colormap(cdata); caxis([-40 40]);
load coastlines;
plotm(coastlat, coastlon, 'color',[.7 .7 .7]); % Plot the coastlines in black
hold on;
title('Increase','FontName','Arial','FontSize',9,'FontWeight','bold');

% Shift
s=subplot(3,2,2); s.Position=poss(2,:);
axesm('MapProjection', 'robinson', 'MapLatLimit',[-60 85],'Frame', 'on', 'Grid', 'off', ...
      'MeridianLabel', 'off', 'ParallelLabel', 'off');
setm(gca,'FLineWidth',1);
axis off;
scatterm(finallat, finallon, 12, shiftincerr_way1(:,1), 'filled');
colormap(cdata); caxis([-40 40]);
load coastlines;
plotm(coastlat, coastlon, 'color',[.7 .7 .7]); % Plot the coastlines in black
hold on;
title('Shift','FontName','Arial','FontSize',9,'FontWeight','bold');
ax_stations=gca;


%% cmip6

gridinc=ncread(['dataforplot/cmip6_modes_spatial_dist_19%miss_19551984_19942023.nc'],'gridinc');
gridshift=ncread(['dataforplot/cmip6_modes_spatial_dist_19%miss_19551984_19942023.nc'],'gridshift');

% increase
s=subplot(3,2,3); s.Position=poss(3,:);
axesm('MapProjection', 'robinson', 'MapLatLimit',[-60 85], 'Frame', 'on', 'Grid', 'off', ...
      'MeridianLabel', 'off', 'ParallelLabel', 'off');
setm(gca,'FLineWidth',1);
  axis off;
scatterm(finallat, finallon, 12, gridinc, 'filled'); % stations-inc
colormap(cdata); caxis([-20 20]);
load coastlines;
plotm(coastlat, coastlon, 'color',[.7 .7 .7]); % Plot the coastlines in black
hold on;

% Shift
s=subplot(3,2,4); s.Position=poss(4,:);
axesm('MapProjection', 'robinson', 'MapLatLimit',[-60 85],'Frame', 'on', 'Grid', 'off', ...
      'MeridianLabel', 'off', 'ParallelLabel', 'off');
setm(gca,'FLineWidth',1);
  axis off;
scatterm(finallat, finallon, 12, gridshift, 'filled');
colormap(cdata); caxis([-20 20]);
load coastlines;
plotm(coastlat, coastlon, 'color',[.7 .7 .7]); % Plot the coastlines in black
hold on;
ax_model=gca;


% annotation('textbox',...
%     [0.034 0.85 0.06 0.04],'String',{'Station'},'LineStyle','none','FontName','Nimbus Roman','FontSize',16);
% annotation('textbox',...
%     [0.034 0.63 0.06 0.04],'String',{'Model'},'LineStyle','none','FontName','Nimbus Roman','FontSize',16);


%% scatter plot
% increase mode
blue=[30 144 255]/255;
s=subplot(3,2,5); s.Position=poss(5,:);
scatter(gridinc,shiftincerr_way1(:,2),6,'k','filled'); hold on;
% one on one line
min_val = min([gridinc shiftincerr_way1(:,2)]); % Find minimum value in data
max_val = max([gridinc shiftincerr_way1(:,2)]); % Find maximum value in data
ax=plot([min_val max_val], [min_val max_val], '--','Color', blue, 'Linewidth',1.5); % One-to-one line
xline(0, '-', 'Color', [0.8 0.8 0.8], 'LineWidth', 0.5);
yline(0, '-', 'Color', [0.8 0.8 0.8], 'LineWidth', 0.5);
xlim([-40 80]);
ylim([-40 80]);
% ax.XTicks=[-40 -20 0 20 40 60 80];
% ax.YTicks=[-40 -20 0 20 40 60 80];
xlabel('Model (% K^-^1)','FontName','Arial','FontSize',9);
ylabel('Station (% K^-^1)','FontName','Arial','FontSize',9);

% shift mode
s=subplot(3,2,6); s.Position=poss(6,:);
scatter(gridshift,shiftincerr_way1(:,1),6,'k','filled'); hold on;
% one on one line
min_val = min([gridshift shiftincerr_way1(:,1)]); % Find minimum value in data
max_val = max([gridshift shiftincerr_way1(:,1)]); % Find maximum value in data
ax=plot([min_val max_val], [min_val max_val], '--','Color', blue, 'Linewidth',1.5); % One-to-one line
xline(0, '-', 'Color', [0.8 0.8 0.8], 'LineWidth', 0.5);
yline(0, '-', 'Color', [0.8 0.8 0.8], 'LineWidth', 0.5);
xlim([-40 80]);
ylim([-40 80]);
% ax.XTicks=[-40 -20 0 20 40 60 80];
% ax.YTicks=[-40 -20 0 20 40 60 80];
xlabel('Model (% K^-^1)','FontName','Arial','FontSize',9);
ylabel('Station (% K^-^1)','FontName','Arial','FontSize',9);

annotation('textbox',...
    [0.085 0.9 0.06 0.04],'String',{'a'},'LineStyle','none','FontName','Arial','FontSize',9,'FontWeight','bold');
annotation('textbox',...
    [0.35 0.9 0.06 0.04],'String',{'b'},'LineStyle','none','FontName','Arial','FontSize',9,'FontWeight','bold');
annotation('textbox',...
    [0.085 0.9-0.22 0.06 0.04],'String',{'c'},'LineStyle','none','FontName','Arial','FontSize',9,'FontWeight','bold');
annotation('textbox',...
    [0.35 0.9-0.23 0.06 0.04],'String',{'d'},'LineStyle','none','FontName','Arial','FontSize',9,'FontWeight','bold');
annotation('textbox',...
    [0.14 0.9-2*0.23 0.06 0.04],'String',{'e'},'LineStyle','none','FontName','Arial','FontSize',9,'FontWeight','bold');
annotation('textbox',...
    [0.15+0.26 0.9-2*0.22 0.06 0.04],'String',{'f'},'LineStyle','none','FontName','Arial','FontSize',9,'FontWeight','bold');

annotation('textbox',...
    [0.03 0.85 0.1 0.04],'String',{'Station'},'LineStyle','none','FontName','Arial','FontSize',9,'FontWeight','bold');
annotation('textbox',...
    [0.03 0.85-0.22 0.1 0.04],'String',{'Model'},'LineStyle','none','FontName','Arial','FontSize',9,'FontWeight','bold');

hc=colorbar(ax_stations,'Location','eastoutside','Position',[left+width+0.24 down 0.01 he-0.05] );
set(get(hc,'Title'),'string','% K^-^1','FontName','Arial','FontSize',9);
hc.Ticks = [-40 -30 -20 -10 0 10 20 30 40];
hc.FontSize = 7;
cbarrow;
hc=colorbar(ax_model,'Location','eastoutside','Position',[left+width+0.24 down-he 0.01 he-0.05]);
set(get(hc,'Title'),'string','% K^-^1','FontName','Arial','FontSize',9);
hc.Ticks = [-20 -15 -10 -5 0 5 10 15 20];
hc.FontSize = 7;
cbarrow;
hold on;

% savefig('/share/cliprelabs/jh2423/modesofchange_system/results_01-Feb-2025 15:39:58/figs_19%miss_19551984_19942023/v2/Fig3.fig');
% exportgraphics(gcf,"/share/cliprelabs/jh2423/modesofchange_system/results_01-Feb-2025 15:39:58/figs_19%miss_19551984_19942023/v2/Fig3.png",...
%     'Resolution', 300);