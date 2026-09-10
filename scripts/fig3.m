%% Fig. 3: Local magnitudes of the modes of change at stations and in models.
% August 2026, Jingya Han, Cornell University, Ithaca, NY. jh2423@cornell.edu
% You might need to change the path of netCDF files for your use
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
% Science Advances figure standards:
%   2-column width 18.4 cm; max depth 19.9 cm (leaves room for the legend)
%   panel letters 9 pt bold capitals; all other type 8 pt sans serif (6 pt min)
%   symbols 5-8 pt; line weights >= 0.28 pt; no minor ticks or grid lines
fn  = 'Arial'; % sans serif equivalent of Myriad, accepted by the guidelines
fs  = 8;   % all labels, ticks and legends
fsl = 7;   % colorbar ticks, still above the 6 pt minimum
fsp = 9;   % panel letters, bold

missrate=20;
path='\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\dataforplot\';

f=figure;
clf;
set(gcf,'units','centimeters','paperpositionmode','auto');
set(gcf,'position',[1 1 18.4 17]); % 2 columns wide, within the 19.9 cm depth
set(f,'Color','white','Renderer','painters');
% left=0.045; down=.72; width=.38; he=.22;
% poss=[left        down             width he;
%       left+0.44   down             width he;
%       left        down-he-0.02     width he;
%       left+0.44   down-he-0.02     width he;
%       0.10        down-2.35*he-0.10 0.30 0.235;
%       0.10+0.44   down-2.35*he-0.10 0.30 0.235];
left=0.04; down= .73;width= .37;he= .2;
poss=[left down width he;
left+0.35 down width he;
left down-he+0.001 width he;
left+0.35 down-he+0.001 width he;
0.08 down-2.2*(he) .27 .23;
0.08+0.38 down-2.2*(he) .27 .23];
%% station

shiftincerr_way1=ncread([path,'stations_modes_spatial_dist_',num2str(missrate),'%miss_19551984_19942023.nc'],...
    'shiftincerr_way1');
finallat=ncread([path,'stationslatlon.nc'],'finallat');
finallon=ncread([path,'stationslatlon.nc'],'finallon');

% increase
cdata=othercolor('RdBu10',8);
s=subplot(3,2,1); s.Position=poss(1,:);
axesm('MapProjection', 'robinson', 'MapLatLimit',[-60 85],'Frame', 'on', 'Grid', 'off', ...
      'MeridianLabel', 'off', 'ParallelLabel', 'off');
setm(gca,'FLineWidth',1);
axis off;
scatterm(finallat, finallon, 9, shiftincerr_way1(:,2), 'filled'); % stations-inc
colormap(cdata); caxis([-40 40]);
load coastlines;
plotm(coastlat, coastlon, 'color',[.7 .7 .7]); % Plot the coastlines in black
hold on;
title('Increase','FontName',fn,'FontSize',fsp,'FontWeight','bold');

% Shift
s=subplot(3,2,2); s.Position=poss(2,:);
axesm('MapProjection', 'robinson', 'MapLatLimit',[-60 85],'Frame', 'on', 'Grid', 'off', ...
      'MeridianLabel', 'off', 'ParallelLabel', 'off');
setm(gca,'FLineWidth',1);
axis off;
scatterm(finallat, finallon, 9, shiftincerr_way1(:,1), 'filled');
colormap(cdata); caxis([-40 40]);
load coastlines;
plotm(coastlat, coastlon, 'color',[.7 .7 .7]); % Plot the coastlines in black
hold on;
title('Shift','FontName',fn,'FontSize',fsp,'FontWeight','bold');
ax_stations=gca;


%% cmip6

gridinc=ncread([path,'cmip6_modes_spatial_dist_',num2str(missrate),'%miss_19551984_19942023.nc'],'gridinc');
gridshift=ncread([path,'cmip6_modes_spatial_dist_',num2str(missrate),'%miss_19551984_19942023.nc'],'gridshift');

% modes at each gridpoint for every individual simulation, so that panels E,F
% show the combination of forced response and internal variability, as the
% station points do. Produced by run_gridmodes_permember.m
f_mem=[path,'cmip6_gridmodes_permember_',num2str(missrate),'%miss_19551984_19942023.nc'];
gridinc_mem=double(ncread(f_mem,'gridinc_mem'));     % station x member
gridshift_mem=double(ncread(f_mem,'gridshift_mem'));
fprintf('per-member modes: %d stations x %d members\n', size(gridinc_mem,1), size(gridinc_mem,2));

% increase
s=subplot(3,2,3); s.Position=poss(3,:);
axesm('MapProjection', 'robinson', 'MapLatLimit',[-60 85], 'Frame', 'on', 'Grid', 'off', ...
      'MeridianLabel', 'off', 'ParallelLabel', 'off');
setm(gca,'FLineWidth',1);
  axis off;
scatterm(finallat, finallon, 9, gridinc, 'filled'); % stations-inc
colormap(cdata); caxis([-40 40]);
load coastlines;
plotm(coastlat, coastlon, 'color',[.7 .7 .7]); % Plot the coastlines in black
hold on;

% Shift
s=subplot(3,2,4); s.Position=poss(4,:);
axesm('MapProjection', 'robinson', 'MapLatLimit',[-60 85],'Frame', 'on', 'Grid', 'off', ...
      'MeridianLabel', 'off', 'ParallelLabel', 'off');
setm(gca,'FLineWidth',1);
  axis off;
scatterm(finallat, finallon, 9, gridshift, 'filled');
colormap(cdata); caxis([-40 40]);
load coastlines;
plotm(coastlat, coastlon, 'color',[.7 .7 .7]); % Plot the coastlines in black
hold on;
ax_model=gca;


%% scatter plot
% increase mode
blue=[30 144 255]/255;
memcol=[0.55 0.55 0.55]; % individual simulations
s=subplot(3,2,5); s.Position=poss(5,:);
% every station x member pair: the model spread including internal variability
yrep=repmat(shiftincerr_way1(:,2),1,size(gridinc_mem,2));
hm=scatter(gridinc_mem(:),yrep(:),4,memcol,'filled'); hold on;
hm.MarkerFaceAlpha=0.1; % ~50000 points, so keep each one faint
hs=scatter(gridinc,shiftincerr_way1(:,2),7,'k','filled'); hold on;
% one on one line
min_val = min([gridinc_mem(:); shiftincerr_way1(:,2)]); % Find minimum value in data
max_val = max([gridinc_mem(:); shiftincerr_way1(:,2)]); % Find maximum value in data
ax=plot([min_val 70], [min_val 70], '--','Color', blue, 'Linewidth',1.5); % One-to-one line
xline(0, '-', 'Color', [0.8 0.8 0.8], 'LineWidth', 0.5);
yline(0, '-', 'Color', [0.8 0.8 0.8], 'LineWidth', 0.5);
xlim([-40 80]); ylim([-40 80]);
set(gca,'FontName',fn,'FontSize',fs,'XTick',-40:20:80,'YTick',-40:20:80);
xlabel('Model (% K^-^1)','FontName',fn,'FontSize',fs);
ylabel('Station (% K^-^1)','FontName',fn,'FontSize',fs);
% l=legend([hm hs],'Individual simulations','Multi-model mean',...
%     'FontName',fn,'FontSize',fsl,'Location','northwest');
% legend('boxoff');

% shift mode
s=subplot(3,2,6); s.Position=poss(6,:);
yrep=repmat(shiftincerr_way1(:,1),1,size(gridshift_mem,2));
hm=scatter(gridshift_mem(:),yrep(:),4,memcol,'filled'); hold on;
hm.MarkerFaceAlpha=0.1;
hs=scatter(gridshift,shiftincerr_way1(:,1),7,'k','filled'); hold on;
% one on one line
min_val = min([gridshift_mem(:); shiftincerr_way1(:,1)]); % Find minimum value in data
max_val = max([gridshift_mem(:); shiftincerr_way1(:,1)]); % Find maximum value in data
ax=plot([min_val 70], [min_val 70], '--','Color', blue, 'Linewidth',1.5); % One-to-one line
xline(0, '-', 'Color', [0.8 0.8 0.8], 'LineWidth', 0.5);
yline(0, '-', 'Color', [0.8 0.8 0.8], 'LineWidth', 0.5);
xlim([-40 80]);
ylim([-40 80]);
% ax.XTicks=[-40 -20 0 20 40 60 80];
% ax.YTicks=[-40 -20 0 20 40 60 80];
xlabel('Model (% K^-^1)','FontName',fn,'FontSize',fs);
ylabel('Station (% K^-^1)','FontName',fn,'FontSize',fs);

% panel letters, placed in normalized figure coordinates from poss so they
% follow the panels if the layout is adjusted
lbl={'A','B','C','D','E','F'};
for i=1:6
    annotation('textbox',[poss(i,1)-0.035 poss(i,2)+poss(i,4)-0.025 0.04 0.03],...
        'String',lbl{i},'LineStyle','none','FontName',fn,'FontSize',fsp,'FontWeight','bold');
end

annotation('textbox',[0.005 poss(1,2)+poss(1,4)-0.06 0.05 0.03],'String',{'Station'},...
    'LineStyle','none','FontName',fn,'FontSize',fs,'FontWeight','bold');
annotation('textbox',[0.005 poss(3,2)+poss(3,4)-0.06 0.05 0.03],'String',{'Model'},...
    'LineStyle','none','FontName',fn,'FontSize',fs,'FontWeight','bold');

hc=colorbar(ax_stations,'Location','eastoutside','Position',[left+1.95*width down-0.1 0.02 he-0.01] );
set(get(hc,'Title'),'string','% K^-^1','FontName','Arial','FontSize',9);
hc.Ticks = [-40 -30 -20 -10 0 10 20 30 40];
hc.FontSize = 7;
cbarrow;
% hc=colorbar(ax_model,'Location','eastoutside','Position',[left+width+0.24 down-he 0.01 he-0.05]);
% set(get(hc,'Title'),'string','% K^-^1','FontName','Arial','FontSize',9);
% hc.Ticks = [-20 -15 -10 -5 0 5 10 15 20];
% hc.FontSize = 7;
% cbarrow;
% hold on;

savefig(['\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\figures\Fig3.fig']);
exportgraphics(gcf,['\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\figures\Fig3.png'],...
    'Resolution', 600); % 600 dpi is the ceiling before downsampling
exportgraphics(gcf,[path,'Fig3.pdf'],...
    'ContentType','vector','BackgroundColor','white');

% % pdf version
% addpath(genpath('C:\Program Files\MATLAB\altmany-export_fig-d5538e9'));
% export_fig(gcf,'-eps', '-r300', '-painters', '\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\figures\Fig3.eps');
% export_fig(gcf,'-pdf', '-r300', '-painters', '\\wsl.localhost\Ubuntu\home\jingya\station_model_precip_modes\figures\Fig3.pdf');